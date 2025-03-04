const std = @import("std");
const c = @cImport(@cInclude("glfw3.h"));
const Error = @import("module.zig").Error;
const errorCheck = @import("module.zig").errorCheck;
const Window = @This();
const Monitor = @import("monitor.zig");

handle: *c.GLFWwindow = undefined,

// Static functions
pub fn defaultHints() Error!void {
    c.glfwDefaultWindowHints();
    try errorCheck();
}

pub fn hint(h: c_int, value: c_int) Error!void {
    c.glfwWindowHint(h, value);
    try errorCheck();
}

pub fn hintString(h: c_int) Error![]const u8 {
    var value: [*:0]const u8 = undefined;
    c.glfwWindowHintString(h, &value);
    try errorCheck();
    return std.mem.span(value);
}

pub fn init(width: u16, height: u16, title: [:0]const u8, monitor: ?*Monitor, share: ?*Window) Error!Window {
    const h = c.glfwCreateWindow(
        @as(c_int, width),
        @as(c_int, height),
        title,
        null,
        null,
    );
    _ = monitor;
    _ = share;
    try errorCheck();
    if (h == null) return Error.PlatformError;
    return .{ .handle = h.? };
}

pub fn deinit(self: *Window) void {
    c.glfwDestroyWindow(self.handle);
}

pub fn shouldClose(self: *Window) Error!bool {
    const res = c.glfwWindowShouldClose(self.handle);
    try errorCheck();
    return res != 0;
}

