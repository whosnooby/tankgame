package engine

import "core:odin/ast"
import log "logging"

import rt "base:runtime"
import "core:fmt"
import "core:slice"
import "core:strconv"
import "core:strings"
import "core:reflect"

import SDL "vendor:sdl3"
import TTF "vendor:sdl3/ttf"

ConsoleWriteCallback :: #type proc(^State)
ConsoleInputCallback :: #type proc(^State, string)
ConsoleCommandHandler :: #type proc(^State, []string)

ConsoleCommand :: struct {
    name: string,
    handler: ConsoleCommandHandler,
}

Console :: struct {
    history: [dynamic]string,
    content: strings.Builder,

    font: ^TTF.Font,
    text_obj: ^TTF.Text,
    text_engine: ^TTF.TextEngine,
    text_surface: ^SDL.Surface,
    text_texture: ^SDL.Texture,
    rect: SDL.FRect,

    needs_redraw: bool,

    input_handler: ConsoleInputCallback,
    on_write: ConsoleWriteCallback,

    history_pos: int,
}

create_console :: proc(state: ^State) -> (console: Console, ok: bool) {
    if !TTF.Init() {
        log.app_panic("failed to init text rendering")
    }

    console = {
        // content = strings.builder_make(),
        font = TTF.OpenFont("resources/whitrabt.ttf", 15.0),
        input_handler = default_console_input_handler
    }
    ok = true

    if console.font == nil {
        log.console_error("failed to load console font")
        ok = false
    }
    
    return console, ok
}

create_console_text_engine :: proc(state: ^State) {
    state.console.text_engine = TTF.CreateRendererTextEngine(state.renderer)
}

resize_console :: proc(state: ^State) {
    window_area: SDL.Rect
    SDL.GetWindowSafeArea(state.window, &window_area)

    state.console.rect = { x = 0, y = 0, w = f32(window_area.w), h = f32(window_area.h / 3) }
}

console_logfn :: proc "c" (
    userdata: rawptr,
    category: SDL.LogCategory,
    priority: SDL.LogPriority,
    message: cstring
) {
    context = rt.default_context()

    when false {
        str := fmt.aprintfln("[%s][%s] %s", priority, category, message)
        defer delete(str)

        fmt.print(str)
    } else {
        fmt.printfln("[%s][%s] %s", priority, category, message)
    }

    console := (^Console)(userdata)
    // strings.write_string(&console.content, str)
}

push_string_to_console :: proc(console: ^Console, str: string) {
    fmt.println(str)
    // strings.write_string(&console.content, str)
}

console_write_callback :: proc(state: ^State) {
    state.console.needs_redraw = true
}

console_set_cvar :: proc(state: ^State, cvar: CVars, args: string) {
    var := &state.cvars[cvar]
    str := strings.trim(args, " \t")

    switch value in var.value {
        case ^uint:
            num, ok := strconv.parse_uint(str)
            if ok do value^ = num
            else do log.console_error("\"%s\" cannot be parsed as uint", args)
        case ^f32:
            num, ok := strconv.parse_f32(str)
            if ok do value^ = num
            else do log.console_error("\"%s\" cannot be parsed as f32", args)
        case ^string:
            value^ = str
        case:
            log.console_error("cvar \"%s\" value type is nil")
    }
}

default_console_input_handler :: proc(state: ^State, str: string) {
    console := &state.console
    append(&console.history, str)

    command_str_end := strings.index(str, " ")
    has_args := true
    if command_str_end == -1 {
        command_str_end = len(str)
        has_args = false
    }
    command := str[:command_str_end]

    args: string
    if has_args {
        args = str[command_str_end+1:]
    }

    for name, cvar in state.cvar_names {
        if strings.compare(name, command) == 0 {
            console_set_cvar(state, cvar, args)
        }
    }
}

clear_console :: proc(console: ^Console) {
    strings.builder_reset(&console.content)
}

render_console_text :: proc(console: ^Console) {
    str := strings.to_string(console.content) 
    cstr := strings.clone_to_cstring(str)
    defer delete(cstr)

    text := TTF.CreateText(console.text_engine, console.font, cstr, len(cstr))
    if text == nil {
        log.console_error("failed to create text object for rendering")
        return
    }
    defer TTF.DestroyText(text)

    if !TTF.DrawRendererText(text, console.rect.x, console.rect.y) {
        log.console_error("whoops! failed to render text")
    }
}

render_console :: proc(state: ^State) {
    if !state.rendering_console do return
    console := &state.console

    SDL.SetRenderDrawColor(state.renderer, 100, 100, 100, 255)
    SDL.RenderFillRect(state.renderer, &console.rect)

    render_console_text(console)
}

