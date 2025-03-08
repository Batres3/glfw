const std = @import("std");
const internal = @import("internal.zig");
const _c = internal._c;
pub const build_options = @import("glfw_options");
pub const c = internal.c;
pub const Input = @import("input.zig");
pub const Hint = @import("hint.zig");
pub const Error = @import("error.zig").Error;

// Constants
pub const dont_care = -1;
// Utility structs for functions
pub const Size = struct { width: u32, height: u32 };
pub const VideoMode = struct { size: Size, bits: struct { r: c_int, g: c_int, b: c_int }, refreshRate: c_int };

pub const Monitor = @import("Monitor.zig");
pub const Window = @import("Window.zig");
pub const Cursor = @import("Cursor.zig");
pub const Joystick = @import("Joystick.zig");
pub const GammaRamp = @import("GammaRamp.zig");
pub const Image = @import("Image.zig");
/// This function should not be used directly
///
/// Checks the glfw error buffer and returns the appropriate zig error
pub fn errorCheck() Error!void {
    var description: [*c]const u8 = undefined;
    if (internal.err.toZigError(c.glfwGetError(&description))) |e| return e;
}
/// Holds the compile time version data of glfw
pub const version = struct {
    /// The major version number of the GLFW library.
    ///
    /// This is incremented when the API is changed in non-compatible ways.
    pub const major = c.GLFW_VERSION_MAJOR;
    /// The minor version number of the GLFW library.
    ///
    /// This is incremented when features are added to the API but it remains backward-compatible.
    pub const minor = c.GLFW_VERSION_MINOR;
    /// The revision number of the GLFW library.
    ///
    /// This is incremented when a bug fix release is made that does not contain any API changes.
    pub const revision = c.GLFW_VERSION_REVISION;
    /// Returns a string describing the compile-time configuration.
    ///
    /// This function returns the compile-time generated version string of the GLFW library binary. It
    /// describes the version, platform, compiler and any platform or operating system specific
    /// compile-time options. It should not be confused with the OpenGL or OpenGL ES version string,
    /// queried with `glGetString`.
    ///
    /// __Do not use the version string__ to parse the GLFW library version. Use the glfw.version
    /// constants instead.
    ///
    /// __Do not use the version string__ to parse what platforms are supported. The
    /// `glfw.platformSupported` function lets you query platform support.
    ///
    /// returns: The ASCII encoded GLFW version string.
    ///
    /// remark: This function may be called before @ref glfw.Init.
    ///
    /// pointer_lifetime: The returned string is static and compile-time generated.
    ///
    /// thread_safety: This function may be called from any thread.
    pub fn getString() [:0]const u8 {
        return std.mem.span(@as([*:0]const u8, @ptrCast(c.glfwGetVersionString())));
    }
};