pub fn close(self: *Window, value: bool) Error!void {
    c.glfwSetWindowShouldClose(self.handle, @intFromBool(value));
    try errorCheck();
}
//
// pub fn setWindowTitle(window: ?*Window, title: [*:0]const u8) void {
//     c.glfwSetWindowTitle(window, title);
//     errorCheck();
// }
//
// pub fn setWindowIcon(window: ?*Window, count: c_int, images: ?[*]Image) void {
//     c.glfwSetWindowIcon(window, count, images);
//     errorCheck();
// }
//
// pub fn getWindowPos(window: ?*Window, xpos: *c_int, ypos: *c_int) void {
//     c.glfwGetWindowPos(window, xpos, ypos);
//     errorCheck();
// }
//
// pub fn setWindowPos(window: ?*Window, xpos: c_int, ypos: c_int) void {
//     c.glfwSetWindowPos(window, xpos, ypos);
//     errorCheck();
// }
//
// pub fn getWindowSize(window: ?*Window, width: *c_int, height: *c_int) void {
//     c.glfwGetWindowSize(window, width, height);
//     errorCheck();
// }
//
// pub fn setWindowSizeLimits(window: ?*Window, minwidth: c_int, minheight: c_int, maxwidth: c_int, maxheight: c_int) void {
//     c.glfwSetWindowSizeLimits(window, minwidth, minheight, maxwidth, maxheight);
//     errorCheck();
// }
//
// pub fn setWindowAspectRatio(window: ?*Window, numer: c_int, denom: c_int) void {
//     c.glfwSetWindowAspectRatio(window, numer, denom);
//     errorCheck();
// }
//
// pub fn setWindowSize(window: ?*Window, width: c_int, height: c_int) void {
//     c.glfwSetWindowSize(window, width, height);
//     errorCheck();
// }
//
// pub fn getFramebufferSize(window: ?*Window, width: *c_int, height: *c_int) void {
//     c.glfwGetFramebufferSize(window, width, height);
//     errorCheck();
// }
//
// pub fn getWindowFrameSize(window: ?*Window, left: *c_int, top: *c_int, right: *c_int, bottom: *c_int) void {
//     c.glfwGetWindowFrameSize(window, left, top, right, bottom);
//     errorCheck();
// }
//
// pub fn getWindowContentScale(window: ?*Window, xscale: *f32, yscale: *f32) void {
//     c.glfwGetWindowContentScale(window, xscale, yscale);
//     errorCheck();
// }
//
// pub fn getWindowOpacity(window: ?*Window) f32 {
//     const res = c.glfwGetWindowOpacity(window);
//     errorCheck();
//     return res;
// }
//
// pub fn setWindowOpacity(window: ?*Window, opacity: f32) void {
//     c.glfwSetWindowOpacity(window, opacity);
//     errorCheck();
// }
//
// pub fn iconifyWindow(window: ?*Window) void {
//     c.glfwIconifyWindow(window);
//     errorCheck();
// }
//
// pub fn restoreWindow(window: ?*Window) void {
//     c.glfwRestoreWindow(window);
//     errorCheck();
// }
//
// pub fn maximizeWindow(window: ?*Window) void {
//     c.glfwMaximizeWindow(window);
//     errorCheck();
// }
//
// pub fn showWindow(window: ?*Window) void {
//     c.glfwShowWindow(window);
//     errorCheck();
// }
//
// pub fn hideWindow(window: ?*Window) void {
//     c.glfwHideWindow(window);
//     errorCheck();
// }
//
// pub fn focusWindow(window: ?*Window) void {
//     c.glfwFocusWindow(window);
//     errorCheck();
// }
//
// pub fn requestWindowAttention(window: ?*Window) void {
//     c.glfwRequestWindowAttention(window);
//     errorCheck();
// }
//
// pub fn getWindowMonitor(window: ?*Window) ?*Monitor {
//     const res = c.glfwGetWindowMonitor(window);
//     errorCheck();
//     return res;
// }
//
// pub fn setWindowMonitor(window: ?*Window, monitor: ?*Monitor, xpos: c_int, ypos: c_int, width: c_int, height: c_int, refreshRate: c_int) void {
//     c.glfwSetWindowMonitor(window, monitor, xpos, ypos, width, height, refreshRate);
//     errorCheck();
// }
//
// pub fn getWindowAttrib(window: ?*Window, attrib: WindowHint) c_int {
//     const res = c.glfwGetWindowAttrib(window, (attrib));
//     errorCheck();
//     return res;
// }
//
// pub fn setWindowAttrib(window: ?*Window, attrib: WindowHint, value: c_int) void {
//     c.glfwSetWindowAttrib(window, (attrib), value);
//     errorCheck();
// }
//
// pub fn setWindowUserPointer(window: ?*Window, pointer: *anyopaque) void {
//     c.glfwSetWindowUserPointer(window, pointer);
//     errorCheck();
// }
//
// pub fn getWindowUserPointer(window: ?*Window) ?*anyopaque {
//     const res = c.glfwGetWindowUserPointer(window);
//     errorCheck();
//     return res;
// }
//
// pub fn setWindowPosCallback(window: ?*Window, callback: WindowPosFun) WindowPosFun {
//     const res = c.glfwSetWindowPosCallback(window, callback);
//     errorCheck();
//     return res;
// }
// pub fn setWindowSizeCallback(window: ?*Window, callback: WindowSizeFun) WindowSizeFun {
//     const res = c.glfwSetWindowSizeCallback(window, callback);
//     errorCheck();
//     return res;
// }
// pub fn setWindowCloseCallback(window: ?*Window, callback: WindowCloseFun) WindowCloseFun {
//     const res = c.glfwSetWindowCloseCallback(window, callback);
//     errorCheck();
//     return res;
// }
// pub fn setWindowRefreshCallback(window: ?*Window, callback: WindowRefreshFun) WindowRefreshFun {
//     const res = c.glfwSetWindowRefreshCallback(window, callback);
//     errorCheck();
//     return res;
// }
// pub fn setWindowFocusCallback(window: ?*Window, callback: WindowFocusFun) WindowFocusFun {
//     const res = c.glfwSetWindowFocusCallback(window, callback);
//     errorCheck();
//     return res;
// }
// pub fn setWindowIconifyCallback(window: ?*Window, callback: WindowIconifyFun) WindowIconifyFun {
//     const res = c.glfwSetWindowIconifyCallback(window, callback);
//     errorCheck();
//     return res;
// }
// pub fn setWindowMaximizeCallback(window: ?*Window, callback: WindowMaximizeFun) WindowMaximizeFun {
//     const res = c.glfwSetWindowMaximizeCallback(window, callback);
//     errorCheck();
//     return res;
// }
// pub fn setFramebufferSizeCallback(window: ?*Window, callback: FramebufferSizeFun) FramebufferSizeFun {
//     const res = c.glfwSetFramebufferSizeCallback(window, callback);
//     errorCheck();
//     return res;
// }
// pub fn setWindowContentScaleCallback(window: ?*Window, callback: WindowContentScaleFun) WindowContentScaleFun {
//     const res = c.glfwSetWindowContentScaleCallback(window, callback);
//     errorCheck();
//     return res;
// }
