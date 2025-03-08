//! Monitor type and related functions
const std = @import("std");
const internal = @import("internal.zig");
const c = internal.c;
const _c = internal._c;
const glfw = internal.glfw;
const Size = glfw.Size;
const Error = internal.Error;
const errorCheck = glfw.errorCheck;
const Monitor = @This();
const requireInit = internal.requireInit;

handle: *_c._GLFWmonitor = undefined,

/// This function should not be used directly.
///
/// Generates a glfw.Monitor given a C pointer to a monitor
pub fn init(glfw_handle: *c.GLFWmonitor) Monitor {
    return .{ .handle = glfw_handle };
}

/// Returns the currently connected monitors.
///
/// This function returns a slice of all currently connected monitors. The primary monitor is
/// always first. If no monitors were found, this function returns an empty slice.
///
/// The returned slice memory is owned by glfw. The underlying handles are owned by glfw, and
/// are valid until the monitor configuration changes or `glfw.deinit` is called.
///
/// @thread_safety This function must only be called from the main thread.
pub fn getAll() []Monitor {
    requireInit();
    const count: usize = @intCast(_c._glfw.monitorCount);
    const tmp: [*]Monitor = @ptrCast(@as([*c]*_c._GLFWmonitor, @ptrCast(_c._glfw.monitors)));
    return tmp[0..count];
}

/// Returns the primary monitor.
///
/// This function returns the primary monitor. This is usually the monitor where elements like
/// the task bar or global menu bar are located.
///
/// @thread_safety This function must only be called from the main thread.
pub fn getPrimary() Monitor {
    requireInit();
    return .{ .handle = _c._glfw.monitors[0] };
}

pub const Event = enum(c_int) {
    /// The device was connected
    connected = c.GLFW_CONNECTED,
    /// The device was connected
    disconnected = c.GLFW_DISCONNECTED,
};

/// Sets the monitor configuration callback.
///
/// This function sets the monitor configuration callback, or removes the currently set callback.
/// This is called when a monitor is connected to or disconnected from the system. Example:
///
/// `event` may be one of .connected or .disconnected.
///
/// @thread_safety This function must only be called from the main thread.
pub fn setCallback(callback: ?fn (monitor: Monitor, event: Event) void) void {
    requireInit();
    if (callback) |call| {
        const CWrapper = struct {
            pub fn monitorCallback(monitor: ?*c.GLFWmonitor, event: c_int) callconv(.C) void {
                @call(.always_inline, call, .{
                    Monitor{ .handle = @ptrCast(@alignCast(monitor.?)) },
                    @as(Event, @enumFromInt(event)),
                });
            }
        };
        // TODO: Why is this cast necessary?
        _c._glfw.callbacks.monitor = @ptrCast(&CWrapper.monitorCallback);
    } else _c._glfw.callbacks.monitor = null;
}

//
// Member functions
//

/// A monitor position, in screen coordinates, of the upper left corner of the monitor on the
/// virtual screen.
const Position = struct {
    /// The x coordinate.
    x: u32,
    /// The y coordinate.
    y: u32,
};
/// Returns the position of the monitor's viewport on the virtual screen.
///
/// @thread_safety This function must only be called from the main thread.
const SubErrors = error{PlatformError};
pub fn getPosition(self: Monitor) SubErrors!Position {
    requireInit();
    var xpos: c_int = 0;
    var ypos: c_int = 0;
    _c._glfw.platform.getMonitorPos.?(self.handle, &xpos, &ypos);
    try internal.subErrorCheck(SubErrors);
    return .{ .x = @intCast(xpos), .y = @intCast(ypos) };
}
/// The monitor workarea, in screen coordinates.
///
/// This is the position of the upper-left corner of the work area of the monitor, along with the
/// work area size. The work area is defined as the area of the monitor not occluded by the
/// window system task bar where present. If no task bar exists then the work area is the
/// monitor resolution in screen coordinates.
const Workarea = struct {
    position: Position,
    size: Size,
};

/// Retrieves the work area of the monitor.
///
/// @thread_safety This function must only be called from the main thread.
pub fn getWorkarea(self: Monitor) SubErrors!Workarea {
    requireInit();
    var xpos: c_int = 0;
    var ypos: c_int = 0;
    var xsize: c_int = 0;
    var ysize: c_int = 0;
    _c._glfw.platform.getMonitorWorkarea.?(self.handle, &xpos, &ypos, &xsize, &ysize);
    try internal.subErrorCheck(SubErrors);
    return .{
        .position = .{ .x = @intCast(xpos), .y = @intCast(ypos) },
        .size = .{ .width = @intCast(xsize), .height = @intCast(ysize) },
    };
}

