package game

import engine "../engine"
import log "../engine/logging"

import SDL "vendor:sdl3"

import math "core:math"

main_loop :: proc(estate: ^engine.State, gstate: ^State) {
    for {
        using estate
        using gstate

        for SDL.PollEvent(&event) {
            #partial switch event.type {
                case .QUIT:
                    return
            }

            if does_player_handle(&event) {
                handle_player_movement(&player, &event)
            }
        }

        engine.time_frame(&estate.time)

        SDL.RenderClear(renderer)

        update_player(&player, &estate.time)
        render_player(estate, &player)

        SDL.RenderPresent(renderer)
    }
}