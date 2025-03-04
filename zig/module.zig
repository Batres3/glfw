const std = @import("std");
const builtin = @import("builtin");
pub const c = @cImport({
    @cInclude("glfw3.h");
});
pub const Input = @import("input.zig");
pub const Hint = @import("hint.zig");
// Some simple zig bindings
const err = @import("error.zig");
pub const Error = err.Error;
/// An error check for all the glfw functions, only runs in debug mode by default
/// we use this instead of error callback in order to be able to return errors
pub fn errorCheck() Error!void {
    if (builtin.mode == .Debug) {
        var description: [*c]const u8 = undefined;
        err.toZigError(c.glfwGetError(&description)) catch |e| {
            std.debug.print("glfw error={s} message={s}", .{ @errorName(e), description });
            return e;
        };
        return;
    }
}

// Constants
pub const Version = struct {
    pub const Major = c.GLFW_VERSION_MAJOR;
    pub const Minor = c.GLFW_VERSION_MINOR;
    pub const Revision = c.GLFW_VERSION_REVISION;
};
// These are completely unnecessary, but glfw offers them so why not
pub const True = 1;
pub const False = 0;

pub const Monitor = @import("monitor.zig");
pub const Window = @import("window.zig");
pub const Cursor = c.GLFWcursor;
pub const VideoMode = c.GLFWvidmode;
pub const GammaRamp = c.GLFWgammaramp;
pub const Image = c.GLFWimage;

pub fn init() Error!void {
    _ = c.glfwInit();
    return errorCheck();
}

pub fn deinit() void {
    c.glfwTerminate();
}

