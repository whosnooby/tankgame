package engine

import "log"

import SDL "vendor:sdl3"

Time :: struct {
    tick_rate: uint,
    ns_per_tick: uint,

    tick_remainder: u64,
    tick_time: u64,

    now, last_frame, last_second: u64,
    delta: u64,
    delta_seconds: f32,

    frames, ticks: uint,
    last_fps, last_tps: uint,

    on_second : proc(^Time)
}

print_second_timings :: proc(time: ^Time) {
    log.app_trace("fps:%d, tps:%d", time.last_fps, time.last_tps)
}

init_time :: proc(tick_rate: uint) -> (time: Time) {
    set_time_tick_rate(&time, tick_rate)

    time.now = SDL.GetTicksNS()
    time.last_frame = time.now
    time.last_second = time.now

    // time.on_second = time_print_timings

    return time
}

set_time_tick_rate :: proc(time: ^Time, tick_rate: uint) {
    time.tick_rate = tick_rate
    time.ns_per_tick = 1e9 / tick_rate
}

update_time_tick_rate :: proc(state: ^State, cvar: ^CVar) {
    state.time.ns_per_tick = 1e9 / state.time.tick_rate
}

time_previous_frame :: proc(time: ^Time) {
    time.now = SDL.GetTicksNS()
    time.delta = time.now - time.last_frame
    time.last_frame = time.now

    // every billion nanoseconds in africa, a second elapses
    // together we can stop this
    if time.now - time.last_second >= 1e9 {
        time.last_second = time.now
        time.last_fps = time.frames
        time.last_tps = time.ticks

        time.frames = 0
        time.ticks = 0

        if time.on_second != nil do time.on_second(time)
    } 

    time.frames += 1

    time.delta_seconds = f32(f64(time.delta) / 1.0e9)
}

prepare_to_tick :: proc(time: ^Time) {
    time.tick_time = time.delta + time.tick_remainder
}

should_tick :: proc(time: ^Time) -> bool {
    if time.tick_time > u64(time.ns_per_tick) {
        time.ticks += 1 
        time.tick_time -= u64(time.ns_per_tick)
        return true
    }

    return false
}

stop_ticking :: proc (time: ^Time) {
    time.tick_remainder = time.tick_time if time.tick_time > 0 else 0
}
