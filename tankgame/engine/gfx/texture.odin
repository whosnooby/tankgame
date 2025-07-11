package gfx

import log "../logging"

import SDL "vendor:sdl3"

u32_color_from_rgba :: proc(color: [4]u8) -> (rgba: u32) {
    rgba  = u32(color.r) << 24
    rgba |= u32(color.b) << 16
    rgba |= u32(color.g) << 8
    rgba |= u32(color.a) << 0
    return
}

create_blank_texture :: proc(
    renderer: ^SDL.Renderer,
    size: [2]i32
) -> (
    texture: ^SDL.Texture,
    ok: bool
) {
    log.render_trace("creating empty texture (w: %d, h: %d)", size.x, size.y)
    texture = SDL.CreateTexture(renderer, .RGBA32, .TARGET, size.x, size.y)
    ok = texture != nil
    if !ok {
        log.render_error("failed to create texture: %s", SDL.GetError())
    }
    return
}

create_solid_texture :: proc(
    renderer: ^SDL.Renderer,
    size: [2]i32,
    color: [4]u8
) -> (
    texture: ^SDL.Texture,
    ok: bool
) {
    surface := SDL.CreateSurface(size.x, size.y, .RGBA32)  
    defer SDL.DestroySurface(surface)

    color := u32_color_from_rgba(color)
    SDL.FillSurfaceRect(surface, nil, color)

    log.render_trace("creating solid color texture (w: %d, h: %d) 0x%x",
        size.x, size.y, color 
    )
    texture = SDL.CreateTextureFromSurface(renderer, surface)
    ok = texture != nil
    if !ok {
        log.render_error("failed to create texture: %s", SDL.GetError())
    }
    return
}

create_texture_from_image :: proc(renderer: ^SDL.Renderer, path: cstring) -> (texture: ^SDL.Texture, ok: bool) {
    surface := SDL.LoadBMP(path)  
    defer SDL.DestroySurface(surface)

    ok = surface != nil
    if !ok {
        log.render_error("failed to load image %s: %s", path, SDL.GetError())
        return nil, ok
    }

    log.render_trace("creating texture (w: %d, h: %d) from image %s",
        surface.w, surface.h, path
    )
    texture = SDL.CreateTextureFromSurface(renderer, surface)

    ok = texture != nil
    if !ok {
        log.render_error("failed to create texture: %s", SDL.GetError())
    }
    return
}

create_texture :: proc {
    create_blank_texture,
    create_solid_texture,
    create_texture_from_image,
}