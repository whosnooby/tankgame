package engine

import log "logging"
import render "renderer"

import SDL "vendor:sdl3"

State :: struct {
    window : ^SDL.Window,
    renderer : ^SDL.Renderer,
    render_target: ^SDL.Texture,
    event : SDL.Event,
    time: Time,

    cvars: [CVars]CVar,
}

SCREEN_WIDTH : i32 : 640
SCREEN_HEIGHT: i32 : 360

create_window :: proc() -> (window: ^SDL.Window, ok: bool) {
    title :: "tankgame"
    flags: SDL.WindowFlags : { .RESIZABLE }

    log.info("creating window (w: %d, h: %d) title: \"%s\" %v",
        SCREEN_WIDTH, SCREEN_HEIGHT, title, flags
    )

    window = SDL.CreateWindow(
        "tankgame",
        SCREEN_WIDTH, SCREEN_HEIGHT,
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

create_render_target :: proc(state: ^State) -> (target: ^SDL.Texture, ok: bool) {
    target, ok = render.create_blank_texture(state.renderer, [2]i32{ SCREEN_WIDTH, SCREEN_HEIGHT })
    if !ok {
        log.panic("failed to create render target texture")
    }

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
    SDL.DestroyTexture(state.render_target)
    SDL.DestroyRenderer(state.renderer)
    SDL.DestroyWindow(state.window)
}