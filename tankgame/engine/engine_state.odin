package engine

import "collider/aabb"
import "gfx"
import "log"

import SDL "vendor:sdl3"

State :: struct {
    window : ^SDL.Window,
    renderer : ^SDL.Renderer,
    render_target: ^SDL.Texture,
    event : SDL.Event,
    time: Time,

    aabb_pool: aabb.Pool,
    wireframe_mode: enum { NO_WIREFRAME, WIREFRAME, ONLY_WIREFRAME },

    rendering_console: bool,
    console: Console,

    cvar_names: [CVars]string,
    cvars: [CVars]CVar,
}

SCREEN_WIDTH : i32 : 640
SCREEN_HEIGHT: i32 : 360

create_window :: proc() -> (window: ^SDL.Window, ok: bool) {
    title :: "tankgame"
    flags: SDL.WindowFlags : { .RESIZABLE }

    log.video_info("creating window (w: %d, h: %d) title: \"%s\" %v",
        SCREEN_WIDTH, SCREEN_HEIGHT, title, flags
    )

    window = SDL.CreateWindow(
        "tankgame",
        SCREEN_WIDTH*2, SCREEN_HEIGHT*2,
        { .RESIZABLE, },
    )

    ok = window != nil
    if !ok {
        log.video_error("no window L: %s", SDL.GetError())
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
        log.render_error("no renderer L: %s", SDL.GetError())
        return
    }

    query_render_drivers()

    name := SDL.GetRendererName(renderer)
    log.render_info("created renderer: %s", name)

    return
}

create_render_target :: proc(state: ^State) -> (target: ^SDL.Texture, ok: bool) {
    target, ok = gfx.create_blank_texture(state.renderer, [2]i32{ SCREEN_WIDTH, SCREEN_HEIGHT })
    if !ok {
        log.render_panic("failed to create render target texture")
    }

    SDL.SetTextureScaleMode(target, .NEAREST)

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

cleanup_state :: proc(state: ^State) {
    clear_console(&state.console)

    SDL.DestroyTexture(state.render_target)
    SDL.DestroyRenderer(state.renderer)
    SDL.DestroyWindow(state.window)
}