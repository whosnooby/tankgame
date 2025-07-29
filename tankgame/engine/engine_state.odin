package engine

import "collider/aabb"
import "gfx"
import "log"

import SDL "vendor:sdl3"

State :: struct {
    window : ^SDL.Window,
    renderer : ^SDL.Renderer,
    event : SDL.Event,
    time: Time,
    level: Level,

    wireframe_mode: enum { NO_WIREFRAME, WIREFRAME, ONLY_WIREFRAME },
}

WINDOW_WIDTH : i32 : 1280
WINDOW_HEIGHT: i32 : 720

create_window :: proc() -> (window: ^SDL.Window, ok: bool) {
    title :: "tankgame"
    flags: SDL.WindowFlags : { .RESIZABLE }

    log.video_info("creating window (w: %d, h: %d) title: \"%s\" %v",
        WINDOW_WIDTH, WINDOW_HEIGHT, title, flags
    )

    window = SDL.CreateWindow(
        "tankgame",
        WINDOW_WIDTH, WINDOW_HEIGHT,
        { .RESIZABLE, },
    )

    ok = window != nil
    if !ok {
        log.video_error("no window L: %s", SDL.GetError())
    }

    return
}

create_renderer :: proc(state: ^State) -> (renderer: ^SDL.Renderer, ok: bool) {
    query_render_drivers()

    renderer = SDL.CreateRenderer(
        state.window,
        nil,
    )

    ok = renderer != nil
    if !ok {
        log.render_error("no renderer L: %s", SDL.GetError())
        return
    }

    return
}

query_render_drivers :: proc() {
    count := SDL.GetNumRenderDrivers()
    log.render_info("querying render drivers (found %d):", count)

    for i in 0..<count {
        driver_name := SDL.GetRenderDriver(i)

        log.render_info("  - driver %d: %s", i, driver_name)
    }
}

render_engine_debug_text :: proc(state: ^State) {
    line_h : i32 : 12
    line_x := state.level.render_area.x + state.level.render_area.w + 2.0
    line_y :: proc(n: i32) -> f32 {
        return f32(2 + line_h * n)
    }

    SDL.SetRenderTarget(state.renderer, nil)
    SDL.SetRenderDrawColor(state.renderer, 255, 255, 255, 255)

    SDL.RenderDebugTextFormat(
        state.renderer,
        line_x, line_y(0),
        "lvl render area: (%.0f, %.0f) @ %.0fx%.0f",
        state.level.render_area.x, state.level.render_area.y,
        state.level.render_area.w, state.level.render_area.h
    )
}

cleanup_state :: proc(state: ^State) {
    cleanup_level(&state.level)
    SDL.DestroyRenderer(state.renderer)
    SDL.DestroyWindow(state.window)
}