/// hint: Valid options can be found in glfw.Hint.Init (excluding the ones ending in Value)
/// value: Valid options are 0 (false), 1 (true) and the members of glfw.Hint.Init ending in value
pub fn initHint(hint: c_int, value: c_int) Error!void {
    c.glfwInitHint(hint, value);
    return errorCheck();
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
pub fn setErrorCallback(callback: c.GLFWerrorfun) c.GLFWerrorfun {
    return c.glfwSetErrorCallback(callback);
}

// Monitors
pub fn getMonitors() Error!?[]const Monitor {
    var count: c_int = 0;
    const res = c.glfwGetMonitors(&count) orelse return Error.NotInitialized;
    var monitors: [count]Monitor = undefined;
    for (res, 0..count) |item, i| {
        monitors[i] = .{item};
    }

    return monitors;
}

pub fn getPrimaryMonitor() Error!*Monitor {
    const res = c.glfwGetPrimaryMonitor() orelse return Error.NotInitialized;
    return .{res};
}

pub fn setMonitorCallback(callback: c.GLFWmonitorfun) Error!c.GLFWmonitorfun {
    const res = c.glfwSetMonitorCallback(callback);
    try errorCheck();
    return res;
}
//
// pub fn getVideoModes(monitor: ?*Monitor, count: *c_int) ?[*]Vidmode {
//     const res = c.glfwGetVideoModes(monitor, count);
//     errorCheck();
//     return res;
// }
//
// pub fn getVideoMode(monitor: ?*Monitor) ?*Vidmode {
//     const res = getVideoMode(monitor);
//     errorCheck();
//     return res;
// }
//
// pub fn setGamma(monitor: ?*Monitor, gamma: f32) void {
//     c.glfwSetGamma(monitor, gamma);
//     errorCheck();
// }
//
// pub fn getGammaRamp(monitor: ?*Monitor) ?*Gammaramp {
//     const res = c.glfwGetGammaRamp(monitor);
//     errorCheck();
//     return res;
// }
//
// pub fn setGammaRamp(monitor: ?*Monitor, ramp: ?*Gammaramp) void {
//     c.glfwSetGammaRamp(monitor, ramp);
//     errorCheck();
// }
//
// pub fn defaultWindowHints() void {
//     c.glfwDefaultWindowHints();
//     errorCheck();
// }
//
// pub fn windowHint(hint: WindowHint, value: c_int) void {
//     c.glfwWindowHint((hint), value);
//     errorCheck();
// }
//
// pub fn windowHintString(hint: WindowHint, value: [*:0]const u8) void {
//     c.glfwWindowHintString((hint), value);
//     errorCheck();
// }
//
// pub fn createWindow(width: c_int, height: c_int, title: [*:0]const u8, monitor: ?*Monitor, share: ?*Window) !*Window {
//     const res = c.glfwCreateWindow(width, height, title, monitor, share);
//     errorCheck();
//     if (res == null) {
//         return GLFWError.PlatformError;
//     }
//     return res.?;
// }
//
// pub fn destroyWindow(window: ?*Window) void {
//     c.glfwDestroyWindow(window);
//     errorCheck();
// }
//
// pub fn windowShouldClose(window: ?*Window) bool {
//     const res = c.glfwWindowShouldClose(window);
//     errorCheck();
//     return res != 0;
// }
//
// pub fn setWindowShouldClose(window: ?*Window, value: bool) void {
//     c.glfwSetWindowShouldClose(window, @intFromBool(value));
//     errorCheck();
// }
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
//
// pub fn pollEvents() void {
//     c.glfwPollEvents();
//     errorCheck();
// }
//
// pub fn waitEvents() void {
//     c.glfwWaitEvents();
//     errorCheck();
// }
//
// pub fn waitEventsTimeout(timeout: f64) void {
//     c.glfwWaitEventsTimeout(timeout);
//     errorCheck();
// }
//
// pub fn postEmptyEvent() void {
//     c.glfwPostEmptyEvent();
//     errorCheck();
// }
//
// //Depending on what your input mode is, you can change to true/false or one of the attribute enums
// pub fn getInputMode(window: ?*Window, mode: InputMode) c_int {
//     const res = c.glfwGetInputMode(window, (mode));
//     errorCheck();
//     return res;
// }
//
// pub fn setInputMode(window: ?*Window, mode: InputMode, value: c_int) void {
//     c.glfwSetInputMode(window, (mode), value);
//     errorCheck();
// }
//
// pub fn rawMouseMotionSupported() bool {
//     const res = c.glfwRawMouseMotionSupported();
//     errorCheck();
//     return res != 0;
// }
//
// const std = @import("std");
// pub fn getKeyName(key: Key, scancode: c_int) ?[:0]const u8 {
//     const res = c.glfwGetKeyName((key), scancode);
//     errorCheck();
//     return std.mem.spanZ(res);
// }
//
// pub fn getKeyScancode(key: Key) c_int {
//     const res = c.glfwGetKeyScancode((key));
//     errorCheck();
//     return res;
// }
//
// pub fn getKey(window: ?*Window, key: Key) KeyState {
//     const res = c.glfwGetKey(window, (key));
//     errorCheck();
//     return res;
// }
//
// pub fn getMouseButton(window: ?*Window, button: Mouse) KeyState {
//     const res = c.glfwGetMouseButton(window, (button));
//     errorCheck();
//     return res;
// }
//
// pub fn getCursorPos(window: ?*Window, xpos: *f64, ypos: *f64) void {
//     c.glfwGetCursorPos(window, xpos, ypos);
//     errorCheck();
// }
//
// pub fn setCursorPos(window: ?*Window, xpos: f64, ypos: f64) void {
//     c.glfwSetCursorPos(window, xpos, ypos);
//     errorCheck();
// }
//
// pub fn createCursor(image: ?*Image, xhot: c_int, yhot: c_int) ?*CursorHandle {
//     const res = c.glfwCreateCursor(image, xhot, yhot);
//     errorCheck();
//     return res;
// }
//
// pub fn createStandardCursor(shape: CursorShape) ?*CursorHandle {
//     const res = c.glfwCreateStandardCursor((shape));
//     errorCheck();
//     return res;
// }
//
// pub fn destroyCursor(cursor: ?*CursorHandle) void {
//     c.glfwDestroyCursor(cursor);
//     errorCheck();
// }
//
// pub fn setCursor(window: ?*Window, cursor: ?*CursorHandle) void {
//     c.glfwSetCursor(window, cursor);
//     errorCheck();
// }
//
// pub fn setKeyCallback(window: ?*Window, callback: KeyFun) KeyFun {
//     const res = c.glfwSetKeyCallback(window, callback);
//     errorCheck();
//     return res;
// }
// pub fn setCharCallback(window: ?*Window, callback: CharFun) CharFun {
//     const res = c.glfwSetCharCallback(window, callback);
//     errorCheck();
//     return res;
// }
// pub fn setCharModsCallback(window: ?*Window, callback: CharmodsFun) CharmodsFun {
//     const res = c.glfwSetCharModsCallback(window, callback);
//     errorCheck();
//     return res;
// }
// pub fn setMouseButtonCallback(window: ?*Window, callback: MouseButtonFun) MouseButtonFun {
//     const res = c.glfwSetMouseButtonCallback(window, callback);
//     errorCheck();
//     return res;
// }
// pub fn setCursorPosCallback(window: ?*Window, callback: CursorPosFun) CursorPosFun {
//     const res = c.glfwSetCursorPosCallback(window, callback);
//     errorCheck();
//     return res;
// }
// pub fn setCursorEnterCallback(window: ?*Window, callback: CursorEnterFun) CursorEnterFun {
//     const res = c.glfwSetCursorEnterCallback(window, callback);
//     errorCheck();
//     return res;
// }
// pub fn setScrollCallback(window: ?*Window, callback: ScrollFun) ScrollFun {
//     const res = c.glfwSetScrollCallback(window, callback);
//     errorCheck();
//     return res;
// }
// pub fn setDropCallback(window: ?*Window, callback: DropFun) DropFun {
//     const res = c.glfwSetDropCallback(window, callback);
//     errorCheck();
//     return res;
// }
//
// pub fn joystickPresent(jid: c_int) bool {
//     const res = c.glfwJoystickPresent(jid);
//     errorCheck();
//     return res != 0;
// }
//
// pub fn getJoystickAxes(jid: c_int, count: *c_int) ?[*]const f32 {
//     const res = c.glfwGetJoystickAxes(jid, count);
//     errorCheck();
//     return res;
// }
//
// pub fn getJoystickButtons(jid: c_int, count: *c_int) ?[*]const u8 {
//     const res = c.glfwGetJoystickButtons(jid, count);
//     errorCheck();
//     return res;
// }
//
// pub fn getJoystickHats(jid: c_int, count: *c_int) ?[*]const u8 {
//     const res = c.glfwGetJoystickHats(jid, count);
//     errorCheck();
//     return res;
// }
//
// pub fn getJoystickName(jid: c_int) ?[*:0]const u8 {
//     const res = c.glfwGetJoystickName(jid);
//     errorCheck();
//     return res;
// }
//
// pub fn getJoystickGUID(jid: c_int) ?[*:0]const u8 {
//     const res = c.glfwGetJoystickGUID(jid);
//     errorCheck();
//     return res;
// }
//
// pub fn setJoystickUserPointer(jid: c_int, pointer: *anyopaque) void {
//     const res = c.glfwSetJoystickUserPointer(jid, pointer);
//     errorCheck();
//     return res;
// }
//
// pub fn getJoystickUserPointer(jid: c_int) *anyopaque {
//     const res = getJoystickUserPointer(jid);
//     errorCheck();
//     return res;
// }
//
// pub fn joystickIsGamepad(jid: c_int) c_int {
//     const res = c.glfwJoystickIsGamepad(jid);
//     errorCheck();
//     return res;
// }
//
// pub fn setJoystickCallback(callback: JoystickFun) JoystickFun {
//     const res = c.glfwSetJoystickCallback(callback);
//     errorCheck();
//     return res;
// }
//
// pub fn updateGamepadMappings(string: [*:0]const u8) c_int {
//     const res = c.glfwUpdateGamepadMappings(string);
//     errorCheck();
//     return res;
// }
//
// pub fn getGamepadName(jid: c_int) ?[*:0]const u8 {
//     const res = c.glfwGetGamepadName(jid);
//     errorCheck();
//     return res;
// }
//
// pub fn getGamepadState(jid: c_int, state: ?*GamepadState) c_int {
//     const res = c.glfwGetGamepadState(jid, state);
//     errorCheck();
//     return res;
// }
//
// pub fn setClipboardString(window: ?*Window, string: [*:0]const u8) void {
//     c.glfwSetClipboardString(window, string);
//     errorCheck();
// }
//
// pub fn getClipboardString(window: ?*Window) ?[:0]const u8 {
//     const res = c.glfwGetClipboardString(window);
//     errorCheck();
//     return std.mem.spanZ(res);
// }
//
// pub fn getTime() f64 {
//     const res = c.glfwGetTime();
//     errorCheck();
//     return res;
// }
//
// pub fn setTime(time: f64) void {
//     c.glfwSetTime(time);
//     errorCheck();
// }
//
// pub fn getTimerValue() u64 {
//     const res = c.glfwGetTimerValue();
//     errorCheck();
//     return res;
// }
//
// pub fn getTimerFrequency() u64 {
//     const res = c.glfwGetTimerFrequency();
//     errorCheck();
//     return res();
// }
//
// //Context
// pub fn makeContextCurrent(window: ?*Window) void {
//     c.glfwMakeContextCurrent(window);
//     errorCheck();
// }
//
// pub fn getCurrentContext(window: ?*Window) ?*Window {
//     const res = c.glfwGetCurrentContext(window);
//     errorCheck();
//     return res;
// }
//
// pub fn swapBuffers(window: ?*Window) void {
//     c.glfwSwapBuffers(window);
//     errorCheck();
// }
//
// pub fn swapInterval(interval: c_int) void {
//     c.glfwSwapInterval(interval);
//     errorCheck();
// }
//
// //GL Stuff
// pub fn extensionSupported(extension: [*:0]const u8) c_int {
//     const res = c.glfwExtensionSupported(extension);
//     errorCheck();
//     return res;
// }
//
// pub fn getProcAddress(procname: [*:0]const u8) ?GLproc {
//     const res = c.glfwGetProcAddress(procname);
//     errorCheck();
//     return res;
// }
//
// //Vulkan stuff
// pub fn getInstanceProcAddress(instance: VkInstance, procname: [*:0]const u8) ?VKproc {
//     const res = c.glfwGetInstanceProcAddress(instance, procname);
//     errorCheck();
//     return res;
// }
//
// pub fn getPhysicalDevicePresentationSupport(instance: VkInstance, device: VkPhysicalDevice, queuefamily: u32) bool {
//     const res = c.glfwGetPhysicalDevicePresentationSupport(instance, device, queuefamily);
//     errorCheck();
//     return res != 0;
// }
//
// pub fn createWindowSurface(instance: VkInstance, window: *Window, allocator: ?*const VkAllocationCallbacks, surface: *VkSurfaceKHR) VkResult {
//     const res = c.glfwCreateWindowSurface(instance, window, allocator, surface);
//     errorCheck();
//     return res;
// }
//
// pub fn vulkanSupported() bool {
//     const res = c.glfwVulkanSupported();
//     errorCheck();
//     return res != 0;
// }
//
// pub fn getRequiredInstanceExtensions(count: *u32) ?[*][*:0]const u8 {
//     const res = c.glfwGetRequiredInstanceExtensions(count);
//     errorCheck();
//     return res;
// }
