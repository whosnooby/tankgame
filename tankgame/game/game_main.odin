package game

import engine "../engine"
import log "../engine/logging"
import phys "../engine/physics"

import SDL "vendor:sdl3"

import math "core:math"

render_game_to_target :: proc(estate: ^engine.State, gstate: ^State) {
    SDL.SetRenderTarget(estate.renderer, estate.render_target)

    SDL.SetRenderDrawColor(estate.renderer, 0, 0, 0, 255)
    SDL.RenderClear(estate.renderer)

    if estate.wireframe_mode != .ONLY_WIREFRAME {
        game_render(gstate, estate)
    }

    if estate.wireframe_mode != .NO_WIREFRAME {
        phys.render_wireframes(estate.renderer, estate.physics_state)
    }
}

render_game_to_window :: proc(estate: ^engine.State) {
    SDL.SetRenderTarget(estate.renderer, nil)

    SDL.SetRenderDrawColor(estate.renderer, 0, 0, 0, 255)
    SDL.RenderClear(estate.renderer)

    draw_width, draw_height: i32
    SDL.GetRenderOutputSize(estate.renderer, &draw_width, &draw_height)

    // code from:
    // https://blog.roboblob.com/2013/07/27/solving-resolution-independent-rendering-and-2d-camera-using-monogame/

    targetAspectRatio := f32(engine.SCREEN_WIDTH) / f32(engine.SCREEN_HEIGHT);
    width := draw_width
    height := i32(f32(width) / targetAspectRatio + 0.5);
    if (height > draw_height) {
        height = draw_height;
        width = i32(f32(height) * targetAspectRatio + 0.5);
    }

    dstrect: SDL.FRect = {
        x = f32(draw_width / 2) - f32(width / 2),
        y = f32(draw_height / 2) - f32(height / 2),
        w = f32(width),
        h = f32(height)
    };

    SDL.RenderTexture(estate.renderer, estate.render_target, nil, &dstrect)
    SDL.RenderPresent(estate.renderer)
}

main_loop :: proc(estate: ^engine.State, gstate: ^State) {
    for {
        using estate
        using gstate

        for SDL.PollEvent(&event) {
            #partial switch event.type {
                case .WINDOW_EXPOSED:
                    if event.window.data1 == 1 {
                        log.render_trace("redrawing render target to fit new size")
                        render_game_to_window(estate)
                    }
                case .QUIT:
                    return
            }

            if does_player_handle(event) {
                handle_player_input(gstate, event)
            }
        }

        engine.time_frame(&time)

        SDL.RenderClear(renderer)

        time = engine.time_start_ticks(&time)^
        for engine.time_tick(&time) {
            game_prepare_physics(gstate)

            phys.tick(&physics_state)
            game_tick(gstate)
        }
        time = engine.time_end_ticks(&time)^

        game_update(gstate, &time)

        render_game_to_target(estate, gstate)
        render_game_to_window(estate)
    }
}