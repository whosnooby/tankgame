package engine

TileSize : [2]i32 : { 32, 32 }

TileType :: enum {
    EMPTY = 0,
}

Tile :: struct {
    x, y: i32,
    type: TileType,
}