/// Initialization hints for passing into glfw.init
pub const InitHints = struct {
    /// Specifies whether to also expose joystick hats as buttons, for compatibility with earlier
    /// versions of GLFW that did not have glfwGetJoystickHats.
    joystick_hat_buttons: bool = true,

    /// Specifies the platform to use for windowing and input
    platform: PlatformType = .any,

    /// Specifies the platform type (rendering backend) to request when using OpenGL ES and EGL via ANGLE.
    /// If the requested platform type is unavailable, ANGLE will use its default
    angle_patform: AnglePlatformType = .none,

    // Platform specific hints
    /// MacOS specifc hints. Ignored on other platforms
    cocoa: Cocoa = .{},
    /// Wayland specifc hints. Ignored on other platforms
    wayland: Wayland = .{},
    /// X11 specifc hints. Ignored on other platforms
    x11: X11 = .{},

    /// Angle platform type hints for glfw.InitHint.angle_platform_type
    pub const AnglePlatformType = enum(c_int) {
        none = c.GLFW_ANGLE_PLATFORM_TYPE_NONE,
        opengl = c.GLFW_ANGLE_PLATFORM_TYPE_OPENGL,
        opengles = c.GLFW_ANGLE_PLATFORM_TYPE_OPENGLES,
        d3d9 = c.GLFW_ANGLE_PLATFORM_TYPE_D3D9,
        d3d11 = c.GLFW_ANGLE_PLATFORM_TYPE_D3D11,
        vulkan = c.GLFW_ANGLE_PLATFORM_TYPE_VULKAN,
        metal = c.GLFW_ANGLE_PLATFORM_TYPE_METAL,
    };

    /// Platform type hints for glfw.InitHint.platform
    pub const PlatformType = enum(c_int) {
        /// Enables automatic platform detection.
        /// Will default to X11 on wayland.
        any = c.GLFW_ANY_PLATFORM,
        win32 = c.GLFW_PLATFORM_WIN32,
        cocoa = c.GLFW_PLATFORM_COCOA,
        wayland = c.GLFW_PLATFORM_WAYLAND,
        x11 = c.GLFW_PLATFORM_X11,
        null = c.GLFW_PLATFORM_NULL,
    };
    pub const Cocoa = struct {
        /// Specifies whether to set the current directory to the application to the Contents/Resources
        /// subdirectory of the application's bundle, if present.
        chdir_resources: bool = true,

        /// specifies whether to create a basic menu bar, either from a nib or manually, when the first
        /// window is created, which is when AppKit is initialized.
        menubar: bool = true,
    };
    pub const Wayland = struct {
        /// Wayland libdecor hints for glfw.InitHint.wayland_libdecor
        ///
        /// libdecor is important for GNOME, since GNOME does not implement server side decorations on
        /// wayland. libdecor is loaded dynamically at runtime, so in general enabling it is always
        /// safe to do. It is enabled by default.
        libdecor: LibdecorInitHint = .prefer,
        pub const LibdecorInitHint = enum(c_int) {
            prefer = c.GLFW_WAYLAND_PREFER_LIBDECOR,
            disable = c.GLFW_WAYLAND_DISABLE_LIBDECOR,
        };
    };
    pub const X11 = struct {
        xcb_vulkan_surface: bool = false,
    };

    pub fn set(hints: InitHints) void {
        const h = &_c._glfw.hints.init;
        h.hatButtons = @intFromBool(hints.joystick_hat_buttons);
        h.angleType = @intFromEnum(hints.angle_patform);
        h.platformID = @intFromEnum(hints.platform);
        h.ns.chdir = @intFromBool(hints.cocoa.chdir_resources);
        h.ns.menubar = @intFromBool(hints.cocoa.menubar);
        h.x11.xcbVulkanSurface = @intFromBool(hints.x11.xcb_vulkan_surface);
        h.wl.libdecorMode = @intFromEnum(hints.wayland.libdecor);
    }
};

/// Initializes the GLFW library.
///
/// This function initializes the GLFW library. Before most GLFW functions can be used, GLFW must
/// be initialized, and before an application terminates GLFW should be terminated in order to free
/// any resources allocated during or after initialization.
///
/// If this function fails, it calls glfw.Terminate before returning. If it succeeds, you should
/// call glfw.Terminate before the application exits.
///
/// Additional calls to this function after successful initialization but before termination will
/// return immediately with no error.
///
/// The glfw.InitHints.platform init hint controls which platforms are considered during
/// initialization. This also depends on which platforms the library was compiled to support.
///
/// macos: This function will change the current directory of the application to the
/// `Contents/Resources` subdirectory of the application's bundle, if present. This can be disabled
/// with `glfw.InitHint.cocoa.chdir_resources`.
///
/// macos: This function will create the main menu and dock icon for the application. If GLFW finds
/// a `MainMenu.nib` it is loaded and assumed to contain a menu bar. Otherwise a minimal menu bar is
/// created manually with common commands like Hide, Quit and About. The About entry opens a minimal
/// about dialog with information from the application's bundle. The menu bar and dock icon can be
/// disabled entirely with `glfw.InitHint.cocoa.menubar`.
///
/// x11: This function will set the `LC_CTYPE` category of the application locale according to the
/// current environment if that category is still "C".  This is because the "C" locale breaks
/// Unicode text input.
///
/// @thread_safety This function must only be called from the main thread.
pub fn init(hints: InitHints) InitError!void {
    hints.set();
    _ = c.glfwInit();
    try internal.subErrorCheck(InitError);
}
const InitError = error{ PlatformUnavailable, PlatformError };

