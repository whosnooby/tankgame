package main

import log "engine/logging"
import renderer "engine/renderer"
import "game"
import "engine"

import fmt "core:fmt"
import SDL "vendor:sdl3"

main :: proc() {
    fmt.println("hello, world!")
    if ok := SDL.Init({ .VIDEO, }); !ok {
        log.panic("no SDL, major L")
        return
    }

    estate := engine.State {}
    gstate := game.State {}

    if window, ok := engine.create_window(); ok {
        estate.window = window
    } else {
        return
    }

    if renderer, ok := engine.create_renderer(&estate); ok {
        estate.renderer = renderer
    } else {
        return
    }
    defer engine.cleanup_state(&estate)

    gstate.player = game.create_player(&estate)

    game.main_loop(&estate, &gstate)
}