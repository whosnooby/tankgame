package game

import engine "../engine"

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
        }

        // sineWave := SDL.sinf(((f32(SDL.GetTicks() % 3000)) / 3000.0) * 2.0 * math.PI)
        // r := u8(sineWave * 127.0) + 127;
        // SDL.SetRenderDrawColor(renderer, r, 0, 0, 255)

        SDL.RenderClear(renderer)

        render_player(estate, &player)

        SDL.RenderPresent(renderer)
    }
}