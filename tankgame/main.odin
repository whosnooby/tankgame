package main

import "base:runtime"
import log "engine/logging"
import "game"
import "engine"
import "engine/gfx"

import fmt "core:fmt"
import SDL "vendor:sdl3"

set_app_metadata :: proc() {
    metadata := make(map[cstring]cstring)
    metadata[SDL.PROP_APP_METADATA_NAME_STRING      ] = "tankgame"
    metadata[SDL.PROP_APP_METADATA_VERSION_STRING   ] = "1.0.0"
    metadata[SDL.PROP_APP_METADATA_IDENTIFIER_STRING] = "com.mantelis.tankgame"
    metadata[SDL.PROP_APP_METADATA_CREATOR_STRING   ] = "mantelis"
    metadata[SDL.PROP_APP_METADATA_COPYRIGHT_STRING ] = "Copyright (c) 2025 mantelis"
    metadata[SDL.PROP_APP_METADATA_URL_STRING       ] = "https://github.com/whosnooby/tankgame"
    metadata[SDL.PROP_APP_METADATA_TYPE_STRING      ] = "game"

    for property, value in metadata {
        if !SDL.SetAppMetadataProperty(property, value) {
            log.app_error("failed to set app property '%s': %s", property, SDL.GetError())
        }
    }
}


main :: proc() {
    fmt.println("hello, world!")

    if ok := SDL.Init({ .VIDEO, }); !ok {
        log.app_panic("no SDL, major L")
        return
    }

    estate := engine.State {}
    gstate := game.State {}

    estate.time = engine.time_init(64)

    SDL.SetLogOutputFunction(engine.console_logfn, &estate.console)
    SDL.SetLogPriorities(.TRACE)

    if console, ok := engine.create_console(&estate); ok {
        estate.console = console
    } else {
        log.app_panic("failed to create console")
        return
    }


    if window, ok := engine.create_window(); ok {
        estate.window = window
    } else {
        return
    }

    engine.resize_console(&estate)

    if renderer, ok := engine.create_renderer(&estate); ok {
        estate.renderer = renderer
    } else {
        return
    }
    engine.create_console_text_engine(&estate)

    if target, ok := engine.create_render_target(&estate); ok {
        estate.render_target = target
    } else {
        return
    }

    gstate.player = game.create_player(&estate)

    estate = engine.initialize_engine_cvars(&estate)^
    estate = game.add_game_cvars(&estate, &gstate)^

    engine.print_cvars(&estate, "initialized cvars:")

    game.main_loop(&estate, &gstate)

    engine.cleanup_state(&estate)
    game.cleanup_player(&gstate.player)
}
