package game

import "../engine"
import "../engine/collider/aabb"

import SDL "vendor:sdl3"

State :: struct {
    bullet_pool: BulletPool,
    player: Player,
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

render_state_debug_text :: proc(gstate: ^State, renderer: ^SDL.Renderer) {
    player := &gstate.player

    line_h : i32 : 12
    line :: proc(n: i32) -> f32 {
        return f32(2 + line_h * n)
    }

    SDL.SetRenderDrawColor(renderer, 255, 255, 255, 255)

    SDL.RenderDebugTextFormat(renderer, 2, line(0), "player tile: %d, %d", player.tile_x, player.tile_y)

    bullet_pool_free := card(gstate.bullet_pool.free_slots)
    bullet_pool_active := BulletPoolSize - bullet_pool_free
    SDL.RenderDebugTextFormat(renderer, 2, line(1), "player bullets active/free: %d/%d", bullet_pool_active, bullet_pool_free)
}

render_state_wireframes :: proc(gstate: ^State, estate: ^engine.State) {
    render_player_wireframe(estate, &gstate.player)
    render_bullet_wireframes(estate, gstate.bullet_pool)
}

cleanup_state :: proc(gstate: ^State) {
    cleanup_player(&gstate.player)
    cleanup_bullet_pool(&gstate.bullet_pool)
}