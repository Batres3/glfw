const std = @import("std");
const internal = @import("internal.zig");
const c = internal.c;
const _c = internal._c;
const glfw = internal.glfw;
const Position = glfw.iPosition;
const Size = glfw.Size;
const Workarea = glfw.Workarea;
const Error = internal.Error;
const errorCheck = internal.errorCheck;
const Monitor = @This();

fn requireInit() Error!void {
    if (_c._glfw.initialized == 0) return Error.NotInitialized;
}

handle: *_c._GLFWmonitor = undefined,

//
// Static functions
//
pub fn init(glfw_handle: *c.GLFWmonitor) Monitor {
    return .{ .handle = glfw_handle };
}

pub fn getAll() Error![]*_c._GLFWmonitor {
    try requireInit();
    const count: usize = @intCast(_c._glfw.monitorCount);

    const tmp: [*c]*_c._GLFWmonitor = @ptrCast(_c._glfw.monitors);
    return tmp[0..count];
}

pub fn getPrimary() Error!Monitor {
    return .{ .handle = _c._glfw.monitors[0] };
}

pub fn setCallback(callback: c.GLFWmonitorfun) Error!c.GLFWmonitorfun {
    try requireInit();
    // TODO: Why are these casts necessary?
    const tmp: c.GLFWmonitorfun = @ptrCast(_c._glfw.callbacks.monitor);
    _c._glfw.callbacks.monitor = @ptrCast(callback);
    return tmp;
}
//
// Member functions
//
pub fn getPosition(self: *Monitor) Error!Position {
    try requireInit();
    var pos: Position = .{ .x = 0, .y = 0 };
    _c._glfw.platform.getMonitorPos.?(self.handle, &pos.x, &pos.y);
    return pos;
}

pub fn getWorkarea(self: *Monitor) Error!Workarea {
    try requireInit();
    var xpos: c_int = 0;
    var ypos: c_int = 0;
    var xsize: c_int = 0;
    var ysize: c_int = 0;
    _c._glfw.platform.getMonitorWorkarea.?(self.handle, &xpos, &ypos, &xsize, &ysize);
    return .{ .position = .{ .x = xpos, .y = ypos }, .size = .{ .width = @intCast(xsize), .height = @intCast(ysize) } };
}

/// Returns size in millimeters, it may not be accurate
pub fn getPhysicalSize(self: *Monitor) Error!Size {
    try requireInit();
    return .{ .width = @intCast(self.handle.heightMM), .height = @intCast(self.handle.widthMM) };
}

pub fn getContentScale(self: *Monitor) Error!glfw.Scale {
    try requireInit();
    var data: glfw.Scale = .{ .x = 0, .y = 0 };
    _c._glfw.platform.getMonitorContentScale.?(self.handle, &data.x, &data.y);
    return data;
}

pub fn getName(self: *Monitor) Error![]const u8 {
    try requireInit();
    const len = std.mem.indexOfScalar(u8, &self.handle.name, 0).?;
    return self.handle.name[0..len];
}

pub fn setUserPointer(self: *Monitor, pointer: *anyopaque) void {
    self.handle.userPointer = pointer;
}

pub fn getUserPointer(self: *Monitor) ?*anyopaque {
    return self.handle.userPointer;
}
//
// Video modes
//
// TODO: Make a Zig implementation
// Defined in monitor.c
// extern fn refreshVideoModes(monitor: *_c._GLFWmonitor) callconv(.C) c_int;
// pub fn getVideoModes(self: *Monitor) Error!?[]c.GLFWvidmode {
//     try requireInit();
//     if (refreshVideoModes(self.handle) == 0) return null;
//     const count: usize = @intCast(self.handle.modeCount);
//     const tmp: [*c]c.GLFWvidmode = @ptrCast(self.handle.modes);
//     return tmp[0..count];
// }
pub fn getVideoModes(self: *Monitor) Error!?[]const c.GLFWvidmode {
    var count: c_int = 0;
    const res: [*c]const c.GLFWvidmode = @ptrCast(c.glfwGetVideoModes(@ptrCast(self.handle), &count));
    return res[0..@intCast(count)];
}

pub fn getVideoMode(self: *Monitor) Error!?glfw.VideoMode {
    try requireInit();
    if (_c._glfw.platform.getVideoMode.?(self.handle, &self.handle.currentMode) == 0) return null;
    const current = self.handle.currentMode;
    return .{
        .size = .{ .width = @intCast(current.width), .height = @intCast(current.height) },
        .bits = .{ .r = current.redBits, .g = current.greenBits, .b = current.blueBits },
        .refreshRate = current.refreshRate,
    };
}
//
// Gamma
//
pub fn setGamma(self: *Monitor, gamma: f32) Error!void {
    c.glfwSetGamma(@ptrCast(self.handle), gamma);
    try errorCheck();
}

pub fn getGammaRamp(self: *Monitor) Error!?*const glfw.GammaRamp {
    const res = c.glfwGetGammaRamp(@ptrCast(self.handle));
    try errorCheck();
    return @ptrCast(res);
}

pub fn setGammaRamp(self: *Monitor, ramp: *const c.GLFWgammaramp) Error!void {
    try requireInit();

    if (self.handle.originalRamp.size == 0) {
        if (_c._glfw.platform.getGammaRamp.?(self.handle, &self.handle.originalRamp) == 0) return;
    }

    _c._glfw.platform.setGammaRamp.?(self.handle, @ptrCast(ramp));
}
