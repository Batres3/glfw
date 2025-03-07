const std = @import("std");
const internal = @import("internal.zig");
const input = @import("input.zig");
const c = internal.c;
const _c = internal._c;
const glfw = internal.glfw;
const Position = glfw.uPos;
const Size = glfw.Size;
const Workarea = glfw.Workarea;
const Error = glfw.Error;
const Window = @This();
const Cursor = @import("Cursor.zig");
const Monitor = @import("Monitor.zig");
const Hint = @import("hint.zig");
const errorCheck = glfw.errorCheck;
const requireInit = internal.requireInit;

handle: *_c._GLFWwindow = undefined,

// Static functions
pub fn init(width: u16, height: u16, title: [:0]const u8, monitor: ?*Monitor, share: ?*Window) Error!Window {
    requireInit();
    const h = c.glfwCreateWindow(
        @as(c_int, width),
        @as(c_int, height),
        title,
        null,
        null,
    );
    _ = monitor;
    _ = share;
    if (h == null) return Error.PlatformError;
    return .{ .handle = @ptrCast(@alignCast(h.?)) };
}

pub fn deinit(self: *Window) void {
    requireInit();
    c.glfwDestroyWindow(@ptrCast(self.handle));
}

// TODO: The only possible error for all of these functions is that glfw is not initialized
// since they use a Window object, it must have been initialized, but it is possible that it was terminated
// before this function is called, so we still require an error check. Figure out how to remove that.
pub fn shouldClose(self: *Window) bool {
    requireInit();
    return self.handle.shouldClose != 0;
}

pub fn close(self: *Window, value: bool) void {
    requireInit();
    self.handle.shouldClose = value;
}

pub fn getTitle(self: *Window) []const u8 {
    requireInit();
    return std.mem.span(self.handle.title);
}

/// Try to avoid using this function, set the title when creating the window
pub fn setTitle(self: *Window, title: [:0]const u8) void {
    requireInit();
    self.handle.title = _c._glfw_strdup(title);
    _c._glfw.platform.setWindowTitle.?(self.handle, title);
}

pub fn setIcon(self: *Window, images: []const c.GLFWimage) Error!void {
    c.glfwSetWindowIcon(@ptrCast(self.handle), images.len, images);
    try errorCheck();
}

pub fn getPosition(self: *Window) Position {
    requireInit();
    var xpos: c_int = 0;
    var ypos: c_int = 0;
    _c._glfw.platform.getWindowPos.?(self.handle, &xpos, &ypos);
    return .{ .x = @intCast(xpos), .y = @intCast(ypos) };
}

pub fn setPosition(self: *Window, pos: Position) void {
    requireInit();
    if (self.handle.monitor != null) return;
    _c._glfw.platform.setWindowPos.?(self.handle, @intCast(pos.x), @intCast(pos.y));
}

pub fn getSize(self: *Window) Size {
    requireInit();
    var xsize: c_int = 0;
    var ysize: c_int = 0;
    _c._glfw.platform.getWindowSize.?(self.handle, &xsize, &ysize);
    return .{ .width = @intCast(xsize), .height = @intCast(ysize) };
}

pub fn setSize(self: *Window, size: Size) void {
    requireInit();
    self.handle.videoMode.width = @intCast(size.width);
    self.handle.videoMode.height = @intCast(size.height);

    _c._glfw.platform.setWindowSize.?(self.handle, self.handle.videoMode.width, self.handle.videoMode.height);
}

pub fn setSizeLimits(self: *Window, minwidth: ?u32, minheight: ?u32, maxwidth: ?u32, maxheight: ?u32) Error!void {
    requireInit();
    if (maxwidth != null and maxheight != null and minwidth != null and minheight != null) {
        if (maxwidth.? < minwidth.? or maxheight.? < minheight.?) return Error.InvalidValue;
    }
    self.handle.maxwidth = if (maxwidth) |n| @intCast(n) else -1;
    self.handle.maxheight = if (maxheight) |n| @intCast(n) else -1;
    self.handle.minwidth = if (minwidth) |n| @intCast(n) else -1;
    self.handle.minheight = if (minheight) |n| @intCast(n) else -1;

    if (self.handle.monitor != null or self.handle.resizable != 0) return;

    _c._glfw.platform.setWindowSizeLimits.?(
        self.handle,
        self.handle.minwidth,
        self.handle.minheight,
        self.handle.maxwidth,
        self.handle.maxheight,
    );
}

