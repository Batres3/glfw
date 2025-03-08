//! Gamma ramp for monitors
//!
//! It can be .owned if initialized by the user, or not .owned if obtained via
//! glfw.Monitor.getGammaRamp. If it is owned it must be freed by the user using .deinit

const internal = @import("internal.zig");
const c = internal.c;
const std = @import("std");
const GammaRamp = @This();

red: []u16,
green: []u16,
blue: []u16,
owned: ?[]u16,

/// Initializes a new (owned) gamma ramp with the given size and undefined values
/// .deinit must be called.
pub fn init(allocator: std.mem.Allocator, size: usize) !GammaRamp {
    const buf = try allocator.init(u16, size * 3);
    return .{
        .red = buf[0..size],
        .green = buf[size .. 2 * size],
        .blue = buf[2 * size .. 3 * size],
        .owned = buf,
    };
}

/// Deinitialzes the memory of an owned gamma ramp, does nothing if not owned.
pub fn deinit(self: *GammaRamp, allocator: std.mem.Allocator) void {
    if (self.owned) |buf| allocator.free(buf);
}

/// Converts a zig gamma ramp into a (non owning) C gamma ramp for interaction with the C api
pub fn toC(self: GammaRamp) c.GLFWgammaramp {
    return .{
        .red = &self.red[0],
        .green = &self.green[0],
        .blue = &self.blue[0],
        .size = @as(c_uint, @intCast(self.red.len)),
    };
}

/// Converts a C gramma ramp into a (non-owning) zig gamma ramp
pub fn fromC(ramp: *const c.GLFWgammaramp) GammaRamp {
    return .{
        .red = ramp.red[0..ramp.size],
        .green = ramp.green[0..ramp.size],
        .blue = ramp.blue[0..ramp.size],
        .owned = null,
    };
}
