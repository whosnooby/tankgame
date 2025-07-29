package game

import "../engine"
import "../engine/collider/aabb"

import SDL "vendor:sdl3"

State :: struct {
    bullet_pool: BulletPool,
    player: Player,
    level: uint,
}

init_game_state :: proc(gstate: ^State, estate: ^engine.State) {
    gstate.player = create_player(estate)
    init_bullet_pool(&gstate.bullet_pool, estate)
}

tick_state :: proc(gstate: ^State) {
    tick_bullet_pool(&gstate.bullet_pool)
    tick_player(&gstate.player)
}

update_state :: proc(gstate: ^State, time: ^engine.Time) {
    update_player(gstate, &gstate.player, time)
}

render_state :: proc(gstate: ^State, estate: ^engine.State) {
    render_player(estate, &gstate.player)
    render_bullets(estate, gstate.bullet_pool)
}

cleanup_state :: proc(gstate: ^State) {
    cleanup_player(&gstate.player)
    cleanup_bullet_pool(&gstate.bullet_pool)
}