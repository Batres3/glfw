const std = @import("std");
const builtin = @import("builtin");
pub const c = @cImport({
    @cInclude("glfw3.h");
});
const internal = @cImport(@cInclude("../../src/internal.h"));
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
        return err.toZigError(c.glfwGetError(&description));
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
// Utility structs for functions
pub const Position = struct { x: c_int, y: c_int };
pub const Size = struct { width: c_uint, height: c_uint };
pub const Workarea = struct { position: Position, size: Size };
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

fn requireInit() Error!void {
    if (internal._glfw.initialized == 0) return Error.NotInitialized;
}
/// This should not be used, one of the main benefits of using zig is precisely not needing to use this,
/// it is exposed in case someone needs it, but consider skipping this and simply using the given glfw functions,
/// which have included error checks ()
pub fn setErrorCallback(callback: c.GLFWerrorfun) c.GLFWerrorfun {
    return c.glfwSetErrorCallback(callback);
}

pub fn pollEvents() Error!void {
    try requireInit();
    internal._glfw.platform.pollEvents.?();
}

pub fn waitEvents() Error!void {
    try requireInit();
    internal._glfw.platform.waitEvents.?();
}

pub fn waitEventsTimeout(timeout: f64) Error!void {
    try requireInit();
    if (timeout != timeout or timeout < 0) return Error.InvalidValue;
    internal._glfw.platform.waitEventsTimeout.?(timeout);
}

pub fn postEmptyEvent() Error!void {
    try requireInit();
    internal._glfw.platform.postEmptyEvent.?();
}
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
