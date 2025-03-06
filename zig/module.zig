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
    pub const Major = c.GLFW_VERSION_MAJOR;
    pub const Minor = c.GLFW_VERSION_MINOR;
    pub const Revision = c.GLFW_VERSION_REVISION;
};
// These are completely unnecessary, but glfw offers them so why not
pub const True = 1;
pub const False = 0;
// Utility structs for functions
pub const Position = struct { x: f64, y: f64 };
pub const iPosition = struct { x: c_int, y: c_int };
pub const Size = struct { width: c_uint, height: c_uint };
pub const Workarea = struct { position: iPosition, size: Size };
pub const FrameSize = struct { left: c_int, right: c_int, top: c_int, bottom: c_int };
pub const Scale = struct { x: f32, y: f32 };
pub const VideoMode = struct { size: Size, bits: struct { r: c_int, g: c_int, b: c_int }, refreshRate: c_int };
pub const GammaRamp = c.GLFWgammaramp;
pub const GamepadState = c.GLFWgamepadstate;

pub const Monitor = @import("monitor.zig");
pub const Window = @import("window.zig");
pub const Cursor = @import("cursor.zig");
pub const Joystick = @import("joystick.zig");
pub const Image = c.GLFWimage;

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
// TODO: fix tls problems with both of these
pub fn getCurrentContext() ?Window {
    internal.requireInit();
    if (c.glfwGetCurrentContext()) |ptr| {
        return .{ .handle = @ptrCast(@alignCast(ptr)) };
    } else return null;
}

pub fn swapInterval(interval: c_int) !void {
    internal.requireInit();
    c.glfwSwapInterval(interval);
    try errorCheck();
}
pub const OpenGL = struct {
    pub fn extensionSupported(extension: [*:0]const u8) !bool {
        internal.requireInit();
        const res = c.glfwExtensionSupported(extension);
        try errorCheck();
        return res != 0;
    }

    pub fn getProcAddress(procname: [*:0]const u8) !c.GLFWglproc {
        internal.requireInit();
        const res = c.glfwGetProcAddress(procname);
        try errorCheck();
        return res;
    }
};

pub const Vulkan = if (build_options.vulkan) @import("vulkan.zig") else struct {};
