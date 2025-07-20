package engine

import "core:math"

vec2 :: distinct [2]f32
vec3 :: distinct [3]f32
vec4 :: distinct [4]f32

vec2i :: distinct [2]i32
vec3i :: distinct [3]i32
vec4i :: distinct [4]i32

vec2_ZERO  : vec2 : { +0.0, +0.0 }
vec2_ONE   : vec2 : { +1.0, +1.0 }
vec2_UP    : vec2 : { +0.0, -1.0 }
vec2_DOWN  : vec2 : { +0.0, +1.0 }
vec2_LEFT  : vec2 : { -1.0, +0.0 }
vec2_RIGHT : vec2 : { +1.0, +0.0 }
vec2i_ZERO  : vec2i : { +0, +0 }
vec2i_ONE   : vec2i : { +1, +1 }
vec2i_UP    : vec2i : { +0, -1 }
vec2i_DOWN  : vec2i : { +0, +1 }
vec2i_LEFT  : vec2i : { -1, +0 }
vec2i_RIGHT : vec2i : { +1, +0 }

vec3_ZERO     : vec3 : { +0.0, +0.0, +0.0 }
vec3_ONE      : vec3 : { +1.0, +1.0, +1.0 }
vec3_UP       : vec3 : { +0.0, -1.0, +0.0 }
vec3_DOWN     : vec3 : { +0.0, +1.0, +0.0 }
vec3_LEFT     : vec3 : { -1.0, +0.0, +0.0 }
vec3_RIGHT    : vec3 : { +1.0, +0.0, +0.0 }
vec3_FORWARD  : vec3 : { +0.0, +0.0, +1.0 }
vec3_BACK     : vec3 : { +0.0, +0.0, -1.0 }
vec3i_ZERO     : vec3 : { +0, +0, +0 }
vec3i_ONE      : vec3 : { +1, +1, +1 }
vec3i_UP       : vec3 : { +0, -1, +0 }
vec3i_DOWN     : vec3 : { +0, +1, +0 }
vec3i_LEFT     : vec3 : { -1, +0, +0 }
vec3i_RIGHT    : vec3 : { +1, +0, +0 }
vec3i_FORWARD  : vec3 : { +0, +0, +1 }
vec3i_BACK     : vec3 : { +0, +0, -1 }

vec2_length :: proc(v: vec2) -> f32 {
    return math.sqrt(v.x*v.x + v.y*v.y)
}
vec2i_length :: proc(v: vec2i) -> f32 {
    return math.sqrt(f32(v.x*v.x + v.y*v.y))
}

vec2_normalize :: proc(v: vec2) -> vec2 {
    length := vec2_length(v)
    if length == 0.0 do return vec2_ZERO
    return v / length
}

vec2i_normalize :: proc(v: vec2i) -> vec2i {
    length := vec2i_length(v)
    return { i32(f32(v.x) / length), i32(f32(v.y) / length) }
}

vec3_length :: proc(v: vec3) -> f32 {
    return math.sqrt(v.x*v.x + v.y*v.y + v.z*v.z)
}
vec3i_length :: proc(v: vec3i) -> f32 {
    return math.sqrt(f32(v.x*v.x + v.y*v.y + v.z*v.z))
}

vec3_normalize :: proc(v: vec3) -> vec3 {
    length := vec3_length(v)
    if length == 0.0 do return vec3_ZERO
    return v / length
}

vec3i_normalize :: proc(v: vec3i) -> vec3i {
    length := vec3i_length(v)
    return { i32(f32(v.x) / length), i32(f32(v.y) / length), i32(f32(v.z) / length) }
}
