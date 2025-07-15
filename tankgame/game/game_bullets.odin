package game

import "../engine"
import log "../engine/logging"
import gfx "../engine/gfx"

import SDL "vendor:sdl3"

Bullet :: struct {
    speed: f32,
    position: engine.vec2,
    direction: MoveDirection,
    ticks_left: i64,
}

BulletPoolSize :: 32
BulletLifetime :: 128
BulletSpeed :: 4.0
BulletSize : engine.vec2i : { 8, 8 }

BulletPool :: struct {
    pool: [BulletPoolSize]Bullet,
    free_slots: bit_set[0..<BulletPoolSize],
    bullet_texture: ^SDL.Texture,
}

init_bullet_pool :: proc(pool: ^BulletPool, estate: ^engine.State) {
    for &bullet in pool.pool {
        bullet.speed = 0.0
        bullet.position = { -1, -1 }
        bullet.direction = .NONE
    }

    for i in 0..<BulletPoolSize {
        pool.free_slots += { i }
    }

    texture, ok := gfx.create_solid_texture(
        estate.renderer,
        ([2]i32)(BulletSize),
        { 255, 175, 100, 255 }
    )

    if !ok {
        log.render_panic("failed to generate bullet texture")
        return
    }

    pool.bullet_texture = texture
}

bullet_pool_tick :: proc(pool: ^BulletPool) {
    for &bullet, i in pool.pool {
        bullet.ticks_left -= 1
        if bullet.ticks_left <= 0 { 
            if i not_in pool.free_slots {
                pool.free_slots += { i }
                bullet_make_inactive(&bullet)
            }
            continue
        }

        vectors := MoveVectors
        bullet.position += vectors[bullet.direction] * bullet.speed
    }
}

bullet_spawn_from_pool :: proc(
    pool: ^BulletPool,
    direction: MoveDirection, position: engine.vec2
) -> bool {
    if card(pool.free_slots) == 0 {
        log.app_error("attempt to spawn bullet when pool is full")
        return false
    }

    for idx in pool.free_slots {
        bullet := &pool.pool[idx]

        assert_contextless(bullet.ticks_left <= 0)

        bullet.ticks_left = BulletLifetime
        bullet.speed = BulletSpeed
        bullet.direction = direction
        bullet.position = position

        pool.free_slots -= { idx }

        break
    }

    when false {
        free_bullet_count := card(pool.free_slots)
        log.app_trace("fired bullet #%d (%d remaining in pool)",
            BulletPoolSize - free_bullet_count, free_bullet_count
        )
    }

    return true
}

bullet_pool_render_active :: proc(estate: ^engine.State, pool: BulletPool) {
    if card(pool.free_slots) == BulletPoolSize {
        return
    }

    for bullet in pool.pool {
        if bullet.ticks_left <= 0 {
            continue
        }

        bullet_rect : SDL.FRect = {
            x = bullet.position.x, y = bullet.position.y,
            w = f32(BulletSize.x), h = f32(BulletSize.y)
        }
        SDL.RenderTexture(estate.renderer, pool.bullet_texture, nil, &bullet_rect)
    }
}

bullet_pool_cleanup :: proc(pool: ^BulletPool) {
    SDL.DestroyTexture(pool.bullet_texture)
}

bullet_make_inactive :: proc(bullet: ^Bullet) {
    bullet.ticks_left = 0
    bullet.direction = .NONE
    bullet.position = { -1, -1 }
    bullet.speed = 0.0
}
