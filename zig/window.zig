const std = @import("std");
const c = @cImport(@cInclude("glfw3.h"));
const internal = @cImport(@cInclude("../../src/internal.h"));
const glfw = @import("module.zig");
const Position = glfw.Position;
const Size = glfw.Size;
const Workarea = glfw.Workarea;
const Error = glfw.Error;
const errorCheck = glfw.errorCheck;
const Window = @This();
const Monitor = @import("monitor.zig");
const Hint = @import("hint.zig");

handle: *internal._GLFWwindow = undefined,
fn asExternal(self: *Window) *c.GLFWwindow {
    return @ptrCast(self.handle);
}

// Window hints

// Static functions
fn requireInit() Error!void {
    if (internal._glfw.initialized == 0) return Error.NotInitialized;
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
    return .{ .handle = @ptrCast(@alignCast(h.?)) };
}

pub fn deinit(self: *Window) void {
    c.glfwDestroyWindow(self.asExternal());
}

// TODO: The only possible error for all of these functions is that glfw is not initialized
// since they use a Window object, it must have been initialized, but it is possible that it was terminated
// before this function is called, so we still require an error check. Figure out how to remove that.
pub fn shouldClose(self: *Window) Error!bool {
    try requireInit();
    return self.handle.shouldClose != 0;
}

pub fn close(self: *Window, value: bool) Error!void {
    try requireInit();
    self.handle.shouldClose = value;
}

pub fn getTitle(self: *Window) Error![]const u8 {
    try requireInit();
    return std.mem.span(self.handle.title);
}

/// Try to avoid using this function, set the title when creating the window
pub fn setTitle(self: *Window, title: [:0]const u8) Error!void {
    try requireInit();
    self.handle.title = internal._glfw_strdup(title);
    internal._glfw.platform.setWindowTitle.?(self.handle, title);
}

pub fn setIcon(self: *Window, images: []const c.GLFWimage) Error!void {
    c.glfwSetWindowIcon(@ptrCast(self.handle), images.len, images);
    try errorCheck();
}

pub fn getPosition(self: *Window) Error!Position {
    try requireInit();
    var pos: Position = .{ .x = 0, .y = 0 };
    internal._glfw.platform.getWindowPos.?(self.handle, &pos.x, &pos.y);
    return pos;
}

pub fn setPosition(self: *Window, pos: Position) Error!void {
    try requireInit();
    if (self.handle.monitor != null) return;
    internal._glfw.platform.setWindowPos.?(self.handle, pos.x, pos.y);
}

pub fn getSize(self: *Window) Error!Size {
    try requireInit();
    var xsize: c_int = 0;
    var ysize: c_int = 0;
    internal._glfw.platform.getWindowSize.?(self.handle, &xsize, &ysize);
    return .{ .width = @intCast(xsize), .height = @intCast(ysize) };
}

pub fn setSize(self: *Window, size: Size) Error!void {
    try requireInit();
    self.handle.videoMode.width = @intCast(size.width);
    self.handle.videoMode.height = @intCast(size.height);

    internal._glfw.platform.setWindowSize.?(self.handle, self.handle.videoMode.width, self.handle.videoMode.height);
}

pub fn setSizeLimits(self: *Window, minwidth: ?u32, minheight: ?u32, maxwidth: ?u32, maxheight: ?u32) Error!void {
    try requireInit();
    if (maxwidth != null and maxheight != null and minwidth != null and minheight != null) {
        if (maxwidth.? < minwidth.? or maxheight.? < minheight.?) return Error.InvalidValue;
    }
    self.handle.maxwidth = if (maxwidth) |n| @intCast(n) else -1;
    self.handle.maxheight = if (maxheight) |n| @intCast(n) else -1;
    self.handle.minwidth = if (minwidth) |n| @intCast(n) else -1;
    self.handle.minheight = if (minheight) |n| @intCast(n) else -1;

    if (self.handle.monitor != null or self.handle.resizable != 0) return;

    internal._glfw.platform.setWindowSizeLimits.?(
        self.handle,
        self.handle.minwidth,
        self.handle.minheight,
        self.handle.maxwidth,
        self.handle.maxheight,
    );
}

pub fn setAspectRatio(self: *Window, numer: ?u32, denom: ?u32) Error!void {
    try requireInit();
    const n: c_int = if (numer) |num| @intCast(num) else -1;
    const d: c_int = if (denom) |num| @intCast(num) else -1;

    self.handle.numer = n;
    self.handle.denom = d;

    if (self.handle.monitor != null or self.handle.resizable == 0) return;
    internal._glfw.platform.setWindowAspectRatio.?(self.handle, n, d);
}

pub fn getFramebufferSize(self: *Window) Error!Size {
    try requireInit();
    var xsize: c_int = 0;
    var ysize: c_int = 0;
    internal._glfw.platform.getFramebufferSize.?(self.handle, &xsize, &ysize);
    return Size{ .width = @intCast(xsize), .height = @intCast(ysize) };
}

