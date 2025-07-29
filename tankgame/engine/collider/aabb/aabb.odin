package aabb

import SDL "vendor:sdl3"

AABB :: struct {
    area: SDL.Rect,
    intersects: ^AABB,
}

create_aabb :: proc(area: SDL.Rect) -> (aabb: AABB) {
    aabb.area = area
    return 
}

is_aabb_active :: proc(aabb: AABB) -> bool {
    return aabb.area.w > 0 && aabb.area.h > 0
}

intersects_area :: proc(aabb: AABB, area: SDL.Rect) -> (bool, SDL.Rect) {
    intersection: SDL.Rect
    return SDL.GetRectIntersection(aabb.area, area, &intersection), intersection
}

intersects_aabb :: proc(a: AABB, b: AABB) -> (bool, SDL.Rect) {
    intersection: SDL.Rect
    return SDL.GetRectIntersection(a.area, b.area, &intersection), intersection
}

intersects :: proc {
    intersects_area,
    intersects_aabb,
}
