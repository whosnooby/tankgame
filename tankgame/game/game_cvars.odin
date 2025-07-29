package game

import "../engine"

import SDL "vendor:sdl3"

add_game_cvars :: proc(estate: ^engine.State, gstate: ^State) -> ^engine.State {
    engine.append_cvar(
        estate, .SV_PLAYER_SPEED,
        "sv_player_speed",
        &gstate.player.speed,
        nil
    )

    return estate
}