pub fn getFrameSize(self: *Window) Error!glfw.FrameSize {
    try requireInit();
    var f: glfw.FrameSize = .{ .left = 0, .right = 0, .top = 0, .bottom = 0 };
    internal._glfw.platform.getWindowFrameSize.?(self.handle, &f.left, &f.top, &f.right, &f.bottom);
    return f;
}

pub fn getContentScale(self: *Window) Error!glfw.Scale {
    try requireInit();
    var scale: glfw.Scale = .{ .x = 0, .y = 0 };
    internal._glfw.platform.getWindowContentScale.?(self.handle, &scale.x, &scale.y);
    return scale;
}

pub fn getOpacity(self: *Window) Error!f32 {
    try requireInit();
    return internal._glfw.platform.getWindowOpacity.?(self.handle);
}

/// opacity is in [0, 1]
pub fn setOpacity(self: *Window, opacity: f32) Error!void {
    try requireInit();
    if (opacity != opacity or opacity < 0 or opacity > 1) return Error.InvalidValue;
    internal._glfw.platform.setWindowOpacity.?(self.handle, opacity);
}

pub fn iconify(self: *Window) Error!void {
    try requireInit();
    internal._glfw.platform.iconifyWindow.?(self.handle);
}
pub fn isIconified(self: *Window) Error!bool {
    try requireInit();
    return internal._glfw.platform.windowIconified.?(self.handle) != 0;
}

pub fn restore(self: *Window) Error!void {
    try requireInit();
    internal._glfw.platform.restoreWindow.?(self.handle);
}

pub fn maximize(self: *Window) Error!void {
    try requireInit();
    if (self.handle.monitor != null) return;
    internal._glfw.platform.maximizeWindow.?(self.handle);
}

pub fn isMaximized(self: *Window) Error!bool {
    try requireInit();
    return internal._glfw.platform.windowMaximized.?(self.handle) != 0;
}

pub fn show(self: *Window) Error!void {
    try requireInit();
    if (self.handle.monitor != null) return;
    internal._glfw.platform.showWindow.?(self.handle);

    if (self.handle.focusOnShow != 0) try self.focus();
}

pub fn isVisible(self: *Window) Error!bool {
    try requireInit();
    return internal._glfw.platform.windowVisible.?(self.handle) != 0;
}

pub fn hide(self: *Window) Error!void {
    try requireInit();
    if (self.handle.monitor != null) return;
    internal._glfw.platform.hideWindow.?(self.handle);
}

pub fn focus(self: *Window) Error!void {
    try requireInit();
    internal._glfw.platform.focusWindow.?(self.handle);
}

pub fn isFocused(self: *Window) Error!bool {
    try requireInit();
    return internal._glfw.platform.windowFocused.?(self.handle) != 0;
}

pub fn isHovered(self: *Window) Error!bool {
    try requireInit();
    return internal._glfw.platform.windowHovered.?(self.handle) != 0;
}

pub fn requestAttention(self: *Window) Error!void {
    try requireInit();
    internal._glfw.platform.requestWindowAttention.?(self.handle);
}

/// This function should not generally be used, window properties
/// can be accessed through the relevant function or through the handle
pub fn getWindowAttrib(self: *Window, attrib: c_int) Error!c_int {
    const res = c.glfwGetWindowAttrib(@ptrCast(self.handle), attrib);
    try errorCheck();
    return res;
}
/// This function should not generally be used, window properties
/// can be accessed through the relevant function or through the handle
pub fn setWindowAttrib(self: *Window, attrib: c_int, value: c_int) Error!void {
    c.glfwSetWindowAttrib(@ptrCast(self.handle), attrib, value);
    try errorCheck();
}

pub fn getMonitor(self: *Window) Error!?Monitor {
    try requireInit();
    return .{ .handle = self.handle.monitor };
}

pub fn setMonitor(self: *Window, monitor: ?*Monitor, pos: Position, size: Size, refreshRate: ?u32) Error!void {
    try requireInit();

    self.handle.videoMode.width = @intCast(size.width);
    self.handle.videoMode.height = @intCast(size.height);
    self.handle.videoMode.refreshRate = if (refreshRate) |rate| @intCast(rate) else -1;

    internal._glfw.platform.setWindowMonitor(
        self.handle,
        if (monitor) |m| m.handle else null,
        pos.x,
        pos.y,
        self.handle.videoMode.width,
        self.handle.videoMode.height,
        self.handle.videoMode.refreshRate,
    );
}

pub fn setUserPointer(self: *Window, pointer: *anyopaque) Error!void {
    try requireInit();
    self.handle.userPointer = pointer;
}

pub fn getUserPointer(self: *Window) Error!?*anyopaque {
    try requireInit();
    return self.handle.userPointer;
}

