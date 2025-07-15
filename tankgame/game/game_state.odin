package game

import "../engine"

State :: struct {
    bullet_pool: BulletPool,
    player: Player,
    level: uint,
}

game_init :: proc(gstate: ^State, estate: ^engine.State) {
    gstate.player = create_player(estate)
    init_bullet_pool(&gstate.bullet_pool, estate)
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