/// The physical size, in millimetres, of the display area of a monitor.
const PhysicalSize = struct {
    width_mm: u32,
    height_mm: u32,
};

/// Returns the physical size of the monitor.
///
/// Some platforms do not provide accurate monitor size information, either because the monitor
/// [EDID](https://en.wikipedia.org/wiki/Extended_display_identification_data)
/// data is incorrect or because the driver does not report it accurately.
///
/// win32: On Windows 8 and earlier the physical size is calculated from
/// the current resolution and system DPI instead of querying the monitor EDID data
/// @thread_safety This function must only be called from the main thread.
pub fn getPhysicalSize(self: Monitor) PhysicalSize {
    requireInit();
    return .{ .width_mm = @intCast(self.handle.heightMM), .height_mm = @intCast(self.handle.widthMM) };
}

/// The content scale for a monitor.
///
/// This is the ratio between the current DPI and the platform's default DPI. This is especially
/// important for text and any UI elements. If the pixel dimensions of your UI scaled by this look
/// appropriate on your machine then it should appear at a reasonable size on other machines
/// regardless of their DPI and scaling settings. This relies on the system DPI and scaling
/// settings being somewhat correct.
///
/// The content scale may depend on both the monitor resolution and pixel density and on users
/// settings. It may be very different from the raw DPI calculated from the physical size and
/// current resolution.
const ContentScale = struct {
    x: f32,
    y: f32,
};

/// Returns the content scale for the monitor.
///
/// @thread_safety This function must only be called from the main thread.
pub fn getContentScale(self: Monitor) SubErrors!ContentScale {
    requireInit();
    var data: ContentScale = .{ .x = 0, .y = 0 };
    _c._glfw.platform.getMonitorContentScale.?(self.handle, &data.x, &data.y);
    try internal.subErrorCheck(SubErrors);
    return data;
}

/// Returns the name of the specified monitor.
///
/// This function returns a human-readable name, encoded as UTF-8, of the specified monitor. The
/// name typically reflects the make and model of the monitor and is not guaranteed to be unique
/// among the connected monitors.
///
/// @pointer_lifetime The returned string is allocated and freed by GLFW. You should not free it
/// yourself. It is valid until the specified monitor is disconnected or the library is terminated.
///
/// @thread_safety This function must only be called from the main thread.
pub fn getName(self: Monitor) []const u8 {
    requireInit();
    const len = std.mem.indexOfScalar(u8, &self.handle.name, 0).?;
    return self.handle.name[0..len];
}

/// Sets the user pointer of the specified monitor.
///
/// This function sets the user-defined pointer of the specified monitor. The current value is
/// retained until the monitor is disconnected.
///
/// This function may be called from the monitor callback, even for a monitor that is being
/// disconnected.
///
/// @thread_safety This function may be called from any thread. Access is not synchronized.
pub fn setUserPointer(self: Monitor, pointer: *anyopaque) void {
    self.handle.userPointer = pointer;
}

