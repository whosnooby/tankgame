package game

import engine "../engine"
import log "../engine/logging"
import renderer "../engine/renderer"

import SDL "vendor:sdl3"

PlayerMoveDirection :: enum {
    NONE  = 0,
    NORTH = 1,
    WEST  = 2,
    SOUTH = 3,
    EAST  = 4,
}

PlayerMoveVectors :: [PlayerMoveDirection]engine.vec2 {
    .NONE = engine.vec2_ZERO,
    .NORTH = engine.vec2_UP,
    .WEST = engine.vec2_LEFT,
    .SOUTH = engine.vec2_DOWN,
    .EAST = engine.vec2_RIGHT,
}

direction_is_opposite_of :: proc(dir, other: PlayerMoveDirection) -> bool {
    if dir == .NONE || other == .NONE do return false 

    if int(dir) % 2 == 0 && int(other) % 2 == 0 do return true
    if int(dir) % 2 != 0 && int(other) % 2 != 0 do return true

    return false
}

direction_opposite :: proc(dir: PlayerMoveDirection) -> PlayerMoveDirection {
    switch dir {
        case .NORTH: return .SOUTH
        case .WEST:  return .EAST
        case .SOUTH: return .NORTH
        case .EAST:  return .WEST

        case .NONE: fallthrough
        case: return .NONE
    }
}

Player :: struct {
    position: engine.vec2,
    speed: f32,
    directions: [4]PlayerMoveDirection,
    active_direction_count: int,
    

    texture: ^SDL.Texture,
    rendering: bool,
}


create_player :: proc(estate: ^engine.State) -> (player: Player) {
    player.position = { 100, 100 }
    player.rendering = true
    player.speed = 100.0

    if texture, ok := renderer.create_texture_from_image(estate.renderer, "resources/player.bmp"); ok {
        player.texture = texture
    } else {
        log.warn("falling back to solid color player texture")
        texture, ok := renderer.create_solid_texture(estate.renderer, { 16, 16 }, { 255, 0, 255, 255 })
        player.texture = texture
        if !ok {
            log.panic("failed to load/generate player texture")
        }
    }
    return
}

cleanup_player :: proc(player: ^Player) {
    SDL.DestroyTexture(player.texture)
}

get_player_rect :: proc(player: ^Player) -> SDL.FRect {
    return {
        x = f32(player.position.x), y = f32(player.position.y),
        w = f32(player.texture.w), h = f32(player.texture.h)
    }
}

does_player_handle :: proc(event: ^SDL.Event) -> bool {
    #partial switch event.type {
        case .KEY_DOWN:
            return true
        case .KEY_UP:
            return true
        // case .GAMEPAD_BUTTON_DOWN:
        //     return true
        // case .GAMEPAD_BUTTON_UP:
        //     return true
        case:
            return false
    }
}

@(private="file")
get_keyboard_move_direction :: proc(event: ^SDL.KeyboardEvent) -> PlayerMoveDirection {
    #partial switch event.scancode {
        case .W:
            return .NORTH
        case .A:
            return .WEST
        case .S:
            return .SOUTH
        case .D:
            return .EAST
        case:
            return .NONE
    }
}

handle_player_movement :: proc(player: ^Player, event: ^SDL.Event) {
    // if event.type & (.GAMEPAD_BUTTON_DOWN | .GAMEPAD_BUTTON_UP) != {} {
    //     log.warn("ignoring gamepad input")
    //     return
    // }

    if event.type == .KEY_DOWN && event.key.repeat {
        return
    }

    // get desired move direction from keyboard
    direction := get_keyboard_move_direction(&event.key)

    // do nothing if we don't want to change directions
    if (direction == .NONE) {
        return
    }

    if player.active_direction_count > 4 {
        log.warn("attempted to use fifth movement direction. how??")
        return
    }

    if event.key.down {
        // log.trace("adding %v to player.directions at index %d", direction, player.active_direction_count)
        player.directions[player.active_direction_count] = direction

        player.active_direction_count += 1

        return
    }

    // key released

    released_idx : int = 4
    for &dir, idx in player.directions {
        if dir == direction {
            // log.trace("removing %v from player.directions at index %d", dir, idx)
            dir = .NONE
            released_idx = idx
        }

        if idx > released_idx {
            // log.trace("...moving %v down from %d to %d", dir, idx, idx - 1)
            player.directions[idx - 1] = dir
        }
    }
    // log.trace(" player.directions: %v", player.directions)
    player.active_direction_count -= 1
}

tick_player :: proc(player: ^Player) {

}

update_player :: proc(player: ^Player, time: ^engine.Time) {
    if player.active_direction_count == 0 {
        return
    }
    vectors := PlayerMoveVectors
    direction := vectors[player.directions[player.active_direction_count - 1]]
    player.position += direction * player.speed * time.delta_seconds
}

render_player :: proc(state: ^engine.State, player: ^Player) {
    if !player.rendering {
        return
    }

    rect := get_player_rect(player)
    if !SDL.RenderTexture(state.renderer, player.texture, nil, &rect) {
        log.error("failed to render player: %s", SDL.GetError())
    }
}