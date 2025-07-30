package engine

import SDL "vendor:sdl3"

TileSize : [2]i32 : { 32, 32 }
HalfTileSize : [2]i32 : { TileSize.x / 2, TileSize.y / 2 }

TileType :: enum {
    EMPTY = 0,
}

TileFlag :: enum {
    HAS_PLAYER,
}

Tile :: struct {
    x, y: i32,
    type: TileType,
    flags: bit_set[TileFlag]
}

get_tile_rect :: proc(tile: Tile) -> SDL.Rect {
    return {
        tile.x, tile.y,
        TileSize.x, TileSize.y
    }
}

get_tile_rect_float :: proc(tile: Tile) -> SDL.FRect {
    return {
        f32(tile.x), f32(tile.y),
        f32(TileSize.x), f32(TileSize.y)
    }
}
