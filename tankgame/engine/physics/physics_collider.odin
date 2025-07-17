package physics

import "core:math"
import SDL "vendor:sdl3"

Collision :: struct {
    other: ^Collider,
}

Collider :: struct {
    active: bool,
    is_trigger: bool,
    is_dynamic: bool,
    has_collision: bool,
    collision: Collision,

    area: SDL.FRect,

    colcheck_data: CollisionCheckerData,
}

CollisionCheckerData :: struct {
    center: SDL.FPoint,
    bounding_radius: f32, 

    might_have_collision: bool
}

collider_might_intersect :: proc(a: Collider, b: Collider) -> bool {
    radius_sum := a.colcheck_data.bounding_radius + b.colcheck_data.bounding_radius
    difference := a.colcheck_data.center - b.colcheck_data.center
    distance := math.sqrt(difference.x*difference.x + difference.y*difference.y)

    return distance <= radius_sum
}

collider_intersects_area :: proc(c: Collider, area: SDL.FRect) -> bool {
    // return (abs((a.min.x + a.max.x/2) - (min.x + max.x/2)) * 2 < (a.max.x + max.x)) &&
    //        (abs((a.min.y + a.max.y/2) - (min.y + max.y/2)) * 2 < (a.max.y + max.y))
    return SDL.HasRectIntersectionFloat(c.area, area)
}

collider_intersects_collider :: proc(a: Collider, b: Collider) -> bool {
    return SDL.HasRectIntersectionFloat(a.area, b.area)
}

collider_intersects :: proc {
    collider_intersects_area,
    collider_intersects_collider,
}

collision_checker_data_create :: proc(area: SDL.FRect) -> (data: CollisionCheckerData) {
    area_center : SDL.FPoint = { area.x + area.w * 0.5, area.y + area.h * 0.5 }
    rect_width := area.w - area.x
    rect_height := area.h - area.y

    diagonal := math.sqrt(rect_width*rect_width + rect_height*rect_height)

    data.center = area_center
    data.bounding_radius = diagonal * 0.5
    data.might_have_collision = false

    return data
}

collider_init :: proc(col: ^Collider, area: SDL.FRect, is_dynamic := false, is_trigger := false) {
    col.active = true
    col.area = area

    col.is_trigger = is_trigger
    col.is_dynamic = is_dynamic
    col.has_collision = false
    col.collision.other = nil

    col.colcheck_data = collision_checker_data_create(area)
}

collider_init_static :: proc(col: ^Collider, area: SDL.FRect) {
    collider_init(col, area, is_dynamic = false, is_trigger = false)
}

collider_init_dynamic :: proc(col: ^Collider, area: SDL.FRect) {
    collider_init(col, area, is_dynamic = true, is_trigger = false)
}

collider_init_trigger :: proc(col: ^Collider, area: SDL.FRect) {
    collider_init(col, area, is_dynamic = false, is_trigger = true)
}

collider_update_dynamic :: proc(col: ^Collider, area: SDL.FRect) {
    col.area = area
    col.colcheck_data = collision_checker_data_create(area)
}
