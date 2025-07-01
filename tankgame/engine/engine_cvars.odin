package engine

import log "logging"

// this system is inspired by Valve's CVar system

CVar :: struct {
    name: string,
    value: union {
        ^f32,
        ^uint,
        ^string,
    },
    on_change: proc(^State, ^CVar)
}

CVars :: enum {
    SV_TICKRATE,

    SV_PLAYER_SPEED,
}

initialize_engine_cvars :: proc(state: ^State) -> ^State {
    state.cvars[.SV_TICKRATE] = {
        name = "sv_tickrate", value = &state.time.tick_rate,
        on_change = time_update_tick_rate
    }

    return state
}

setup_game_cvar :: proc(state: ^State, cvar: CVars, value: CVar) -> ^State {
    state.cvars[cvar] = value

    return state
}

print_cvars :: proc(state: ^State, message_format: cstring = nil, message_args: ..any) {
    if message_format != nil {
        log.trace(string(message_format), ..message_args)
    }

    for &cvar in state.cvars {
        switch value in cvar.value {
            case ^f32:
                log.log(`  "%s" = %f`, cvar.name, value^)
            case ^uint:
                log.log(`  "%s" = %d`, cvar.name, value^)
            case ^string:
                log.log(`  "%s" = "%s"`, cvar.name, value^)
        }
    }
}