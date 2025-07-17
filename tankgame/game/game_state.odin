package game

import "../engine"
import phys "../engine/physics"

import SDL "vendor:sdl3"

@(private="file")
// quick temporary code to keep a collider and texture on screen
StaticObject :: struct {
    rect: SDL.FRect,
    collider: ^phys.Collider,
}

State :: struct {
    bullet_pool: BulletPool,
    player: Player,
    level: uint,

    obj: StaticObject,
}

game_init :: proc(gstate: ^State, estate: ^engine.State) {
    gstate.player = create_player(estate)
    init_bullet_pool(&gstate.bullet_pool, estate)

    gstate.obj.rect = {
        x = 200, y = 200,
        w = 64, h = 64,
    }

    gstate.obj.collider = phys.reserve_static_collider(&estate.physics_state)
    phys.collider_init(gstate.obj.collider, gstate.obj.rect) 
}

// used to update colliders before the physics tick
game_prepare_physics :: proc(gstate: ^State) {
    player_update_collider(&gstate.player) 
}

game_tick :: proc(gstate: ^State) {
    bullet_pool_tick(&gstate.bullet_pool)
    player_tick(&gstate.player)
}

game_update :: proc(gstate: ^State, time: ^engine.Time) {
    update_player(gstate, &gstate.player, time)
}

game_render :: proc(gstate: ^State, estate: ^engine.State) {
    render_player(estate, &gstate.player)
    bullet_pool_render_active(estate, gstate.bullet_pool)
}

game_cleanup :: proc(gstate: ^State) {
    cleanup_player(&gstate.player)
    bullet_pool_cleanup(&gstate.bullet_pool)
}