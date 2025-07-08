package logging

import "core:fmt"
import rt "base:runtime"

@(private="package")
log_impl :: proc(level: string, loc: rt.Source_Code_Location, format: string, args: ..any) {
    // the formatted input string
    fmt_str := fmt.aprintf(format, ..args)
    defer delete(fmt_str)

    fmt.printfln("[%s][%s] %s", level, loc.procedure, fmt_str)
}

log :: proc(format: string, args: ..any) {
    fmt.printfln(format, ..args)
}

trace :: proc(format: string, args: ..any, loc := #caller_location) {
    log_impl("trace", loc, format, ..args)
}

info :: proc(format: string, args: ..any, loc := #caller_location) {
    log_impl("info", loc, format, ..args)
}

warn :: proc(format: string, args: ..any, loc := #caller_location) {
    log_impl("warn", loc, format, ..args)
}

error :: proc(format: string, args: ..any, loc := #caller_location) {
    log_impl("error", loc, format, ..args)
}

panic :: proc(format: string, args: ..any, loc := #caller_location) {
    fmt_string := fmt.aprintf(format, ..args)

    fmt.panicf("[panic at %s] %s", loc.procedure, fmt_string)
}