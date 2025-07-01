package game

import engine "../engine"
import log "../engine/logging"

import SDL "vendor:sdl3"

add_game_cvars :: proc(estate: ^engine.State, gstate: ^State) -> ^engine.State {
    engine.setup_game_cvar(estate, .SV_PLAYER_SPEED, {
        name = "sv_player_speed", value = &gstate.player.speed,
        on_change = nil
    })

    return estate
}