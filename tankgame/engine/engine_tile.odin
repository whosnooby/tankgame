package engine

TILE_WIDTH :: 16
TILE_HEIGHT :: 16

TileType :: enum {
    EMPTY = 0,
}

Tile :: struct {
    x, y: i32,
    type: TileType,
}