/// Terminates the GLFW library.
///
/// This function destroys all remaining windows and cursors, restores any modified gamma ramps
/// and frees any other allocated resources. Once this function is called, you must again call
/// glfw.init successfully before you will be able to use most GLFW functions.
///
/// If GLFW has been successfully initialized, this function should be called before the
/// application exits. If initialization fails, there is no need to call this function, as it is
/// called by glfw.init before it returns failure.
///
/// This function has no effect if GLFW is not initialized.
///
/// warning: The contexts of any remaining windows must not be current on any other thread when
/// this function is called.
///
/// reentrancy: This function must not be called from a callback.
///
/// thread_safety: This function must only be called from the main thread.
pub fn deinit() void {
    internal.requireInit();
    c.glfwTerminate();
}

// TODO: implement custom allocator support
//
// /*! @brief Sets the init allocator to the desired value.
//  *
//  *  To use the default allocator, call this function with a `NULL` argument.
//  *
//  *  If you specify an allocator struct, every member must be a valid function
//  *  pointer.  If any member is `NULL`, this function emits @ref
//  *  GLFW_INVALID_VALUE and the init allocator is unchanged.
//  *
//  *  @param[in] allocator The allocator to use at the next initialization, or
//  *  `NULL` to use the default one.
//  *
//  *  @errors Possible errors include @ref GLFW_INVALID_VALUE.
//  *
//  *  @pointer_lifetime The specified allocator is copied before this function
//  *  returns.
//  *
//  *  @thread_safety This function must only be called from the main thread.
//  *
//  *  @sa @ref init_allocator
//  *  @sa @ref glfwInit
//  *
//  *  @since Added in version 3.4.
//  *
//  *  @ingroup init
//  */
// GLFWAPI void glfwInitAllocator(const GLFWallocator* allocator);

/// Returns the currently selected platform.
///
/// This function returns the platform that was selected during initialization. The returned value
/// will be one of `.win32`, `.cocoa`, `.wayland`, `.x11` or `.null`.
///
/// thread_safety: This function may be called from any thread.
pub fn getPlatform() InitHints.PlatformType {
    internal.requireInit();
    return @as(InitHints.PlatformType, @enumFromInt(c.glfwGetPlatform()));
}
/// Returns whether the library includes support for the specified platform.
///
/// This function returns whether the library was compiled with support for the specified platform.
/// The platform must be one of `.win32`, `.cocoa`, `.wayland`, `.x11` or `.null`.
///
/// remark: This function may be called before glfw.Init.
///
/// thread_safety: This function may be called from any thread.
pub fn platformSupported(platform: InitHints.PlatformType) bool {
    internal.requireInit();
    return c.glfwPlatformSupported(@intFromEnum(platform)) == c.GLFW_TRUE;
}

/// This should not be used, one of the main benefits of using zig is precisely not needing to use this,
/// it is exposed in case someone needs it, but consider skipping this and simply using the given glfw functions,
/// which have included error checks
pub fn setErrorCallback(callback: c.GLFWerrorfun) internal.c.GLFWerrorfun {
    return c.glfwSetErrorCallback(callback);
}

/// Processes all pending events.
///
/// This function processes only those events that are already in the event queue and then returns
/// immediately. Processing events will cause the window and input callbacks associated with those
/// events to be called.
///
/// On some platforms, a window move, resize or menu operation will cause event processing to
/// block. This is due to how event processing is designed on those platforms. You can use the
/// window refresh callback (see window_refresh) to redraw the contents of your window when
/// necessary during such operations.
///
/// Do not assume that callbacks you set will _only_ be called in response to event processing
/// functions like this one. While it is necessary to poll for events, window systems that require
/// GLFW to register callbacks of its own can pass events to GLFW in response to many window system
/// function calls. GLFW will pass those events on to the application callbacks before returning.
///
/// Event processing is not required for joystick input to work.
///
/// @reentrancy This function must not be called from a callback.
///
/// @thread_safety This function must only be called from the main thread.
pub fn pollEvents() void {
    internal.requireInit();
    _c._glfw.platform.pollEvents.?();
}