pub fn setPosCallback(self: *Window, callback: c.GLFWwindowposfun) void {
    self.handle.callbacks.pos = callback;
}
pub fn setSizeCallback(self: *Window, callback: c.GLFWwindowsizefun) void {
    self.handle.callbacks.size = callback;
}
pub fn setCloseCallback(self: *Window, callback: c.GLFWwindowclosefun) void {
    self.handle.callbacks.close = callback;
}
pub fn setRefreshCallback(self: *Window, callback: c.GLFWwindowrefreshfun) void {
    self.handle.callbacks.refresh = callback;
}
pub fn setFocusCallback(self: *Window, callback: c.GLFWwindowfocusfun) void {
    self.handle.callbacks.focus = callback;
}
pub fn setIconifyCallback(self: *Window, callback: c.GLFWwindowiconifyfun) void {
    self.handle.callbacks.iconify = callback;
}
pub fn setMaximizeCallback(self: *Window, callback: c.GLFWwindowmaximizefun) void {
    self.handle.callbacks.maximize = callback;
}
pub fn setFramebufferSizeCallback(self: *Window, callback: c.GLFWwindowsizefun) void {
    self.handle.callbacks.size = callback;
}
pub fn setContentScaleCallback(self: *Window, callback: c.GLFWwindowcontentscalefun) void {
    self.handle.callbacks.scale = callback;
}
//
// Input
//
pub fn setInputMode(self: *Window, mode: InputMode, value: anytype) !void {
    const val: c_int = if (@TypeOf(value) == bool)
        @intFromBool(value)
    else
        @intFromEnum(value);

    c.glfwSetInputMode(@ptrCast(self.handle), @intFromEnum(mode), val);
}
pub fn getInputMode(self: *Window, mode: InputMode) union { bool: bool, cursor: InputMode.Cursor.Value } {
    switch (mode) {
        .StickyKeys => return .{ .bool = self.handle.stickyKeys != 0 },
        .StickyMouseButtons => return .{ .bool = self.handle.stickyMouseButtons != 0 },
        .LockKeyMods => return .{ .bool = self.handle.lockKeyMods != 0 },
        .RawMouseMotion => return .{ .bool = self.handle.rawMouseMotion != 0 },
        .UnlimitedMouseButtons => return .{ .bool = self.handle.disableMouseButtonLimit != 0 },
        .Cursor => return .{ .cursor = @enumFromInt(self.handle.cursorMode) },
    }
}
pub const InputMode = enum(c_int) {
    StickyKeys = c.GLFW_STICKY_KEYS,
    StickyMouseButtons = c.GLFW_STICKY_MOUSE_BUTTONS,
    LockKeyMods = c.GLFW_LOCK_KEY_MODS,
    UnlimitedMouseButtons = c.GLFW_UNLIMITED_MOUSE_BUTTONS,
    RawMouseMotion = c.GLFW_RAW_MOUSE_MOTION,
    Cursor = c.GLFW_CURSOR,
    pub fn set(self: *Window, mode: InputMode, value: bool) !void {
        c.glfwSetInputMode(@ptrCast(self.handle), @intFromEnum(mode), @intFromBool(value));
        try errorCheck();
    }
    pub fn get(self: *Window, mode: InputMode) bool {
        const value = switch (mode) {
            .StickyKeys => self.handle.stickyKeys,
            .StickyMouseButtons => self.handle.stickyMouseButtons,
            .LockKeyMods => self.handle.lockKeyMods,
            .RawMouseMotion => self.handle.rawMouseMotion,
            .UnlimitedMouseButtons => self.handle.disableMouseButtonLimit,
        };
        return value != 0;
    }
    pub const _RawMouseMotion = struct {
        pub fn supported() bool {
            return internal._glfw.platform.rawMouseMotionSupported.?() != 0;
        }
        pub fn get(self: *Window) bool {
            return self.handle.rawMouseMotion != 0;
        }
        pub fn set(self: *Window, value: bool) !void {
            if (!supported()) return Error.PlatformError;
            const val: c_int = @intFromBool(value);
            if (self.handle.rawMouseMotion == val) return;
            self.handle.rawMouseMotion = val;
            internal._glfw.platform.setRawMouseMotion.?(self.handle, val);
        }
    };
    pub const Cursor = struct {
        pub fn get(self: *Window) Value {
            return @enumFromInt(self.handle.cursorMode);
        }
        pub fn set(self: *Window, value: Value) void {
            const mode: c_int = @intFromEnum(value);
            if (self.handle.cursorMode == mode) return;

            internal._glfw.platform.getCursorPos.?(
                self.handle,
                &self.handle.virtualCursorPosX,
                &self.handle.virtualCursorPosY,
            );
            internal._glfw.platform.setCursorMode(self.handle, mode);
        }
        pub const Value = enum(c_int) {
            Normal = c.GLFW_CURSOR_NORMAL,
            Disabled = c.GLFW_CURSOR_DISABLED,
            Hidden = c.GLFW_CURSOR_HIDDEN,
            Captured = c.GLFW_CURSOR_CAPTURED,
        };
    };
};
