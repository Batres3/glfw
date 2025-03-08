const std = @import("std");
const internal = @import("internal.zig");
const _c = internal._c;
pub const build_options = @import("glfw_options");
pub const c = internal.c;
pub const Input = @import("input.zig");
pub const Hint = @import("hint.zig");
pub const Error = @import("error.zig").Error;

// Constants
pub const Version = struct {
    pub const major = c.GLFW_VERSION_MAJOR;
    pub const minor = c.GLFW_VERSION_MINOR;
    pub const revision = c.GLFW_VERSION_REVISION;
};
pub const dont_care = -1;
// Utility structs for functions
pub const Pos = struct { x: f64, y: f64 };
pub const uPos = struct { x: u32, y: u32 };
pub const Size = struct { width: u32, height: u32 };
pub const Workarea = struct { position: uPos, size: Size };
pub const ContentScale = struct { x: f32, y: f32 };
pub const VideoMode = struct { size: Size, bits: struct { r: c_int, g: c_int, b: c_int }, refreshRate: c_int };
pub const GamepadState = c.GLFWgamepadstate;

pub const Monitor = @import("Monitor.zig");
pub const Window = @import("Window.zig");
pub const Cursor = @import("Cursor.zig");
pub const Joystick = @import("Joystick.zig");
pub const GammaRamp = @import("GammaRamp.zig");
pub const Image = @import("Image.zig");

pub fn init() Error!void {
    _ = c.glfwInit();
    return errorCheck();
}
pub fn errorCheck() Error!void {
    var description: [*c]const u8 = undefined;
    if (internal.err.toZigError(c.glfwGetError(&description))) |e| return e;
}

pub fn deinit() void {
    internal.requireInit();
    c.glfwTerminate();
}

/// There's no need to use this, the values can be accessed direcly from glfw.Version
pub fn getVersion(major: *i32, minor: *i32, rev: *i32) void {
    @compileLog("glfw: Use glfw.Version instead of glfw.getVersion");
    c.glfwGetVersion(major, minor, rev);
}

pub fn getVersionString() [*:0]const u8 {
    return c.glfwGetVersionString();
}

/// This should not be used, one of the main benefits of using zig is precisely not needing to use this,
/// it is exposed in case someone needs it, but consider skipping this and simply using the given glfw functions,
/// which have included error checks ()
pub fn setErrorCallback(callback: c.GLFWerrorfun) internal.c.GLFWerrorfun {
    return c.glfwSetErrorCallback(callback);
}

pub fn pollEvents() void {
    internal.requireInit();
    _c._glfw.platform.pollEvents.?();
}

pub fn waitEvents() void {
    internal.requireInit();
    _c._glfw.platform.waitEvents.?();
}

pub fn waitEventsTimeout(timeout: f64) Error!void {
    internal.requireInit();
    if (timeout != timeout or timeout < 0) return Error.InvalidValue;
    _c._glfw.platform.waitEventsTimeout.?(timeout);
}

pub fn postEmptyEvent() void {
    internal.requireInit();
    _c._glfw.platform.postEmptyEvent.?();
}

pub fn setClipboardString(string: [:0]const u8) void {
    internal.requireInit();
    _c._glfw.platform.setClipboardString.?(@ptrCast(string));
}

pub fn getClipboardString() []const u8 {
    internal.requireInit();
    const s: [*:0]const u8 = @ptrCast(_c._glfw.platform.getClipboardString.?());
    return std.mem.span(s);
}

pub fn setTime(time: f64) !void {
    c.glfwSetTime(time);
    errorCheck();
}
pub fn getTime() f64 {
    internal.requireInit();
    c.glfwGetTime();
}

pub fn getTimerValue() u64 {
    internal.requireInit();
    return c.glfwGetTimerValue();
}

pub fn getTimerFrequency() u64 {
    internal.requireInit();
    return c.glfwGetTimerFrequency();
}
//
// Context
//
pub usingnamespace if (build_options.vulkan) @import("vulkan.zig") else @import("opengl.zig");