/// Waits until events are queued and processes them.
///
/// This function puts the calling thread to sleep until at least one event is available in the
/// event queue. Once one or more events are available, it behaves exactly like glfw.pollEvents,
/// i.e. the events in the queue are processed and the function then returns immediately.
/// Processing events will cause the window and input callbacks associated with those events to be
/// called.
///
/// Since not all events are associated with callbacks, this function may return without a callback
/// having been called even if you are monitoring all callbacks.
///
/// On some platforms, a window move, resize or menu operation will cause event processing to
/// block. This is due to how event processing is designed on those platforms. You can use the
/// window refresh callback (see window_refresh) to redraw the contents of your window when
/// necessary during such operations.
///
/// Do not assume that callbacks you set will _only_ be called in response to event processing
/// functions like this one. While it is necessary to poll for events, window systems that require
/// GLFW to register callbacks of its own can pass events to GLFW in response to many window system
/// function calls. GLFW will pass those events on to the application callbacks before returning.
///
/// Event processing is not required for joystick input to work.
///
/// @reentrancy This function must not be called from a callback.
///
/// @thread_safety This function must only be called from the main thread.
pub fn waitEvents() void {
    internal.requireInit();
    _c._glfw.platform.waitEvents.?();
}

/// Waits with timeout until events are queued and processes them.
///
/// This function puts the calling thread to sleep until at least one event is available in the
/// event queue, or until the specified timeout is reached. If one or more events are available, it
/// behaves exactly like glfw.pollEvents, i.e. the events in the queue are processed and the
/// function then returns immediately. Processing events will cause the window and input callbacks
/// associated with those events to be called.
///
/// The timeout value must be a positive finite number.
///
/// Since not all events are associated with callbacks, this function may return without a callback
/// having been called even if you are monitoring all callbacks.
///
/// On some platforms, a window move, resize or menu operation will cause event processing to
/// block. This is due to how event processing is designed on those platforms. You can use the
/// window refresh callback (see window_refresh) to redraw the contents of your window when
/// necessary during such operations.
///
/// Do not assume that callbacks you set will _only_ be called in response to event processing
/// functions like this one. While it is necessary to poll for events, window systems that require
/// GLFW to register callbacks of its own can pass events to GLFW in response to many window system
/// function calls. GLFW will pass those events on to the application callbacks before returning.
///
/// Event processing is not required for joystick input to work.
///
/// @param[in] timeout The maximum amount of time, in seconds, to wait.
///
/// @reentrancy This function must not be called from a callback.
///
/// @thread_safety This function must only be called from the main thread.
pub fn waitEventsTimeout(timeout: f64) Error!void {
    internal.requireInit();
    if (std.math.isNan(timeout) or timeout < 0 or timeout > std.math.floatMax(f64)) return Error.InvalidValue;
    _c._glfw.platform.waitEventsTimeout.?(timeout);
}

/// Posts an empty event to the event queue.
///
/// This function posts an empty event from the current thread to the event queue, causing
/// glfw.waitEvents or glfw.waitEventsTimeout to return.
///
/// @thread_safety This function may be called from any thread.
pub fn postEmptyEvent() void {
    internal.requireInit();
    _c._glfw.platform.postEmptyEvent.?();
}

/// Returns whether raw mouse motion is supported.
///
/// This function returns whether raw mouse motion is supported on the current system. This status
/// does not change after GLFW has been initialized so you only need to check this once. If you
/// attempt to enable raw motion on a system that does not support it, glfw.ErrorCode.PlatformError
/// will be emitted.
///
/// Raw mouse motion is closer to the actual motion of the mouse across a surface. It is not
/// affected by the scaling and acceleration applied to the motion of the desktop cursor. That
/// processing is suitable for a cursor while raw motion is better for controlling for example a 3D
/// camera. Because of this, raw mouse motion is only provided when the cursor is disabled.
///
/// @return `true` if raw mouse motion is supported on the current machine, or `false` otherwise.
///
/// @thread_safety This function must only be called from the main thread.
pub fn rawMouseMotionSupported() bool {
    internal.requireInit();
    return _c._glfw.platform.rawMouseMotionSupported.?() != 0;
}

