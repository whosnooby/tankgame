package game

import "../engine"
import "../engine/collider/aabb"
import "../engine/gfx"
import "../engine/log"

import "core:math"

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

get_direction_vector :: proc(dir: MoveDirection) -> engine.vec2i {
    vectors := MoveVectors
    return vectors[dir]
}

Player :: struct {
    game_state: ^State,

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


create_player :: proc(gstate: ^State, estate: ^engine.State) -> (player: Player) {
    player.position = engine.get_position_from_level_tile_coord(estate.level, 6, 12)
    player.prev_position = player.position
    player.rendering = true
    player.speed = 1
    player.forward = .NORTH

    player.game_state = gstate

    if texture, ok := gfx.create_texture_from_image(estate.renderer, "resources/player.bmp"); ok {
        player.texture = texture
    } else {
        log.render_warn("falling back to solid color player texture")
        texture, ok := gfx.create_solid_texture(estate.renderer, engine.TileSize, { 255, 0, 255, 255 })
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

get_player_centre_point :: proc(player: Player) -> engine.vec2i {
    return player.position + (engine.vec2i)(engine.HalfTileSize)
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

handle_player_input :: proc(player: ^Player, event: SDL.Event) {
    if event.key.down && !event.key.repeat && event.key.scancode == .SPACE {
        shoot_player_bullet(player)
    }

    handle_player_movement(player, event)
}

shoot_player_bullet :: proc(player: ^Player) {
    dir_vectors := MoveVectors

    adjustment: i32 = engine.TileSize.x / 2
    player_center := player.position + (engine.vec2i)(engine.TileSize / 2)
    half_bullet_size := BulletSize / 2 
    spawn_pos := player_center - half_bullet_size + dir_vectors[player.forward] * adjustment

    player.should_shoot = false
    if !spawn_bullet_from_pool(&player.game_state.bullet_pool, player.forward, spawn_pos) {
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

should_player_move :: proc(player: Player) -> bool {
    return player.active_direction_count > 0
}

move_player :: proc(player: ^Player, forward: engine.vec2i) {
    player.prev_position = player.position
    player.position += forward * player.speed
}

update_tile_has_player :: proc(level: ^engine.Level, x, y: i32, has_player: bool) {
    tile, ok := engine.get_level_tile(level, x, y)
    if ok {
        if has_player {
            tile.flags += { .HAS_PLAYER }
        } else {
            tile.flags -= { .HAS_PLAYER }
        }
    }
}

update_player_tile_4x4 :: proc(level: ^engine.Level, position: engine.vec2i, has_player: bool) {
    tiles_x : f32 = f32(position.x) / f32(engine.TileSize.x)
    tiles_y : f32 = f32(position.y) / f32(engine.TileSize.y)
    tile_left_x := i32(math.floor(tiles_x))
    tile_right_x := i32(math.ceil(tiles_x))
    tile_top_y := i32(math.floor(tiles_y))
    tile_bottom_y := i32(math.ceil(tiles_y))

    update_tile_has_player(level, tile_left_x,  tile_top_y, has_player)
    update_tile_has_player(level, tile_right_x, tile_top_y, has_player)
    update_tile_has_player(level, tile_left_x,  tile_bottom_y, has_player)
    update_tile_has_player(level, tile_right_x, tile_bottom_y, has_player)
}

update_surrounding_player_tiles :: proc(player: Player) {
    level := player.game_state.level 
    update_player_tile_4x4(level, player.prev_position, false)
    update_player_tile_4x4(level, player.position, true)
}

tick_player :: proc(player: ^Player) {
    if should_player_move(player^) {
        move_player(player, get_direction_vector(player.forward))
        update_surrounding_player_tiles(player^)
    }
}

update_player :: proc(player: ^Player, time: ^engine.Time) {
    if player.should_shoot {
        shoot_player_bullet(player)
    }

    tile_pos := engine.get_level_tile_coord_from_position(player.game_state.level^, player.position)
    player.tile_x = tile_pos.x
    player.tile_y = tile_pos.y
}

render_player :: proc(player: Player, renderer: ^SDL.Renderer) {
    if !player.rendering {
        return
    }

    rect := get_player_rect_float(player)
    if !SDL.RenderTexture(renderer, player.texture, nil, &rect) {
        log.render_error("failed to render player: {}", SDL.GetError())
    }
}

render_player_wireframe :: proc(player: Player, renderer: ^SDL.Renderer) {
    rect := get_player_rect_float(player)

    SDL.SetRenderDrawColor(
        renderer,
        PlayerWireframeColor.r,
        PlayerWireframeColor.g,
        PlayerWireframeColor.b,
        PlayerWireframeColor.a
    )

    if !SDL.RenderRect(renderer, &rect) {
        log.render_error("failed to render player wireframe: %s", SDL.GetError())
    }
}
