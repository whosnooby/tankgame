/// The physics engine for the game
/// It's quite limited, using AABB colliders
package physics

import log "../logging"

import SDL "vendor:sdl3"

ColliderCap :: 512
StaticColliderCap :: ColliderCap - DynamicColliderCap
DynamicColliderCap :: 128

@(private="file")
ColliderIndex :: u16

State :: struct {
    colliders: [ColliderCap]Collider,
    static_colliders: []Collider,
    dynamic_colliders: []Collider,

    static_collider_count: uint,
    dynamic_collider_count: uint,
}

physics_state_init :: proc(phys: ^State) {
    phys.dynamic_colliders = phys.colliders[:DynamicColliderCap]
    phys.static_colliders = phys.colliders[DynamicColliderCap:StaticColliderCap]
}

// updates the collision checker data in all of the colliders
// to mark whether they passed a broad collision check phase
check_possible_collisions :: proc(phys: ^State) {
    for i1 := 0; i1 < ColliderCap; i1 += 1 {
        colliderA := &phys.colliders[i1] 
        colliderA.active or_continue

        for i2 := i1 + 1; i2 < ColliderCap; i2 += 1 {
            colliderB := &phys.colliders[i2]
            colliderB.active or_continue

            might_intersect := collider_might_intersect(colliderA^, colliderB^)
            colliderA.colcheck_data.might_have_collision = might_intersect
            colliderB.colcheck_data.might_have_collision = might_intersect
        }
    } 
}

// checks for collisions and updates the colliders with the collision data.
// used as the narrow phase of collision detected, unless `narrow` == false,
// in which case all colliders are checked
check_collisions :: proc(phys: ^State, narrow := true) {
    for i1 := 0; i1 < ColliderCap; i1 += 1 {
        colliderA := &phys.colliders[i1] 
        colliderA.active or_continue
        if narrow {
            colliderA.colcheck_data.might_have_collision or_continue
        }

        for i2 := i1 + 1; i2 < ColliderCap; i2 += 1 {
            colliderB := &phys.colliders[i2]
            colliderB.active or_continue
            if narrow {
                colliderB.colcheck_data.might_have_collision or_continue
            }

            does_intersect := collider_intersects(colliderA^, colliderB^)

            colliderA.has_collision = does_intersect
            colliderB.has_collision = does_intersect
            colliderA.collision.other = colliderB if does_intersect else nil
            colliderB.collision.other = colliderA if does_intersect else nil
        }
    } 
}

tick :: proc(phys: ^State) {
    // physics_manager_check_possible_collisions(phys)
    check_collisions(phys, narrow = false)
}

render_wireframes :: proc(renderer: ^SDL.Renderer, phys: State) {
    for collider in phys.colliders {
        collider.active or_continue

        active_color   : u8 : 240
        inactive_color : u8 = 10 if collider.is_dynamic else 110
        
        red   : u8 = active_color if !collider.has_collision else inactive_color
        green : u8 = active_color if collider.has_collision  else inactive_color
        blue  : u8 = 40 if collider.is_dynamic else 110

        SDL.SetRenderDrawColor(renderer, red, green, blue, 255)
        
        rect := collider.area
        SDL.RenderRect(renderer, &rect)
    }
}

reserve_dynamic_collider :: proc(phys: ^State) -> ^Collider {
    if phys.dynamic_collider_count >= DynamicColliderCap {
        log.app_error("unable to reserve dynamic collider: max capacity reached!")
        return nil
    }

    collider := &phys.colliders[phys.dynamic_collider_count]
    phys.dynamic_collider_count += 1

    return collider
}

reserve_static_collider :: proc(phys: ^State) -> ^Collider {
    if phys.static_collider_count >= StaticColliderCap {
        log.physics_error("unable to reserve static collider: max capacity reached!")
        return nil
    }

    collider := &phys.colliders[DynamicColliderCap + phys.static_collider_count]
    phys.static_collider_count += 1

    return collider
}
