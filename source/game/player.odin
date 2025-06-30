package game

import engine "../engine"
import log "../engine/logging"
import renderer "../engine/renderer"

import SDL "vendor:sdl3"

Player :: struct {
    position: engine.vec2i,
    texture: ^SDL.Texture,
    rendering: bool,
}


create_player :: proc(state: ^engine.State) -> (player: Player) {
    player.position = { 100, 100 }
    player.rendering = true

    if texture, ok := renderer.create_texture_from_image(state, "resources/player.bmp"); ok {
        player.texture = texture
    } else {
        log.warn("falling back to solid color player texture")
        texture, ok := renderer.create_solid_texture(state, { 16, 16 }, { 255, 0, 255, 255 })
        if !ok {
            log.panic("failed to load/generate player texture")
        }
        player.texture = texture
    }
    return
}

get_player_rect :: proc(player: ^Player) -> SDL.FRect {
    return {
        x = f32(player.position.x), y = f32(player.position.y),
        w = 16, h = 16
    }
}

render_player :: proc(state: ^engine.State, player: ^Player) {
    rect := get_player_rect(player)
    if !SDL.RenderTexture(state.renderer, player.texture, nil, &rect) {
        log.error("failed to render player: %s", SDL.GetError())
    }
}