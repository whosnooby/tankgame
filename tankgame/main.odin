package main

import "game"
import "engine"
import "engine/gfx"
import log "engine/logging"

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
    estate: engine.State
    gstate: game.State
    game.create_game(&estate, &gstate)
    game.main_loop(&estate, &gstate)

    game.cleanup_state(&gstate)
    engine.cleanup_state(&estate)
}
