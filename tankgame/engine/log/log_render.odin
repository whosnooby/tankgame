package log

import rt "base:runtime"

render_trace :: proc(msg: string, args: ..any, loc: rt.Source_Code_Location = #caller_location) {
    log_message(.TRACE, .RENDER, msg, ..args)
}

render_verbose :: proc(msg: string, args: ..any, loc: rt.Source_Code_Location = #caller_location) {
    log_message(.VERBOSE, .RENDER, msg, ..args)
}

render_debug :: proc(msg: string, args: ..any, loc: rt.Source_Code_Location = #caller_location) {
    log_message(.DEBUG, .RENDER, msg, ..args)
}

render_info :: proc(msg: string, args: ..any, loc: rt.Source_Code_Location = #caller_location) {
    log_message(.INFO, .RENDER, msg, ..args)
}

render_warn :: proc(msg: string, args: ..any, loc: rt.Source_Code_Location = #caller_location) {
    log_message(.WARN, .RENDER, msg, ..args)
}

render_error :: proc(msg: string, args: ..any, loc: rt.Source_Code_Location = #caller_location) {
    log_message(.ERROR, .RENDER, msg, ..args)
}

render_panic :: proc(msg: string, args: ..any, loc: rt.Source_Code_Location = #caller_location) {
    panic_message(.RENDER, loc, msg, ..args)
}
