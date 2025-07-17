package logging

import rt "base:runtime"
import "core:fmt"
import "core:strings"

import SDL "vendor:sdl3"

LogCategory :: enum i32 {
	APPLICATION = i32(SDL.LogCategory.APPLICATION),
	ERROR       = i32(SDL.LogCategory.ERROR),
	ASSERT      = i32(SDL.LogCategory.ASSERT),
	SYSTEM      = i32(SDL.LogCategory.SYSTEM),
	AUDIO       = i32(SDL.LogCategory.AUDIO),
	VIDEO       = i32(SDL.LogCategory.VIDEO),
	RENDER      = i32(SDL.LogCategory.RENDER),
	INPUT       = i32(SDL.LogCategory.INPUT),
	TEST        = i32(SDL.LogCategory.TEST),
	GPU         = i32(SDL.LogCategory.GPU),

    CONSOLE     = i32(SDL.LogCategory.CUSTOM),
    PHYSICS,
    CUSTOM,
}

@(private="package")
log_message :: proc(priority: SDL.LogPriority, category: LogCategory, msg: string, args: ..any) {
    str := fmt.tprintfln(msg, ..args)
    defer delete(str, allocator=context.temp_allocator)

    SDL.LogMessage(i32(category), priority, "%s", str) 
}

@(private="package")
panic_message :: proc(category: LogCategory, loc: rt.Source_Code_Location, msg: string, args: ..any,) {
    log_message(.CRITICAL, category, msg, ..args)
    fmt.panicf(string(msg), ..args, loc = loc)
}

app_trace :: proc(msg: string, args: ..any, loc: rt.Source_Code_Location = #caller_location) {
    log_message(.TRACE, .APPLICATION, msg, ..args)
}

app_verbose :: proc(msg: string, args: ..any, loc: rt.Source_Code_Location = #caller_location) {
    log_message(.VERBOSE, .APPLICATION, msg, ..args)
}

app_debug :: proc(msg: string, args: ..any, loc: rt.Source_Code_Location = #caller_location) {
    log_message(.DEBUG, .APPLICATION, msg, ..args)
}

app_info :: proc(msg: string, args: ..any, loc: rt.Source_Code_Location = #caller_location) {
    log_message(.INFO, .APPLICATION, msg, ..args)
}

app_warn :: proc(msg: string, args: ..any, loc: rt.Source_Code_Location = #caller_location) {
    log_message(.WARN, .APPLICATION, msg, ..args)
}

app_error :: proc(msg: string, args: ..any, loc: rt.Source_Code_Location = #caller_location) {
    log_message(.ERROR, .APPLICATION, msg, ..args)
}

app_panic :: proc(msg: string, args: ..any, loc: rt.Source_Code_Location = #caller_location) {
    panic_message(.APPLICATION, loc, msg, ..args)
}

input_trace :: proc(msg: string, args: ..any) {
    log_message(.TRACE, .INPUT, msg, ..args)
}

input_verbose :: proc(msg: string, args: ..any) {
    log_message(.VERBOSE, .INPUT, msg, ..args)
}

input_debug :: proc(msg: string, args: ..any) {
    log_message(.DEBUG, .INPUT, msg, ..args)
}

input_info :: proc(msg: string, args: ..any) {
    log_message(.INFO, .INPUT, msg, ..args)
}

input_warn :: proc(msg: string, args: ..any) {
    log_message(.WARN, .INPUT, msg, ..args)
}

input_error :: proc(msg: string, args: ..any) {
    log_message(.WARN, .INPUT, msg, ..args)
}

input_panic :: proc(msg: string, args: ..any, loc: rt.Source_Code_Location = #caller_location) {
    panic_message(.INPUT, loc, msg, ..args)
}

video_trace :: proc(msg: string, args: ..any) {
    log_message(.TRACE, .VIDEO, msg, ..args)
}

video_verbose :: proc(msg: string, args: ..any) {
    log_message(.VERBOSE, .VIDEO, msg, ..args)
}

video_debug :: proc(msg: string, args: ..any) {
    log_message(.DEBUG, .VIDEO, msg, ..args)
}

video_info :: proc(msg: string, args: ..any) {
    log_message(.INFO, .VIDEO, msg, ..args)
}

video_warn :: proc(msg: string, args: ..any) {
    log_message(.WARN, .VIDEO, msg, ..args)
}

video_error :: proc(msg: string, args: ..any) {
    log_message(.ERROR, .VIDEO, msg, ..args)
}

video_panic :: proc(msg: string, args: ..any, loc: rt.Source_Code_Location = #caller_location) {
    panic_message(.VIDEO, loc, msg, ..args)
}

render_trace :: proc(msg: string, args: ..any) {
    log_message(.TRACE, .RENDER, msg, ..args)
}

render_verbose :: proc(msg: string, args: ..any) {
    log_message(.VERBOSE, .RENDER, msg, ..args)
}

render_debug :: proc(msg: string, args: ..any) {
    log_message(.DEBUG, .RENDER, msg, ..args)
}

render_info :: proc(msg: string, args: ..any) {
    log_message(.INFO, .RENDER, msg, ..args)
}

render_warn :: proc(msg: string, args: ..any) {
    log_message(.WARN, .RENDER, msg, ..args)
}

render_error :: proc(msg: string, args: ..any) {
    log_message(.ERROR, .RENDER, msg, ..args)
}

render_panic :: proc(msg: string, args: ..any, loc := #caller_location) {
    panic_message(.RENDER, loc, msg, ..args)
}

console_trace :: proc(msg: string, args: ..any) {
    log_message(.TRACE, .CONSOLE, msg, ..args)
}

console_verbose :: proc(msg: string, args: ..any) {
    log_message(.VERBOSE, .CONSOLE, msg, ..args)
}

console_debug :: proc(msg: string, args: ..any) {
    log_message(.DEBUG, .CONSOLE, msg, ..args)
}

console_info :: proc(msg: string, args: ..any) {
    log_message(.INFO, .CONSOLE, msg, ..args)
}

console_warn :: proc(msg: string, args: ..any) {
    log_message(.WARN, .CONSOLE, msg, ..args)
}

console_error :: proc(msg: string, args: ..any) {
    log_message(.ERROR, .CONSOLE, msg, ..args)
}

console_panic :: proc(msg: string, args: ..any, loc := #caller_location) {
    panic_message(.CONSOLE, loc, msg, ..args)
}

physics_trace :: proc(msg: string, args: ..any) {
    log_message(.TRACE, .PHYSICS, msg, ..args)
}

physics_verbose :: proc(msg: string, args: ..any) {
    log_message(.VERBOSE, .PHYSICS, msg, ..args)
}

physics_debug :: proc(msg: string, args: ..any) {
    log_message(.DEBUG, .PHYSICS, msg, ..args)
}

physics_info :: proc(msg: string, args: ..any) {
    log_message(.INFO, .PHYSICS, msg, ..args)
}

physics_warn :: proc(msg: string, args: ..any) {
    log_message(.WARN, .PHYSICS, msg, ..args)
}

physics_error :: proc(msg: string, args: ..any) {
    log_message(.ERROR, .PHYSICS, msg, ..args)
}

physics_panic :: proc(msg: string, args: ..any, loc := #caller_location) {
    panic_message(.PHYSICS, loc, msg, ..args)
}
