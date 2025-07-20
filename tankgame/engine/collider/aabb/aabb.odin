package aabb

import "core:math"
import SDL "vendor:sdl3"

OnTriggerCallback :: #type proc(trigger: ^AABB, triggerer: ^AABB)

AABB :: struct {
    active: bool,
    is_trigger: bool,
    is_intersecting: bool,
    intersecting_box: ^AABB,
    area: SDL.FRect,

    on_trigger: OnTriggerCallback,
}

// aabb_might_intersect :: proc(a: AABB, b: AABB) -> bool {
//     radius_sum := a.bounding_radius + b.bounding_radius
//     difference := a.center - b.center
//     distance := math.sqrt(difference.x*difference.x + difference.y*difference.y)

//     return distance <= radius_sum
// }

intersects_area :: proc(aabb: AABB, area: SDL.FRect) -> bool {
    return SDL.HasRectIntersectionFloat(aabb.area, area)
}

intersects_aabb :: proc(a: AABB, b: AABB) -> bool {
    return SDL.HasRectIntersectionFloat(a.area, b.area)
}

intersects :: proc {
    intersects_area,
    intersects_aabb,
}

init_aabb :: proc(aabb: ^AABB, area: SDL.FRect, is_trigger := false) {
    aabb.active = true
    aabb.area = area

    aabb.is_trigger = is_trigger
    aabb.is_intersecting = false
    aabb.intersecting_box = nil
}

init_trigger :: proc(aabb: ^AABB, area: SDL.FRect) {
    init_aabb(aabb, area, is_trigger = true)
}

set_aabb_area :: proc(col: ^AABB, area: SDL.FRect) {
    col.area = area
}
