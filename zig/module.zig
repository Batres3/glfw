const std = @import("std");
const internal = @import("internal.zig");
const _c = internal._c;
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

pub const Monitor = @import("monitor.zig");
pub const Window = @import("window.zig");
pub const Cursor = c.GLFWcursor;
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
//
// //Depending on what your input mode is, you can change to true/false or one of the attribute enums
// pub fn getInputMode(window: ?*Window, mode: InputMode) c_int {
//     const res = c.glfwGetInputMode(window, (mode));
//     internal.errorCheck();
//     return res;
// }
//
// pub fn setInputMode(window: ?*Window, mode: InputMode, value: c_int) void {
//     c.glfwSetInputMode(window, (mode), value);
//     internal.errorCheck();
// }
//
// pub fn rawMouseMotionSupported() bool {
//     const res = c.glfwRawMouseMotionSupported();
//     internal.errorCheck();
//     return res != 0;
// }
//
// const std = @import("std");
// pub fn getKeyName(key: Key, scancode: c_int) ?[:0]const u8 {
//     const res = c.glfwGetKeyName((key), scancode);
//     internal.errorCheck();
//     return std.mem.spanZ(res);
// }
//
// pub fn getKeyScancode(key: Key) c_int {
//     const res = c.glfwGetKeyScancode((key));
//     internal.errorCheck();
//     return res;
// }
//
// pub fn getKey(window: ?*Window, key: Key) KeyState {
//     const res = c.glfwGetKey(window, (key));
//     internal.errorCheck();
//     return res;
// }
//
// pub fn getMouseButton(window: ?*Window, button: Mouse) KeyState {
//     const res = c.glfwGetMouseButton(window, (button));
//     internal.errorCheck();
//     return res;
// }
//
// pub fn getCursorPos(window: ?*Window, xpos: *f64, ypos: *f64) void {
//     c.glfwGetCursorPos(window, xpos, ypos);
//     internal.errorCheck();
// }
//
// pub fn setCursorPos(window: ?*Window, xpos: f64, ypos: f64) void {
//     c.glfwSetCursorPos(window, xpos, ypos);
//     internal.errorCheck();
// }
//
// pub fn createCursor(image: ?*Image, xhot: c_int, yhot: c_int) ?*CursorHandle {
//     const res = c.glfwCreateCursor(image, xhot, yhot);
//     internal.errorCheck();
//     return res;
// }
//
// pub fn createStandardCursor(shape: CursorShape) ?*CursorHandle {
//     const res = c.glfwCreateStandardCursor((shape));
//     internal.errorCheck();
//     return res;
// }
//
// pub fn destroyCursor(cursor: ?*CursorHandle) void {
//     c.glfwDestroyCursor(cursor);
//     internal.errorCheck();
// }
//
// pub fn setCursor(window: ?*Window, cursor: ?*CursorHandle) void {
//     c.glfwSetCursor(window, cursor);
//     internal.errorCheck();
// }
//
// pub fn setKeyCallback(window: ?*Window, callback: KeyFun) KeyFun {
//     const res = c.glfwSetKeyCallback(window, callback);
//     internal.errorCheck();
//     return res;
// }
// pub fn setCharCallback(window: ?*Window, callback: CharFun) CharFun {
//     const res = c.glfwSetCharCallback(window, callback);
//     internal.errorCheck();
//     return res;
// }
// pub fn setCharModsCallback(window: ?*Window, callback: CharmodsFun) CharmodsFun {
//     const res = c.glfwSetCharModsCallback(window, callback);
//     internal.errorCheck();
//     return res;
// }
// pub fn setMouseButtonCallback(window: ?*Window, callback: MouseButtonFun) MouseButtonFun {
//     const res = c.glfwSetMouseButtonCallback(window, callback);
//     internal.errorCheck();
//     return res;
// }
// pub fn setCursorPosCallback(window: ?*Window, callback: CursorPosFun) CursorPosFun {
//     const res = c.glfwSetCursorPosCallback(window, callback);
//     internal.errorCheck();
//     return res;
// }
// pub fn setCursorEnterCallback(window: ?*Window, callback: CursorEnterFun) CursorEnterFun {
//     const res = c.glfwSetCursorEnterCallback(window, callback);
//     internal.errorCheck();
//     return res;
// }
// pub fn setScrollCallback(window: ?*Window, callback: ScrollFun) ScrollFun {
//     const res = c.glfwSetScrollCallback(window, callback);
//     internal.errorCheck();
//     return res;
// }
// pub fn setDropCallback(window: ?*Window, callback: DropFun) DropFun {
//     const res = c.glfwSetDropCallback(window, callback);
//     internal.errorCheck();
//     return res;
// }
//
// pub fn joystickPresent(jid: c_int) bool {
//     const res = c.glfwJoystickPresent(jid);
//     internal.errorCheck();
//     return res != 0;
// }
//
// pub fn getJoystickAxes(jid: c_int, count: *c_int) ?[*]const f32 {
//     const res = c.glfwGetJoystickAxes(jid, count);
//     internal.errorCheck();
//     return res;
// }
//
// pub fn getJoystickButtons(jid: c_int, count: *c_int) ?[*]const u8 {
//     const res = c.glfwGetJoystickButtons(jid, count);
//     internal.errorCheck();
//     return res;
// }
//
// pub fn getJoystickHats(jid: c_int, count: *c_int) ?[*]const u8 {
//     const res = c.glfwGetJoystickHats(jid, count);
//     internal.errorCheck();
//     return res;
// }
//
// pub fn getJoystickName(jid: c_int) ?[*:0]const u8 {
//     const res = c.glfwGetJoystickName(jid);
//     internal.errorCheck();
//     return res;
// }
//
// pub fn getJoystickGUID(jid: c_int) ?[*:0]const u8 {
//     const res = c.glfwGetJoystickGUID(jid);
//     internal.errorCheck();
//     return res;
// }
//
// pub fn setJoystickUserPointer(jid: c_int, pointer: *anyopaque) void {
//     const res = c.glfwSetJoystickUserPointer(jid, pointer);
//     internal.errorCheck();
//     return res;
// }
//
// pub fn getJoystickUserPointer(jid: c_int) *anyopaque {
//     const res = getJoystickUserPointer(jid);
//     internal.errorCheck();
//     return res;
// }
//
// pub fn joystickIsGamepad(jid: c_int) c_int {
//     const res = c.glfwJoystickIsGamepad(jid);
//     internal.errorCheck();
//     return res;
// }
//
// pub fn setJoystickCallback(callback: JoystickFun) JoystickFun {
//     const res = c.glfwSetJoystickCallback(callback);
//     internal.errorCheck();
//     return res;
// }
//
// pub fn updateGamepadMappings(string: [*:0]const u8) c_int {
//     const res = c.glfwUpdateGamepadMappings(string);
//     internal.errorCheck();
//     return res;
// }
//
// pub fn getGamepadName(jid: c_int) ?[*:0]const u8 {
//     const res = c.glfwGetGamepadName(jid);
//     internal.errorCheck();
//     return res;
// }
//
// pub fn getGamepadState(jid: c_int, state: ?*GamepadState) c_int {
//     const res = c.glfwGetGamepadState(jid, state);
//     internal.errorCheck();
//     return res;
// }
//
// pub fn setClipboardString(window: ?*Window, string: [*:0]const u8) void {
//     c.glfwSetClipboardString(window, string);
//     internal.errorCheck();
// }
//
// pub fn getClipboardString(window: ?*Window) ?[:0]const u8 {
//     const res = c.glfwGetClipboardString(window);
//     internal.errorCheck();
//     return std.mem.spanZ(res);
// }
//
// pub fn getTime() f64 {
//     const res = c.glfwGetTime();
//     internal.errorCheck();
//     return res;
// }
//
// pub fn setTime(time: f64) void {
//     c.glfwSetTime(time);
//     internal.errorCheck();
// }
//
// pub fn getTimerValue() u64 {
//     const res = c.glfwGetTimerValue();
//     internal.errorCheck();
//     return res;
// }
//
// pub fn getTimerFrequency() u64 {
//     const res = c.glfwGetTimerFrequency();
//     internal.errorCheck();
//     return res();
// }
//
// //Context
// pub fn makeContextCurrent(window: ?*Window) void {
//     c.glfwMakeContextCurrent(window);
//     internal.errorCheck();
// }
//
// pub fn getCurrentContext(window: ?*Window) ?*Window {
//     const res = c.glfwGetCurrentContext(window);
//     internal.errorCheck();
//     return res;
// }
//
// pub fn swapBuffers(window: ?*Window) void {
//     c.glfwSwapBuffers(window);
//     internal.errorCheck();
// }
//
// pub fn swapInterval(interval: c_int) void {
//     c.glfwSwapInterval(interval);
//     internal.errorCheck();
// }
//
// //GL Stuff
// pub fn extensionSupported(extension: [*:0]const u8) c_int {
//     const res = c.glfwExtensionSupported(extension);
//     internal.errorCheck();
//     return res;
// }
//
// pub fn getProcAddress(procname: [*:0]const u8) ?GLproc {
//     const res = c.glfwGetProcAddress(procname);
//     internal.errorCheck();
//     return res;
// }
//
// //Vulkan stuff
// pub fn getInstanceProcAddress(instance: VkInstance, procname: [*:0]const u8) ?VKproc {
//     const res = c.glfwGetInstanceProcAddress(instance, procname);
//     internal.errorCheck();
//     return res;
// }
//
// pub fn getPhysicalDevicePresentationSupport(instance: VkInstance, device: VkPhysicalDevice, queuefamily: u32) bool {
//     const res = c.glfwGetPhysicalDevicePresentationSupport(instance, device, queuefamily);
//     internal.errorCheck();
//     return res != 0;
// }
//
// pub fn createWindowSurface(instance: VkInstance, window: *Window, allocator: ?*const VkAllocationCallbacks, surface: *VkSurfaceKHR) VkResult {
//     const res = c.glfwCreateWindowSurface(instance, window, allocator, surface);
//     internal.errorCheck();
//     return res;
// }
//
// pub fn vulkanSupported() bool {
//     const res = c.glfwVulkanSupported();
//     internal.errorCheck();
//     return res != 0;
// }
//
// pub fn getRequiredInstanceExtensions(count: *u32) ?[*][*:0]const u8 {
//     const res = c.glfwGetRequiredInstanceExtensions(count);
//     internal.errorCheck();
//     return res;
// }
