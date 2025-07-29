package game

import "../engine"
import "../engine/collider/aabb"
import "../engine/gfx"
import "../engine/log"

import SDL "vendor:sdl3"

PlayerWireframeColor : [4]u8 : { 150, 100, 200, 255 }

MoveDirection :: enum i32 {
    NONE  = 0,
    NORTH = 1,
    WEST  = 2,
    SOUTH = 3,
    EAST  = 4,
}

MoveVectors :: [MoveDirection]engine.vec2i {
    .NONE = engine.vec2i_ZERO,
    .NORTH = engine.vec2i_UP,
    .WEST = engine.vec2i_LEFT,
    .SOUTH = engine.vec2i_DOWN,
    .EAST = engine.vec2i_RIGHT,
}

direction_is_opposite_of :: proc(dir, other: MoveDirection) -> bool {
    if dir == .NONE || other == .NONE do return false 

    if int(dir) % 2 == 0 && int(other) % 2 == 0 do return true
    if int(dir) % 2 != 0 && int(other) % 2 != 0 do return true

    return false
}

opposite_direction :: proc(dir: MoveDirection) -> MoveDirection {
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
    position: engine.vec2i,
    prev_position: engine.vec2i,
    speed: i32,
    directions: [4]MoveDirection,
    active_direction_count: i32,

    forward: MoveDirection,

    should_shoot: bool,

    texture: ^SDL.Texture,
    rendering: bool,

    collider: aabb.AABB,
    tile_x, tile_y: i32,
}


create_player :: proc(estate: ^engine.State) -> (player: Player) {
    player.position = engine.get_position_from_level_tile_coord(estate.level, 6, 12)
    player.prev_position = player.position
    player.rendering = true
    player.speed = 2
    player.forward = .NORTH

    if texture, ok := gfx.create_texture_from_image(estate.renderer, "resources/player.bmp"); ok {
        player.texture = texture
    } else {
        log.render_warn("falling back to solid color player texture")
        texture, ok := gfx.create_solid_texture(estate.renderer, { 16, 16 }, { 255, 0, 255, 255 })
        player.texture = texture
        if !ok {
            log.render_panic("failed to load/generate player texture")
        }
    }

    player.collider = aabb.create_aabb(get_player_rect(player))

    return
}

cleanup_player :: proc(player: ^Player) {
    SDL.DestroyTexture(player.texture)
}

get_player_rect :: proc(player: Player) -> SDL.Rect {
    return {
        x = player.position.x, y = player.position.y,
        w = player.texture.w, h = player.texture.h
    }
}

get_player_rect_float :: proc(player: Player) -> SDL.FRect {
    return {
        x = f32(player.position.x), y = f32(player.position.y),
        w = f32(player.texture.w), h = f32(player.texture.h)
    }
}

does_player_handle :: proc(event: SDL.Event) -> bool {
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
get_keyboard_move_direction :: proc(event: SDL.KeyboardEvent) -> MoveDirection {
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

handle_player_input :: proc(gstate: ^State, event: SDL.Event) {
    if event.key.down && !event.key.repeat && event.key.scancode == .SPACE {
        shoot_player_bullet(gstate)
    }

    handle_player_movement(&gstate.player, event)
}

shoot_player_bullet :: proc(gstate: ^State) {
    player := &gstate.player
    dir_vectors := MoveVectors

    adjustment: i32 = engine.TILE_WIDTH / 2
    player_center := player.position + { engine.TILE_WIDTH / 2, engine.TILE_HEIGHT / 2 }
    half_bullet_size := BulletSize / 2 
    spawn_pos := player_center - half_bullet_size + dir_vectors[player.forward] * adjustment

    player.should_shoot = false
    if !spawn_bullet_from_pool(&gstate.bullet_pool, gstate.player.forward, spawn_pos) {
        player.should_shoot = true
    }
}

handle_player_movement :: proc(player: ^Player, event: SDL.Event) {
    // if event.type & (.GAMEPAD_BUTTON_DOWN | .GAMEPAD_BUTTON_UP) != {} {
    //     log.warn("ignoring gamepad input")
    //     return
    // }

    if event.type == .KEY_DOWN && event.key.repeat {
        return
    }

    // get desired move direction from keyboard
    direction := get_keyboard_move_direction(event.key)

    // do nothing if we don't want to change directions
    if (direction == .NONE) {
        return
    }

    if player.active_direction_count > 4 {
        log.input_warn("attempted to use fifth movement direction. how??")
        return
    }

    if event.key.down {
        // log.trace("adding %v to player.directions at index %d", direction, player.active_direction_count)
        player.directions[player.active_direction_count] = direction
        player.forward = direction

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

    if player.active_direction_count > 0 {
        player.forward = player.directions[player.active_direction_count - 1]
    }
}

tick_player :: proc(player: ^Player) {
    if player.active_direction_count > 0 {
        vectors := MoveVectors
        direction := vectors[player.forward]
        player.prev_position = player.position
        player.position += direction * player.speed
    }
}

update_player :: proc(gstate: ^State, player: ^Player, time: ^engine.Time) {
    if player.should_shoot {
        shoot_player_bullet(gstate)
    }

    tile_pos := engine.get_level_tile_coord_from_position(gstate.level^, player.position)
    player.tile_x = tile_pos.x
    player.tile_y = tile_pos.y
}

render_player :: proc(state: ^engine.State, player: ^Player) {
    if !player.rendering {
        return
    }

    rect := get_player_rect_float(player^)
    if !SDL.RenderTexture(state.renderer, player.texture, nil, &rect) {
        log.render_error("failed to render player: {}", SDL.GetError())
    }
}

render_player_wireframe :: proc(state: ^engine.State, player: ^Player) {
    rect := get_player_rect_float(player^)

    SDL.SetRenderDrawColor(
        state.renderer,
        PlayerWireframeColor.r,
        PlayerWireframeColor.g,
        PlayerWireframeColor.b,
        PlayerWireframeColor.a
    )
    if !SDL.RenderRect(state.renderer, &rect) {
        log.render_error("failed to render player wireframe: %s", SDL.GetError())
    }
}
