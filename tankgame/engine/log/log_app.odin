package log

import rt "base:runtime"

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
