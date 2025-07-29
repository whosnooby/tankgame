package log

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
    LEVEL,
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
