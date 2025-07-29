package game

import "../engine"
import "../engine/collider/aabb"
import "../engine/log"

import "core:math"

import SDL "vendor:sdl3"

start_render :: proc(estate: ^engine.State) {
    SDL.SetRenderDrawColor(estate.renderer, 0, 0, 0, 255)
    SDL.RenderClear(estate.renderer)
}

render_game_level :: proc(estate: ^engine.State, gstate: ^State) {
    SDL.SetRenderTarget(estate.renderer, estate.level.render_target)

    SDL.SetRenderDrawColor(estate.renderer, 100, 0, 100, 255)
    SDL.RenderClear(estate.renderer)

    if estate.wireframe_mode != .ONLY_WIREFRAME {
        render_state(gstate, estate)
    }

    if estate.wireframe_mode != .NO_WIREFRAME {
        engine.render_level_grid_lines(estate.level, estate.renderer)
        render_state_wireframes(gstate, estate) 
    }
}

render_game_to_window :: proc(estate: ^engine.State) {
    SDL.SetRenderTarget(estate.renderer, nil)

    draw_width, draw_height: i32
    SDL.GetRenderOutputSize(estate.renderer, &draw_width, &draw_height)
    engine.update_level_render_area(&estate.level, draw_width, draw_height)

    SDL.SetRenderDrawColor(estate.renderer, 255, 255, 255, 255)
    SDL.RenderTexture(estate.renderer, estate.level.render_target, nil, &estate.level.render_area)
}

end_render :: proc(estate: ^engine.State) {
    SDL.RenderPresent(estate.renderer)
}

create_game :: proc(estate: ^engine.State, gstate: ^State) {
    if ok := SDL.Init({ .VIDEO, }); !ok {
        log.app_panic("no SDL, major L")
        return
    }

    estate.time = engine.init_time(64)
    estate.wireframe_mode = .WIREFRAME

    SDL.SetLogOutputFunction(log.logfn, nil)
    SDL.SetLogPriorities(.TRACE)

    if window, ok := engine.create_window(); ok {
        estate.window = window
    } else {
        return
    }

    if renderer, ok := engine.create_renderer(estate); ok {
        estate.renderer = renderer
    } else {
        return
    }

    if level, ok := engine.create_level(13, 13, engine.WindowWidth, engine.WindowHeight, estate.renderer); ok {
        estate.level = level
        gstate.level = &estate.level
    } else {
        return
    }

    init_game_state(gstate, estate)
}

main_loop :: proc(estate: ^engine.State, gstate: ^State) {
    for {
        using estate

        for SDL.PollEvent(&event) {
            #partial switch event.type {
                case .WINDOW_RESIZED:
                    log.video_trace(
                        "window resized to %dx%d",
                        event.window.data1, event.window.data2
                    )
                case .QUIT:
                    return
            }

            if does_player_handle(event) {
                handle_player_input(gstate, event)
            }
        }

        engine.time_previous_frame(&time)

        SDL.RenderClear(renderer)

        engine.prepare_to_tick(&time)
        for engine.should_tick(&time) {
            tick_state(gstate)
        }
        engine.stop_ticking(&time)

        update_state(gstate, &time)

        start_render(estate)

        render_game_level(estate, gstate)
        render_game_to_window(estate)

        render_game_debug_text(gstate, estate.renderer)
        engine.render_engine_debug_text(estate)

        end_render(estate)
    }
}