package game

import "../engine"
import "../engine/collider/aabb"
import log "../engine/logging"

import "core:math"

import SDL "vendor:sdl3"

render_game_to_target :: proc(estate: ^engine.State, gstate: ^State) {
    SDL.SetRenderTarget(estate.renderer, estate.render_target)

    SDL.SetRenderDrawColor(estate.renderer, 0, 0, 0, 255)
    SDL.RenderClear(estate.renderer)

    if estate.wireframe_mode != .ONLY_WIREFRAME {
        render_state(gstate, estate)
    }

    if estate.wireframe_mode != .NO_WIREFRAME {
        aabb.render_wireframes(estate.renderer, estate.aabb_pool)
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

create_game :: proc(estate: ^engine.State, gstate: ^State) {
    if ok := SDL.Init({ .VIDEO, }); !ok {
        log.app_panic("no SDL, major L")
        return
    }

    estate.time = engine.init_time(64)
    estate.wireframe_mode = .WIREFRAME

    SDL.SetLogOutputFunction(engine.console_logfn, &estate.console)
    SDL.SetLogPriorities(.TRACE)

    if console, ok := engine.create_console(estate); ok {
        estate.console = console
    } else {
        log.app_panic("failed to create console")
        return
    }

    if window, ok := engine.create_window(); ok {
        estate.window = window
    } else {
        return
    }

    engine.resize_console(estate)

    if renderer, ok := engine.create_renderer(estate); ok {
        estate.renderer = renderer
    } else {
        return
    }
    engine.create_console_text_engine(estate)

    if target, ok := engine.create_render_target(estate); ok {
        estate.render_target = target
    } else {
        return
    }

    init_game_state(gstate, estate)

    engine.initialize_engine_cvars(estate)
    add_game_cvars(estate, gstate)

    engine.print_cvars(estate, "initialized cvars:")
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

        engine.time_previous_frame(&time)

        SDL.RenderClear(renderer)

        engine.prepare_to_tick(&time)
        for engine.should_tick(&time) {
            update_dynamic_colliders(gstate)
            aabb.check_pool_intersections(&aabb_pool)

            tick_state(gstate)
        }
        engine.stop_ticking(&time)

        update_state(gstate, &time)

        render_game_to_target(estate, gstate)
        render_game_to_window(estate)
    }
}