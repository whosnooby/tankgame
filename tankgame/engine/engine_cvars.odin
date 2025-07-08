package engine

import log "logging"

import "core:fmt"
import "core:reflect"

// this system is inspired by Valve's CVar system

CVarChangeCallback :: #type proc(^State, ^CVar)

CVar :: struct {
    name: string,
    value: any,
    value_type: typeid,
    on_change: CVarChangeCallback,
}

CVars :: enum {
    SV_TICKRATE,

    SV_PLAYER_SPEED,
}

initialize_engine_cvars :: proc(state: ^State) -> ^State {
    state.cvars[.SV_TICKRATE] = construct_cvar(
        "sv_tickrate",
        state.time.tick_rate,
        time_update_tick_rate
    ) 

    return state
}

setup_game_cvar :: proc(state: ^State, cvar: CVars, value: CVar) -> ^State {
    state.cvars[cvar] = value

    return state
}

construct_cvar :: proc(
    name: string, value: any, on_change: CVarChangeCallback
) -> CVar {
    _, id := reflect.any_data(value)
    return {
        name = name,
        value = value,
        value_type = id,
        on_change = on_change
    }
}

print_cvars :: proc(state: ^State, message_format: cstring = nil, message_args: ..any) {
    if message_format != nil {
        log.trace(string(message_format), ..message_args)
    }

    for cvar in state.cvars {
        log.trace("  %s = %s(%v)", cvar.name, cvar.value_type, cvar.value)
    }
}

set_cvar_value :: proc(state: ^State, cvar: CVars, value: any) {
    var := &state.cvars[cvar]
    var.value = value
    if var.on_change != nil do var.on_change(state, var)
}

get_cvar_value :: proc(state: ^State, cvar: CVars, $T: typeid) -> (T, bool) {
    value := &state.cvars[cvar].value

    switch $T {
        case bool:
            return reflect.as_bool(value^)
        case []byte:
            return reflect.as_bytes(value^), true
        case f32:
            val, ok := reflect.as_f64(value^)
            return f32(val), ok
        case f64:
            return reflect.as_f64(value^)
        case i32:
            val, ok := reflect.as_int(value^)
            return i32(val), ok
        case i64:
            return reflect.as_i64(value^)
        case int:
            return reflect.as_int(value^)
        case rawptr:
            return reflect.as_pointer(value^)
        case string:
            return reflect.as_string(value^)
        case u32:
            val, ok := reflect.as_uint(value^)
            return u32(val), ok
        case u64:
            return reflect.as_u64(value^)
        case uint:
            return reflect.as_uint(value^)
    }
}