package log

import rt "base:runtime"

video_trace :: proc(msg: string, args: ..any, loc: rt.Source_Code_Location = #caller_location) {
    log_message(.TRACE, .VIDEO, msg, ..args)
}

video_verbose :: proc(msg: string, args: ..any, loc: rt.Source_Code_Location = #caller_location) {
    log_message(.VERBOSE, .VIDEO, msg, ..args)
}

video_debug :: proc(msg: string, args: ..any, loc: rt.Source_Code_Location = #caller_location) {
    log_message(.DEBUG, .VIDEO, msg, ..args)
}

video_info :: proc(msg: string, args: ..any, loc: rt.Source_Code_Location = #caller_location) {
    log_message(.INFO, .VIDEO, msg, ..args)
}

video_warn :: proc(msg: string, args: ..any, loc: rt.Source_Code_Location = #caller_location) {
    log_message(.WARN, .VIDEO, msg, ..args)
}

video_error :: proc(msg: string, args: ..any, loc: rt.Source_Code_Location = #caller_location) {
    log_message(.ERROR, .VIDEO, msg, ..args)
}

video_panic :: proc(msg: string, args: ..any, loc: rt.Source_Code_Location = #caller_location) {
    panic_message(.VIDEO, loc, msg, ..args)
}
