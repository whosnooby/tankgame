package engine

import "gfx"
import "log"

import SDL "vendor:sdl3"

Level :: struct {
    width, height: i32,
    tile_grid: []Tile,
    render_target: ^SDL.Texture,
    render_area: SDL.FRect,
}

LevelGridLineColor : [4]u8 : { 100, 100, 100, 255 }

create_level :: proc(width, height: i32, window_width, window_height: i32, renderer: ^SDL.Renderer) -> (level: Level, ok: bool) {
    level.width = width
    level.height = height
    update_level_render_area(&level, window_width, window_height) 
    if ok = init_level_tile_grid(&level); !ok {
        log.level_panic("failed to allocate level grid")
        return
    }

    if level.render_target, ok = gfx.create_blank_texture(renderer, TileSize * { width, height }); !ok {
        log.input_panic("failed to generate level render target")
        return
    }
    SDL.SetTextureScaleMode(level.render_target, .NEAREST)

    return level, ok
}

init_level_tile_grid :: proc(level: ^Level) -> bool {
    tile_count := level.width * level.height
    grid, err := make([]Tile, tile_count)
    (err == .None) or_return 
    level.tile_grid = grid

    for &tile, idx in grid {
        tile.x = i32(idx) % level.width
        tile.y = i32(idx) / level.width
    }

    return err == .None
}

update_level_render_area :: proc(level: ^Level, window_width, window_height: i32) {
    area := get_level_render_area_for_window_size(level^, window_width, window_height)
    level.render_area = area
}

get_level_render_area_for_window_size :: proc(level: Level, window_width, window_height: i32) -> SDL.FRect {
    height := window_height - window_height % level.height
    width := min(height, window_width)
    x := window_width / 2 - width / 2
    y := window_height / 2 - height / 2

    return {
        x = f32(x),
        y = f32(y),
        w = f32(width),
        h = f32(height)
    }
}

render_level_tiles :: proc(level: Level, renderer: ^SDL.Renderer) {
    for tile in level.tile_grid {
        if TileFlag.HAS_PLAYER in tile.flags {
            SDL.SetRenderDrawColor(renderer, 40, 180, 40, 255)
        } else {
            SDL.SetRenderDrawColor(renderer, 180, 40, 40, 255)
        }

        tile_rect : SDL.FRect = {
            f32(tile.x * TileSize.x), f32(tile.y * TileSize.y),
            f32(TileSize.x), f32(TileSize.y)
        }
        SDL.RenderFillRect(renderer, &tile_rect)
    }
}

render_level_grid_lines :: proc(level: Level, renderer: ^SDL.Renderer) {
    rects := make([]SDL.FRect, level.width * level.height)
    defer delete(rects)

    x_min := f32(0.0)
    x_max := f32(level.width * TileSize.x)
    y_min := f32(0.0)
    y_max := f32(level.height * TileSize.y)

    SDL.SetRenderDrawColor(
        renderer,
        LevelGridLineColor.r,
        LevelGridLineColor.g,
        LevelGridLineColor.b,
        LevelGridLineColor.a
    )

    for y in 0..<level.height {
        y_curr := f32(y * TileSize.y)
        SDL.RenderLine(renderer, x_min, y_curr, x_max, y_curr)
    }
    for x in 0..<level.width {
        x_curr := f32(x * TileSize.x)
        SDL.RenderLine(renderer, x_curr, y_min, x_curr, y_max)
    }
}

get_level_tile_coord_from_position :: proc(level: Level, pos: vec2i) -> vec2i {
    return pos / (vec2i)(TileSize)
}

get_position_from_level_tile_coord :: proc(level: Level, x, y: i32) -> vec2i {
    return (vec2i)({ x, y }) * (vec2i)(TileSize)
}

get_level_tile :: proc(level: ^Level, x, y: i32) -> (tile: ^Tile, ok: bool) {
    if x < 0 || x >= level.width || y < 0 || y >= level.height {
        log.level_error(
            "attempt to get oob tile ({}, {}) for {}x{} level",
            x, y,
            level.width, level.height
        )

        return nil, false
    }

    return &level.tile_grid[level.width * y + x], true
}

cleanup_level :: proc(level: ^Level) {
    delete(level.tile_grid)
}