/// Returns the user pointer of the specified monitor.
///
/// This function returns the current value of the user-defined pointer of the specified monitor.
///
/// This function may be called from the monitor callback, even for a monitor that is being
/// disconnected.
///
/// @thread_safety This function may be called from any thread. Access is not synchronized.
pub fn getUserPointer(self: Monitor) ?*anyopaque {
    return self.handle.userPointer;
}
//
// Video modes
//
// TODO: Make a Zig implementation
// Defined in monitor.c
// extern fn refreshVideoModes(monitor: *_c._GLFWmonitor) callconv(.C) c_int;
// pub fn getVideoModes(self: *Monitor) Error!?[]c.GLFWvidmode {
//     requireInit();
//     if (refreshVideoModes(self.handle) == 0) return null;
//     const count: usize = @intCast(self.handle.modeCount);
//     const tmp: [*c]c.GLFWvidmode = @ptrCast(self.handle.modes);
//     return tmp[0..count];
// }
pub fn getVideoModes(self: Monitor) SubErrors![]const c.GLFWvidmode {
    requireInit();
    var count: c_int = 0;
    const res: [*c]const c.GLFWvidmode = @ptrCast(c.glfwGetVideoModes(@ptrCast(self.handle), &count));
    try internal.subErrorCheck(SubErrors);
    return res[0..@intCast(count)];
}
/// Returns the current mode of the specified monitor.
///
/// This function returns the current video mode of the specified monitor. If you have created a
/// full screen window for that monitor, the return value will depend on whether that window is
/// iconified.
///
/// @thread_safety This function must only be called from the main thread.
pub fn getVideoMode(self: Monitor) SubErrors!?glfw.VideoMode {
    requireInit();
    if (_c._glfw.platform.getVideoMode.?(self.handle, &self.handle.currentMode) == 0) return null;
    const current = self.handle.currentMode;
    try internal.subErrorCheck(SubErrors);
    return .{
        .size = .{ .width = @intCast(current.width), .height = @intCast(current.height) },
        .bits = .{ .r = current.redBits, .g = current.greenBits, .b = current.blueBits },
        .refreshRate = current.refreshRate,
    };
}
//
// Gamma
//
/// Generates a gamma ramp and sets it for the specified monitor.
///
/// This function generates an appropriately sized gamma ramp from the specified exponent and then
/// calls glfw.Monitor.setGammaRamp with it. The value must be a finite number greater than zero.
///
/// The software controlled gamma ramp is applied _in addition_ to the hardware gamma correction,
/// which today is usually an approximation of sRGB gamma. This means that setting a perfectly
/// linear ramp, or gamma 1.0, will produce the default (usually sRGB-like) behavior.
///
/// For gamma correct rendering with OpenGL or OpenGL ES, see the glfw.srgb_capable hint.
///
/// wayland: Gamma handling is privileged protocol, this function will thus never be implemented and
/// emits glfw.ErrorCode.FeatureUnavailable
///
/// @thread_safety This function must only be called from the main thread.
const GammaError = error{ PlatformError, FeatureUnavailable };
const SetGammaError = error{ PlatformError, FeatureUnavailable, InvalidValue };
pub fn setGamma(self: Monitor, gamma: f32) SetGammaError!void {
    requireInit();
    if (gamma < 0) return SetGammaError.InvalidValue;
    c.glfwSetGamma(@ptrCast(self.handle), gamma);
    try internal.subErrorCheck(SetGammaError);
}

/// Returns the current gamma ramp for the specified monitor.
///
/// This function returns the current gamma ramp of the specified monitor.
///
/// wayland: Gamma handling is a privileged protocol, this function will thus never be implemented
/// and returns glfw.ErrorCode.FeatureUnavailable.
///
/// The returned gamma ramp is owned by GLFW, and is valid until the monitor is
/// disconnected, this function is called again, or `glfw.deinit()` is called.
///
/// @thread_safety This function must only be called from the main thread.
pub fn getGammaRamp(self: Monitor) GammaError!?glfw.GammaRamp {
    requireInit();
    const res = c.glfwGetGammaRamp(@ptrCast(self.handle));
    try internal.subErrorCheck(GammaError);
    if (res) |ramp| return glfw.GammaRamp.fromC(ramp);
    return null;
}

/// Sets the current gamma ramp for the specified monitor.
///
/// This function sets the current gamma ramp for the specified monitor. The original gamma ramp
/// for that monitor is saved by GLFW the first time this function is called and is restored by
/// `glfw.deinit()`.
///
/// The software controlled gamma ramp is applied _in addition_ to the hardware gamma correction,
/// which today is usually an approximation of sRGB gamma. This means that setting a perfectly
/// linear ramp, or gamma 1.0, will produce the default (usually sRGB-like) behavior.
///
/// For gamma correct rendering with OpenGL or OpenGL ES, see the glfw.srgb_capable hint.
///
/// The size of the specified gamma ramp should match the size of the current ramp for that
/// monitor. On win32, the gamma ramp size must be 256.
///
/// wayland: Gamma handling is a privileged protocol, this function will thus never be implemented
/// and returns glfw.ErrorCode.FeatureUnavailable.
///
/// @pointer_lifetime The specified gamma ramp is copied before this function returns.
///
/// @thread_safety This function must only be called from the main thread.
pub fn setGammaRamp(self: Monitor, ramp: glfw.GammaRamp) GammaError!void {
    requireInit();

    if (self.handle.originalRamp.size == 0) {
        if (_c._glfw.platform.getGammaRamp.?(self.handle, &self.handle.originalRamp) == 0) return;
    }

    _c._glfw.platform.setGammaRamp.?(self.handle, @ptrCast(&ramp.toC()));
    try internal.subErrorCheck(GammaError);
}