/// Sets the clipboard to the specified string.
///
/// This function sets the system clipboard to the specified, UTF-8 encoded string.
///
/// @param[in] string A UTF-8 encoded string.
///
/// @pointer_lifetime The specified string is copied before this function returns.
///
/// @thread_safety This function must only be called from the main thread.
pub fn setClipboardString(string: [:0]const u8) void {
    internal.requireInit();
    _c._glfw.platform.setClipboardString.?(@ptrCast(string));
}

/// Returns the contents of the clipboard as a string.
///
/// This function returns the contents of the system clipboard, if it contains or is convertible to
/// a UTF-8 encoded string. If the clipboard is empty or if its contents cannot be converted,
/// glfw.ErrorCode.FormatUnavailable is returned.
///
/// @return The contents of the clipboard as a UTF-8 encoded string.
///
/// @pointer_lifetime The returned string is allocated and freed by GLFW. You should not free it
/// yourself. It is valid until the next call to glfw.getClipboardString or glfw.setClipboardString
/// or until the library is terminated.
///
/// @thread_safety This function must only be called from the main thread.
pub fn getClipboardString() []const u8 {
    internal.requireInit();
    return std.mem.span(@as([*:0]const u8, @ptrCast(_c._glfw.platform.getClipboardString.?())));
}

/// Sets the GLFW time.
///
/// This function sets the current GLFW time, in seconds. The value must be a positive finite
/// number less than or equal to 18446744073.0, which is approximately 584.5 years.
///
/// This function and @ref glfwGetTime are helper functions on top of glfw.getTimerFrequency and
/// glfw.getTimerValue.
///
/// @param[in] time The new value, in seconds.
///
/// Possible errors include glfw.ErrorCode.InvalidValue.
///
/// The upper limit of GLFW time is calculated as `floor((2^64 - 1) / 10^9)` and is due to
/// implementations storing nanoseconds in 64 bits. The limit may be increased in the future.
///
/// @thread_safety This function may be called from any thread. Reading and writing of the internal
/// base time is not atomic, so it needs to be externally synchronized with calls to glfw.getTime.
pub fn setTime(time: f64) !void {
    if (std.math.isNan(time) or time < 0 or time > @divTrunc(std.math.maxInt(u64), std.time.ns_per_s))
        return Error.InvalidValue;
    c.glfwSetTime(time);
}

/// Returns the GLFW time.
///
/// This function returns the current GLFW time, in seconds. Unless the time
/// has been set using @ref glfwSetTime it measures time elapsed since GLFW was
/// initialized.
///
/// This function and @ref glfwSetTime are helper functions on top of glfw.getTimerFrequency
/// and glfw.getTimerValue.
///
/// The resolution of the timer is system dependent, but is usually on the order
/// of a few micro- or nanoseconds. It uses the highest-resolution monotonic
/// time source on each supported operating system.
///
/// @return The current time, in seconds, or zero if an error occurred.
///
/// @thread_safety This function may be called from any thread. Reading and
/// writing of the internal base time is not atomic, so it needs to be
/// externally synchronized with calls to @ref glfwSetTime.
pub fn getTime() f64 {
    internal.requireInit();
    return c.glfwGetTime();
}

/// Returns the current value of the raw timer.
///
/// This function returns the current value of the raw timer, measured in `1/frequency` seconds. To
/// get the frequency, call glfw.getTimerFrequency.
///
/// @return The value of the timer, or zero if an error occurred.
///
/// @thread_safety This function may be called from any thread.
pub fn getTimerValue() u64 {
    internal.requireInit();
    return c.glfwGetTimerValue();
}

/// Returns the frequency, in Hz, of the raw timer.
///
/// This function returns the frequency, in Hz, of the raw timer.
///
/// @thread_safety This function may be called from any thread.
pub fn getTimerFrequency() u64 {
    internal.requireInit();
    return c.glfwGetTimerFrequency();
}
//
// Context
//
pub usingnamespace if (build_options.vulkan) @import("vulkan.zig") else @import("opengl.zig");
