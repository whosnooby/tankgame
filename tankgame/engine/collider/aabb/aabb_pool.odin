package aabb

import log "../../logging"

import SDL "vendor:sdl3"

PoolCap :: 512

Pool :: struct {
    aabbs: [PoolCap]AABB,
    count: uint,
}

get_aabb_from_pool :: proc(pool: ^Pool) -> ^AABB {
    if pool.count >= PoolCap {
        log.physics_error("unable to get AABB collider: max capacity reached!")
        return nil
    }

    aabb := &pool.aabbs[pool.count]
    pool.count += 1

    return aabb
}

// checks for intersections among the AABBs in the pool.
check_pool_intersections :: proc(pool: ^Pool) {
    for i1 := 0; i1 < PoolCap; i1 += 1 {
        aabb1 := &pool.aabbs[i1] 
        aabb1.active or_continue

        for i2 := i1 + 1; i2 < PoolCap; i2 += 1 {
            aabb2 := &pool.aabbs[i2]
            aabb2.active or_continue

            does_intersect := intersects(aabb1^, aabb2^)

            aabb1.is_intersecting = does_intersect
            aabb2.is_intersecting = does_intersect
            aabb1.intersecting_box = aabb2 if does_intersect else nil
            aabb2.intersecting_box = aabb1 if does_intersect else nil
        }
    } 
}

render_wireframes :: proc(renderer: ^SDL.Renderer, pool: Pool) {
    for aabb, idx in pool.aabbs {
        aabb.active or_continue
        (uint(idx) < pool.count) or_break

        active_color   : u8 : 240
        inactive_color : u8 = 10
        
        red   : u8 = active_color if !aabb.is_intersecting else inactive_color
        green : u8 = active_color if aabb.is_intersecting  else inactive_color
        blue  : u8 = 40

        SDL.SetRenderDrawColor(renderer, red, green, blue, 255)
        
        rect := aabb.area
        SDL.RenderRect(renderer, &rect)
    }
}
