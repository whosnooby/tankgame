package engine

import log "logging"

import SDL "vendor:sdl3"

State :: struct {
    window : ^SDL.Window,
    renderer : ^SDL.Renderer,
    event : SDL.Event,
    time: Time,

    cvars: [CVars]CVar,
}

create_window :: proc() -> (window: ^SDL.Window, ok: bool) {
    title :: "tankgame"
    width :: 1280 / 2
    height :: 720 / 2
    flags: SDL.WindowFlags : { .RESIZABLE }

    log.info("creating window (w: %d, h: %d) title: \"%s\" %v",
        width, height, title, flags
    )

    window = SDL.CreateWindow(
        "tankgame",
        width, height,
        { .RESIZABLE, },
    )

    ok = window != nil
    if !ok {
        log.error("no window L: %s", SDL.GetError())
    }

    return
}

create_renderer :: proc(state: ^State) -> (renderer: ^SDL.Renderer, ok: bool) {
    renderer = SDL.CreateRenderer(
        state.window,
        nil,
    )

    ok = renderer != nil
    if !ok {
        log.error("no renderer L: %s", SDL.GetError())
        return
    }

    query_render_drivers()

    name := SDL.GetRendererName(renderer)
    log.info("created renderer: %s", name)

    return
}

query_render_drivers :: proc() {
    count := SDL.GetNumRenderDrivers()
    log.info("querying render drivers (found %d):", count)

    for i in 0..<count {
        driver_name := SDL.GetRenderDriver(i)

        log.log("  - driver %d: %s", i, driver_name)
    }
}

cleanup_state :: proc(state: ^State) {
    SDL.DestroyRenderer(state.renderer)
    SDL.DestroyWindow(state.window)
}