pub fn setAspectRatio(self: *Window, numer: ?u32, denom: ?u32) void {
    requireInit();
    const n: c_int = if (numer) |num| @intCast(num) else -1;
    const d: c_int = if (denom) |num| @intCast(num) else -1;

    self.handle.numer = n;
    self.handle.denom = d;

    if (self.handle.monitor != null or self.handle.resizable == 0) return;
    _c._glfw.platform.setWindowAspectRatio.?(self.handle, n, d);
}

pub fn getFramebufferSize(self: *Window) Size {
    requireInit();
    var xsize: c_int = 0;
    var ysize: c_int = 0;
    _c._glfw.platform.getFramebufferSize.?(self.handle, &xsize, &ysize);
    return Size{ .width = @intCast(xsize), .height = @intCast(ysize) };
}

pub fn getFrameSize(self: *Window) glfw.FrameSize {
    requireInit();
    var f: glfw.FrameSize = .{ .left = 0, .right = 0, .top = 0, .bottom = 0 };
    _c._glfw.platform.getWindowFrameSize.?(self.handle, &f.left, &f.top, &f.right, &f.bottom);
    return f;
}

pub fn getContentScale(self: *Window) glfw.ContentScale {
    requireInit();
    var scale: glfw.ContentScale = .{ .x = 0, .y = 0 };
    _c._glfw.platform.getWindowContentScale.?(self.handle, &scale.x, &scale.y);
    return scale;
}

pub fn getOpacity(self: *Window) f32 {
    requireInit();
    return _c._glfw.platform.getWindowOpacity.?(self.handle);
}

/// opacity is in [0, 1]
pub fn setOpacity(self: *Window, opacity: f32) Error!void {
    requireInit();
    if (opacity != opacity or opacity < 0 or opacity > 1) return Error.InvalidValue;
    _c._glfw.platform.setWindowOpacity.?(self.handle, opacity);
}

pub fn iconify(self: *Window) void {
    requireInit();
    _c._glfw.platform.iconifyWindow.?(self.handle);
}
pub fn isIconified(self: *Window) bool {
    requireInit();
    return _c._glfw.platform.windowIconified.?(self.handle) != 0;
}

pub fn restore(self: *Window) void {
    requireInit();
    _c._glfw.platform.restoreWindow.?(self.handle);
}

pub fn maximize(self: *Window) void {
    requireInit();
    if (self.handle.monitor != null) return;
    _c._glfw.platform.maximizeWindow.?(self.handle);
}

pub fn isMaximized(self: *Window) bool {
    requireInit();
    return _c._glfw.platform.windowMaximized.?(self.handle) != 0;
}

pub fn show(self: *Window) void {
    requireInit();
    if (self.handle.monitor != null) return;
    _c._glfw.platform.showWindow.?(self.handle);

    if (self.handle.focusOnShow != 0) self.focus();
}

pub fn isVisible(self: *Window) bool {
    requireInit();
    return _c._glfw.platform.windowVisible.?(self.handle) != 0;
}

pub fn hide(self: *Window) void {
    requireInit();
    if (self.handle.monitor != null) return;
    _c._glfw.platform.hideWindow.?(self.handle);
}

pub fn focus(self: *Window) void {
    requireInit();
    _c._glfw.platform.focusWindow.?(self.handle);
}

pub fn isFocused(self: *Window) bool {
    requireInit();
    return _c._glfw.platform.windowFocused.?(self.handle) != 0;
}

pub fn isHovered(self: *Window) bool {
    requireInit();
    return _c._glfw.platform.windowHovered.?(self.handle) != 0;
}

