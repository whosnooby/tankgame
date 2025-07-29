package game

import "../engine"
import "../engine/gfx"
import "../engine/log"

import SDL "vendor:sdl3"

Bullet :: struct {
    speed: i32,
    position: engine.vec2i,
    direction: MoveDirection,
    ticks_left: i64,
}

BulletPoolSize :: 32
BulletLifetime :: 128
BulletSpeed :: 4.0
BulletSize : engine.vec2i : { 6, 6 }
BulletWireframeColor : [4]u8 : { 160, 70, 40, 255 }

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

tick_bullet_pool :: proc(pool: ^BulletPool) {
    for &bullet, i in pool.pool {
        bullet.ticks_left -= 1
        if bullet.ticks_left <= 0 { 
            if i not_in pool.free_slots {
                pool.free_slots += { i }
                inactivate_bullet(&bullet)
            }
            continue
        }

        vectors := MoveVectors
        bullet.position += vectors[bullet.direction] * bullet.speed
    }
}

spawn_bullet_from_pool :: proc(
    pool: ^BulletPool,
    direction: MoveDirection, position: engine.vec2i
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

render_bullets :: proc(estate: ^engine.State, pool: BulletPool) {
    if card(pool.free_slots) == BulletPoolSize {
        return
    }

    for bullet in pool.pool {
        if bullet.ticks_left <= 0 {
            continue
        }

        bullet_rect : SDL.FRect = {
            x = f32(bullet.position.x), y = f32(bullet.position.y),
            w = f32(BulletSize.x), h = f32(BulletSize.y)
        }
        SDL.RenderTexture(estate.renderer, pool.bullet_texture, nil, &bullet_rect)
    }
}

render_bullet_wireframes :: proc(estate: ^engine.State, pool: BulletPool) {
    if card(pool.free_slots) == BulletPoolSize {
        return
    }

    for bullet in pool.pool {
        if bullet.ticks_left <= 0 {
            continue
        }

        bullet_rect : SDL.FRect = {
            x = f32(bullet.position.x), y = f32(bullet.position.y),
            w = f32(BulletSize.x), h = f32(BulletSize.y)
        }
        SDL.SetRenderDrawColor(
            estate.renderer,
            BulletWireframeColor.r,
            BulletWireframeColor.g,
            BulletWireframeColor.b,
            BulletWireframeColor.a
        )
        SDL.RenderRect(estate.renderer, &bullet_rect)
    }
}

cleanup_bullet_pool :: proc(pool: ^BulletPool) {
    SDL.DestroyTexture(pool.bullet_texture)
}

inactivate_bullet :: proc(bullet: ^Bullet) {
    bullet.ticks_left = 0
    bullet.direction = .NONE
    bullet.position = { -1, -1 }
    bullet.speed = 0.0
}
