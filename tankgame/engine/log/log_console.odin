package log

import rt "base:runtime"

console_trace :: proc(msg: string, args: ..any, loc: rt.Source_Code_Location = #caller_location) {
    log_message(.TRACE, .CONSOLE, msg, ..args)
}

console_verbose :: proc(msg: string, args: ..any, loc: rt.Source_Code_Location = #caller_location) {
    log_message(.VERBOSE, .CONSOLE, msg, ..args)
}

console_debug :: proc(msg: string, args: ..any, loc: rt.Source_Code_Location = #caller_location) {
    log_message(.DEBUG, .CONSOLE, msg, ..args)
}

console_info :: proc(msg: string, args: ..any, loc: rt.Source_Code_Location = #caller_location) {
    log_message(.INFO, .CONSOLE, msg, ..args)
}

console_warn :: proc(msg: string, args: ..any, loc: rt.Source_Code_Location = #caller_location) {
    log_message(.WARN, .CONSOLE, msg, ..args)
}

console_error :: proc(msg: string, args: ..any, loc: rt.Source_Code_Location = #caller_location) {
    log_message(.ERROR, .CONSOLE, msg, ..args)
}

console_panic :: proc(msg: string, args: ..any, loc: rt.Source_Code_Location = #caller_location) {
    panic_message(.CONSOLE, loc, msg, ..args)
}