pub fn requestAttention(self: *Window) void {
    requireInit();
    _c._glfw.platform.requestWindowAttention.?(self.handle);
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

pub fn getMonitor(self: *Window) ?Monitor {
    requireInit();
    return .{ .handle = self.handle.monitor };
}

pub fn setMonitor(self: *Window, monitor: ?*Monitor, pos: Position, size: Size, refreshRate: ?u32) void {
    requireInit();

    self.handle.videoMode.width = @intCast(size.width);
    self.handle.videoMode.height = @intCast(size.height);
    self.handle.videoMode.refreshRate = if (refreshRate) |rate| @intCast(rate) else -1;

    _c._glfw.platform.setWindowMonitor(
        self.handle,
        if (monitor) |m| m.handle else null,
        pos.x,
        pos.y,
        self.handle.videoMode.width,
        self.handle.videoMode.height,
        self.handle.videoMode.refreshRate,
    );
}

pub fn setUserPointer(self: *Window, pointer: *anyopaque) void {
    requireInit();
    self.handle.userPointer = pointer;
}

pub fn getUserPointer(self: *Window) ?*anyopaque {
    requireInit();
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
/// This function is valid for the hints in InputMode, for Cursor mode use set/getCursorMode
/// and for RawMouseMotion use set/getRawMouseMotion
pub fn setInputMode(self: *Window, mode: InputMode, value: bool) void {
    requireInit();
    c.glfwSetInputMode(@ptrCast(self.handle), @intFromEnum(mode), @intFromBool(value));
}
/// This function is valid for the hints in InputMode, for Cursor mode use set/getCursorMode
/// and for RawMouseMotion use set/getRawMouseMotion
pub fn getInputMode(self: *Window, mode: InputMode) bool {
    requireInit();
    const val = switch (mode) {
        .StickyKeys => self.handle.stickyKeys,
        .StickyMouseButtons => self.handle.stickyMouseButtons,
        .LockKeyMods => self.handle.lockKeyMods,
        .UnlimitedMouseButtons => self.handle.disableMouseButtonLimit,
    };
    return val != 0;
}
pub fn setCursorMode(self: *Window, mode: InputMode.Cursor) void {
    requireInit();
    const m: c_int = @intFromEnum(mode);
    if (self.handle.cursorMode == m) return;

    _c._glfw.platform.getCursorPos.?(self.handle, &self.handle.virtualCursorPosX, &self.handle.virtualCursorPosY);
    _c._glfw.platform.setCursorMode.?(self.handle, m);
}
pub fn getCursorMode(self: *Window) InputMode.Cursor {
    requireInit();
    return @enumFromInt(self.handle.cursorMode);
}
pub fn rawMouseMotionSupported() bool {
    requireInit();
    return _c._glfw.platform.rawMouseMotionSupported.?() != 0;
}
pub fn setRawMouseMotion(self: *Window, value: bool) !void {
    requireInit();
    if (!rawMouseMotionSupported()) return Error.PlatformError;
    const val: c_int = @intFromBool(value);
    if (self.handle.rawMouseMotion == val) return;

    self.handle.rawMouseMotion = val;
    _c._glfw.platform.setRawMouseMotion.?(self.handle, val);
}
pub fn getRawMouseMotion(self: *Window) bool {
    requireInit();
    return self.handle.rawMouseMotion != 0;
}
pub const InputMode = enum(c_int) {
    StickyKeys = c.GLFW_STICKY_KEYS,
    StickyMouseButtons = c.GLFW_STICKY_MOUSE_BUTTONS,
    LockKeyMods = c.GLFW_LOCK_KEY_MODS,
    UnlimitedMouseButtons = c.GLFW_UNLIMITED_MOUSE_BUTTONS,
    //RawMouseMotion = c.GLFW_RAW_MOUSE_MOTION,
    //Cursor = c.GLFW_CURSOR;
    pub const Cursor = enum(c_int) {
        Normal = c.GLFW_CURSOR_NORMAL,
        Disabled = c.GLFW_CURSOR_DISABLED,
        Hidden = c.GLFW_CURSOR_HIDDEN,
        Captured = c.GLFW_CURSOR_CAPTURED,
    };
};

pub fn getKey(self: *Window, key: input.Key) input.State {
    requireInit();
    const k: usize = @intCast(@intFromEnum(key));
    if (self.handle.keys[k] == 3) { // _GLFW_STICK
        // Sticky mode, so we release
        self.handle.keys[k] = @intFromEnum(input.State.Release);
        return .Press;
    }
    return @enumFromInt(self.handle.keys[k]);
}

pub fn getMouseButton(self: *Window, key: input.Mouse) input.State {
    requireInit();
    const k: usize = @intCast(@intFromEnum(key));
    if (self.handle.mouseButtons[k] == 3) {
        self.handle.mouseButtons[k] = @intFromEnum(input.State.Release);
        return .Press;
    }
    return @enumFromInt(self.handle.mouseButtons[k]);
}

pub fn setCursorPosition(self: *Window, pos: glfw.Pos) !void {
    requireInit();
    if (pos.x != pos.x or pos.y != pos.y) return Error.InvalidValue;
    if (!self.isFocused()) return;

    if (self.handle.cursorMode == @intFromEnum(InputMode.Cursor.Disabled)) {
        self.handle.virtualCursorPosX = pos.x;
        self.handle.virtualCursorPosY = pos.y;
    } else {
        _c._glfw.platform.setCursorPos.?(self.handle, pos.x, pos.y);
    }
}

pub fn getCursorPosition(self: *Window) glfw.Pos {
    requireInit();
    if (self.handle.cursorMode == @intFromEnum(InputMode.Cursor.Disabled)) {
        return .{ .x = self.handle.virtualCursorPosX, .y = self.handle.virtualCursorPosY };
    }
    var x: f64 = 0;
    var y: f64 = 0;
    _c._glfw.platform.getCursorPos.?(self.handle, &x, &y);
    return .{ .x = x, .y = y };
}

pub fn setCursor(self: *Window, cursor: ?Cursor) void {
    requireInit();
    if (cursor) |ptr| {
        self.handle.cursor = ptr.handle;
    } else self.handle.cursor = null;

    _c._glfw.platform.setCursor.?(self.handle, self.handle.cursor);
}

pub fn setKeyCallback(self: *Window, callback: c.GLFWkeyfun) void {
    requireInit();
    self.handle.callbacks.key = callback;
}
pub fn setCharCallback(self: *Window, callback: c.GLFWcharfun) void {
    requireInit();
    self.handle.callbacks.character = callback;
}
pub fn setCharModsCallback(self: *Window, callback: c.GLFWcharmodsfun) void {
    requireInit();
    self.handle.callbacks.charmods = callback;
}
pub fn setMouseButtonCallback(self: *Window, callback: c.GLFWmousebuttonfun) void {
    requireInit();
    self.handle.callbacks.mouseButton = callback;
}
pub fn setCursorPosCallback(self: *Window, callback: c.GLFWcursorposfun) void {
    requireInit();
    self.handle.callbacks.cursorPos = callback;
}
pub fn setCursorEnterCallback(self: *Window, callback: c.GLFWcursorenterfun) void {
    requireInit();
    self.handle.callbacks.cursorEnter = callback;
}
pub fn setScrollCallback(self: *Window, callback: c.GLFWscrollfun) void {
    requireInit();
    self.handle.callbacks.scroll = callback;
}
pub fn setDropCallback(self: *Window, callback: c.GLFWdropfun) void {
    requireInit();
    self.handle.callbacks.drop = callback;
}
//
// Context
//

pub fn makeCurrentContext(self: *Window) !void {
    requireInit();
    c.glfwMakeContextCurrent(@ptrCast(self.handle));
    try glfw.errorCheck();
    // TODO: Check why this fails, it seems like tls.posix is not set? but it works when it runs the C code?
    // if (self.handle.context.client == @intFromEnum(glfw.Hint.Context.API.Client.Value.NoAPI)) {
    //     return Error.NoWindowContext;
    // }
    //
    // if (_c._glfwPlatformGetTls(&_c._glfw.contextSlot)) |ptr| {
    //     const prev: *_c._GLFWwindow = @ptrCast(@alignCast(ptr));
    //     if (self.handle.context.source != prev.context.source)
    //         prev.context.makeCurrent.?(null);
    // }
    //
    // self.handle.context.makeCurrent.?(self.handle);
}

pub fn swapBuffers(self: *Window) !void {
    requireInit();
    if (self.handle.context.client == @intFromEnum(glfw.Hint.Context.API.Client.Value.NoAPI))
        return Error.NoWindowContext;

    self.handle.context.swapBuffers(self.handle);
}
