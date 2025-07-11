package engine

import log "logging"

import "core:fmt"
import "core:reflect"

// this system is inspired by Valve's CVar system

CVarChangeCallback :: #type proc(^State, ^CVar)
CVarValue :: union {
    ^uint,
    ^f32,
    ^string,
}

CVar :: struct {
    name: string,
    value: CVarValue,
    value_type: typeid,
    on_change: CVarChangeCallback,
}

CVars :: enum {
    SV_TICKRATE,

    SV_PLAYER_SPEED,
}

initialize_engine_cvars :: proc(state: ^State) -> ^State {
    append_cvar(
        state, .SV_TICKRATE,
        "sv_tickrate",
        &state.time.tick_rate,
        time_update_tick_rate
    ) 

    return state
}

append_cvar :: proc(
    state: ^State, cvar: CVars,
    name: string, value: CVarValue, on_change: CVarChangeCallback
) -> ^CVar {
    state.cvar_names[cvar] = name

    value_type := reflect.union_variant_typeid(value)

    state.cvars[cvar] = {
        name = state.cvar_names[cvar],
        value = value,
        value_type = value_type,
        on_change = on_change
    }

    return &state.cvars[cvar]
}

print_cvars :: proc(state: ^State, message_format: cstring = nil, message_args: ..any) {
    if message_format != nil {
        log.console_trace(string(message_format), ..message_args)
    }

    for cvar in state.cvars {
        value, ok := get_cvar_value_as_any(cvar)
        if !ok do log.console_trace("  %s = ???", cvar.name)
        else do log.console_trace("  %s = %v", cvar.name, value)
    }
}

set_cvar_value :: proc(state: ^State, cvar: CVars, value: CVarValue) {
    var := &state.cvars[cvar]
    var.value = value

    if var.on_change != nil do var.on_change(state, var)
}

get_cvar_value_from_state :: proc(state: ^State, cvar: CVars) -> (any, bool) {
    return get_cvar_value_as_any(state.cvars[cvar])
}

get_cvar_value_as_any :: proc(cvar: CVar) -> (any, bool) {
    switch value in cvar.value {
        case ^uint:
            return value^, true
        case ^f32:
            return value^, true
        case ^string:
            return value^, true
        case:
            return nil, false
    }
}