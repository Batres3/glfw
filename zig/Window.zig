const std = @import("std");
const internal = @import("internal.zig");
const input = @import("input.zig");
const c = internal.c;
const _c = internal._c;
const strncpy = @cImport(@cInclude("string.h")).strncpy;
const glfw = internal.glfw;
const Size = glfw.Size;
const Workarea = glfw.Workarea;
const Error = glfw.Error;
const Window = @This();
const Cursor = @import("Cursor.zig");
const Monitor = @import("Monitor.zig");
const errorCheck = glfw.errorCheck;
const requireInit = internal.requireInit;

handle: *_c._GLFWwindow = undefined,

// Static functions
/// Creates a window and its associated context.
///
/// This function creates a window and its associated OpenGL or OpenGL ES context. Most of the
/// options controlling how the window and its context should be created are specified with window
/// hints using `glfw.Window.Hints`.
///
/// Successful creation does not change which context is current. Before you can use the newly
/// created context, you need to make it current using `glfw.makeCurrentContext`. For
/// information about the `share` parameter, see context_sharing.
///
/// The created window, framebuffer and context may differ from what you requested, as not all
/// parameters and hints are hard constraints. This includes the size of the window, especially for
/// full screen windows. To query the actual attributes of the created window, framebuffer and
/// context, see glfw.Window.getAttrib, glfw.Window.getSize and glfw.window.getFramebufferSize.
///
/// To create a full screen window, you need to specify the monitor the window will cover. If no
/// monitor is specified, the window will be windowed mode. Unless you have a way for the user to
/// choose a specific monitor, it is recommended that you pick the primary monitor. For more
/// information on how to query connected monitors, see @ref monitor_monitors.
///
/// For full screen windows, the specified size becomes the resolution of the window's _desired
/// video mode_. As long as a full screen window is not iconified, the supported video mode most
/// closely matching the desired video mode is set for the specified monitor. For more information
/// about full screen windows, including the creation of so called _windowed full screen_ or
/// _borderless full screen_ windows, see window_windowed_full_screen.
///
/// Once you have created the window, you can switch it between windowed and full screen mode with
/// glfw.Window.setMonitor. This will not affect its OpenGL or OpenGL ES context.
///
/// By default, newly created windows use the placement recommended by the window system. To create
/// the window at a specific position, make it initially invisible using the `visible` window
/// hint, set its position and then show it.
///
/// As long as at least one full screen window is not iconified, the screensaver is prohibited from
/// starting.
///
/// Window systems put limits on window sizes. Very large or very small window dimensions may be
/// overridden by the window system on creation. Check the actual size after creation.
///
/// The swap interval is not set during window creation and the initial value may vary depending on
/// driver settings and defaults.
///
/// Possible errors include glfw.ErrorCode.InvalidEnum, glfw.ErrorCode.InvalidValue,
/// glfw.ErrorCode.APIUnavailable, glfw.ErrorCode.VersionUnavailable, glfw.ErrorCode.FormatUnavailable and
/// glfw.ErrorCode.PlatformError.
/// Returns null in the event of an error.
///
/// Parameters are as follows:
///
/// * `width` The desired width, in screen coordinates, of the window.
/// * `height` The desired height, in screen coordinates, of the window.
/// * `title` The initial, UTF-8 encoded window title.
/// * `monitor` The monitor to use for full screen mode, or `null` for windowed mode.
/// * `share` The window whose context to share resources with, or `null` to not share resources.
///
/// win32: Window creation will fail if the Microsoft GDI software OpenGL implementation is the
/// only one available.
///
/// win32: If the executable has an icon resource named `GLFW_ICON`, it will be set as the initial
/// icon for the window. If no such icon is present, the `IDI_APPLICATION` icon will be used
/// instead. To set a different icon, see glfw.Window.setIcon.
///
/// win32: The context to share resources with must not be current on any other thread.
///
/// macos: The OS only supports forward-compatible core profile contexts for OpenGL versions 3.2
/// and later. Before creating an OpenGL context of version 3.2 or later you must set the
/// `Hints.context.open_gl.forward_compat` and `Hints.context.open_gl.forward_compat` hints accordingly. OpenGL 3.0 and 3.1
/// contexts are not supported at all on macOS.
///
/// macos: The OS only supports core profile contexts for OpenGL versions 3.2 and later. Before
/// creating an OpenGL context of version 3.2 or later you must set the `Hints.context.open_gl.forward_compat` hint
/// accordingly. OpenGL 3.0 and 3.1 contexts are not supported at all on macOS.
///
/// macos: The GLFW window has no icon, as it is not a document window, but the dock icon will be
/// the same as the application bundle's icon. For more information on bundles, see the
/// [Bundle Programming Guide](https://developer.apple.com/library/mac/documentation/CoreFoundation/Conceptual/CFBundles/)
/// in the Mac Developer Library.
///
/// macos: On OS X 10.10 and later the window frame will not be rendered at full resolution on
/// Retina displays unless the glfw.cocoa_retina_framebuffer hint is true (1) and the `NSHighResolutionCapable`
/// key is enabled in the application bundle's `Info.plist`. For more information, see
/// [High Resolution Guidelines for OS X](https://developer.apple.com/library/mac/documentation/GraphicsAnimation/Conceptual/HighResolutionOSX/Explained/Explained.html)
/// in the Mac Developer Library. The GLFW test and example programs use a custom `Info.plist`
/// template for this, which can be found as `CMake/Info.plist.in` in the source tree.
///
/// macos: When activating frame autosaving with glfw.cocoa_frame_name, the specified window size
/// and position may be overridden by previously saved values.
///
/// x11: Some window managers will not respect the placement of initially hidden windows.
///
/// x11: Due to the asynchronous nature of X11, it may take a moment for a window to reach its
/// requested state. This means you may not be able to query the final size, position or other
/// attributes directly after window creation.
///
/// x11: The class part of the `WM_CLASS` window property will by default be set to the window title
/// passed to this function. The instance part will use the contents of the `RESOURCE_NAME`
/// environment variable, if present and not empty, or fall back to the window title. Set the Hints.x11.class_name
/// and Hints.x11.instance_name window hints to override this.
///
/// wayland: Compositors should implement the xdg-decoration protocol for GLFW to decorate the
/// window properly. If this protocol isn't supported, or if the compositor prefers client-side
/// decorations, a very simple fallback frame will be drawn using the wp_viewporter protocol. A
/// compositor can still emit close, maximize or fullscreen events, using for instance a keybind
/// mechanism. If neither of these protocols is supported, the window won't be decorated.
///
/// wayland: A full screen window will not attempt to change the mode, no matter what the
/// requested size or refresh rate.
///
/// wayland: Screensaver inhibition requires the idle-inhibit protocol to be implemented in the
/// user's compositor.
///
/// @thread_safety This function must only be called from the main thread.
pub fn init(width: u32, height: u32, title: [:0]const u8, monitor: ?Monitor, share: ?Window, hints: Hints) Error!Window {
    requireInit();
    hints.set();
    if (c.glfwCreateWindow(
        @as(c_int, @intCast(width)),
        @as(c_int, @intCast(height)),
        title,
        if (monitor) |m| @ptrCast(m.handle) else null,
        if (share) |w| @ptrCast(w.handle) else null,
    )) |handle| return .{ .handle = @ptrCast(@alignCast(handle)) };
    try glfw.errorCheck();
    return Error.PlatformError;
}

/// Destroys the specified window and its context.
///
/// This function destroys the specified window and its context. On calling this function, no
/// further callbacks will be called for that window.
///
/// If the context of the specified window is current on the main thread, it is detached before
/// being destroyed.
///
/// note: The context of the specified window must not be current on any other thread when this
/// function is called.
///
/// @reentrancy This function must not be called from a callback.
///
/// @thread_safety This function must only be called from the main thread.
pub fn deinit(self: Window) void {
    requireInit();
    c.glfwDestroyWindow(@ptrCast(self.handle));
}

/// Checks the close flag of the specified window.
///
/// This function returns the value of the close flag of the specified window.
///
/// @thread_safety This function may be called from any thread. Access is not synchronized.
pub fn shouldClose(self: Window) bool {
    requireInit();
    return self.handle.shouldClose != 0;
}

/// Sets the close flag of the specified window.
///
/// This function sets the value of the close flag of the specified window. This can be used to
/// override the user's attempt to close the window, or to signal that it should be closed.
///
/// @thread_safety This function may be called from any thread. Access is not
/// synchronized.
pub fn close(self: Window, value: bool) void {
    requireInit();
    self.handle.shouldClose = value;
}

/// This function gets the window title, encoded as UTF-8, of the specified window.
///
/// @thread_safety This function may be called from any thread.
pub fn getTitle(self: Window) []const u8 {
    requireInit();
    return std.mem.span(self.handle.title);
}

/// Try to avoid using this function, set the title on window creation.
///
/// This function sets the window title, encoded as UTF-8, of the specified window.
///
/// macos: The window title will not be updated until the next time you process events.
///
/// @thread_safety This function must only be called from the main thread.
const TitleError = error{PlatformError};
pub fn setTitle(self: Window, title: [:0]const u8) TitleError!void {
    requireInit();
    self.handle.title = _c._glfw_strdup(title);
    _c._glfw.platform.setWindowTitle.?(self.handle, title);
    try internal.subErrorCheck(TitleError);
}

/// Sets the icon for the specified window.
///
/// This function sets the icon of the specified window. If passed an array of candidate images,
/// those of or closest to the sizes desired by the system are selected. If no images are
/// specified, the window reverts to its default icon.
///
/// The pixels are 32-bit, little-endian, non-premultiplied RGBA, i.e. eight bits per channel with
/// the red channel first. They are arranged canonically as packed sequential rows, starting from
/// the top-left corner.
///
/// The desired image sizes varies depending on platform and system settings. The selected images
/// will be rescaled as needed. Good sizes include 16x16, 32x32 and 48x48.
///
/// @pointer_lifetime The specified image data is copied before this function returns.
///
/// macos: Regular windows do not have icons on macOS. This function will emit FeatureUnavailable.
/// The dock icon will be the same as the application bundle's icon. For more information on
/// bundles, see the [Bundle Programming Guide](https://developer.apple.com/library/mac/documentation/CoreFoundation/Conceptual/CFBundles/)
/// in the Mac Developer Library.
///
/// wayland: There is no existing protocol to change an icon, the window will thus inherit the one
/// defined in the application's desktop file. This function will emit glfw.ErrorCode.FeatureUnavailable.
///
/// Possible errors include glfw.ErrorCode.InvalidValue, glfw.ErrorCode.FeatureUnavailable
///
/// @thread_safety This function must only be called from the main thread.
pub fn setIcon(self: Window, images: []const c.GLFWimage) IFPError!void {
    requireInit();
    c.glfwSetWindowIcon(@ptrCast(self.handle), images.len, images);
    try internal.subErrorCheck(IFPError);
}

pub const Position = struct {
    x: i32,
    y: i32,
};
/// This function retrieves the position, in screen coordinates, of the upper-left corner of the content area of the specified window.
///
/// wayland: There is no way for an application to retrieve the global position of its windows,
/// this function will always emit glfw.Error.FeatureUnavailable.
///
/// @thread_safety This function must only be called from the main thread.
pub fn getPosition(self: Window) Position {
    requireInit();
    var xpos: c_int = 0;
    var ypos: c_int = 0;
    _c._glfw.platform.getWindowPos.?(self.handle, &xpos, &ypos);
    return .{ .x = @intCast(xpos), .y = @intCast(ypos) };
}

/// This function sets the position, in screen coordinates, of the upper-left corner of the content area
/// of the specified windowed mode window. If the window is a full screen window, this function does nothing.
///
/// __Do not use this function__ to move an already visible window unless you have very good reasons for doing so, as it will confuse and annoy the user.
///
/// The window manager may put limits on what positions are allowed. GLFW cannot and should not override these limits.
///
/// wayland: There is no way for an application to set the global position of its windows, this
/// function will always emit glfw.ErrorCode.FeatureUnavailable.
///
/// @thread_safety This function must only be called from the main thread.
pub fn setPosition(self: Window, pos: Position) void {
    requireInit();
    if (self.handle.monitor != null) return;
    _c._glfw.platform.setWindowPos.?(self.handle, @intCast(pos.x), @intCast(pos.y));
}

/// Retrieves the size of the content area of the specified window.
///
/// This function retrieves the size, in screen coordinates, of the content area of the specified
/// window. If you wish to retrieve the size of the framebuffer of the window in pixels, see
/// glfw.Window.getFramebufferSize.
///
/// @thread_safety This function must only be called from the main thread.
pub fn getSize(self: Window) Size {
    requireInit();
    var xsize: c_int = 0;
    var ysize: c_int = 0;
    _c._glfw.platform.getWindowSize.?(self.handle, &xsize, &ysize);
    // PlatformError
    internal.errorCheck();
    return .{ .width = @intCast(xsize), .height = @intCast(ysize) };
}

/// Sets the size of the content area of the specified window.
///
/// This function sets the size, in screen coordinates, of the content area of the specified window.
///
/// For full screen windows, this function updates the resolution of its desired video mode and
/// switches to the video mode closest to it, without affecting the window's context. As the
/// context is unaffected, the bit depths of the framebuffer remain unchanged.
///
/// If you wish to update the refresh rate of the desired video mode in addition to its resolution,
/// see glfw.Window.setMonitor.
///
/// The window manager may put limits on what sizes are allowed. GLFW cannot and should not
/// override these limits.
///
/// wayland: A full screen window will not attempt to change the mode, no matter what the requested
/// size.
///
/// @thread_safety This function must only be called from the main thread.
pub fn setSize(self: Window, size: Size) void {
    requireInit();
    self.handle.videoMode.width = @intCast(size.width);
    self.handle.videoMode.height = @intCast(size.height);

    _c._glfw.platform.setWindowSize.?(self.handle, self.handle.videoMode.width, self.handle.videoMode.height);
    internal.errorCheck(); // PlatformError
}

/// A size with option width/height, used to represent e.g. constraints on a windows size while
/// allowing specific axis to be unconstrained (null) if desired.
pub const SizeOptional = struct {
    width: ?u32 = null,
    height: ?u32 = null,
};

/// Sets the size limits of the specified window's content area.
///
/// This function sets the size limits of the content area of the specified window. If the window
/// is full screen, the size limits only take effect/ once it is made windowed. If the window is not
/// resizable, this function does nothing.
///
/// The size limits are applied immediately to a windowed mode window and may cause it to be resized.
///
/// The maximum dimensions must be greater than or equal to the minimum dimensions. glfw.dont_care
/// may be used for any width/height parameter.
///
/// If you set size limits and an aspect ratio that conflict, the results are undefined.
///
/// wayland: The size limits will not be applied until the window is actually resized, either by
/// the user or by the compositor.
///
/// @thread_safety This function must only be called from the main thread.
const IPError = error{ InvalidValue, PlatformError };
pub fn setSizeLimits(self: Window, min: SizeOptional, max: SizeOptional) IPError!void {
    requireInit();
    if (min.width != null and max.width != null and min.width.? <= max.width.?) return Error.InvalidValue;
    if (min.height != null and max.height != null and min.height.? <= max.height.?) return Error.InvalidValue;

    self.handle.maxwidth = if (max.width) |n| @intCast(n) else -1;
    self.handle.maxheight = if (max.height) |n| @intCast(n) else -1;
    self.handle.minwidth = if (min.width) |n| @intCast(n) else -1;
    self.handle.minheight = if (min.height) |n| @intCast(n) else -1;

    if (self.handle.monitor != null or self.handle.resizable != 0) return;

    _c._glfw.platform.setWindowSizeLimits.?(
        self.handle,
        self.handle.minwidth,
        self.handle.minheight,
        self.handle.maxwidth,
        self.handle.maxheight,
    );
    try internal.subErrorCheck(IPError);
}

/// Sets the aspect ratio of the specified window.
///
/// This function sets the required aspect ratio of the content area of the specified window. If
/// the window is full screen, the aspect ratio only takes effect once it is made windowed. If the
/// window is not resizable, this function does nothing.
///
/// The aspect ratio is specified as a numerator and a denominator and both values must be greater
/// than zero. For example, the common 16:9 aspect ratio is specified as 16 and 9, respectively.
///
/// If the numerator AND denominator is set to `null` then the aspect ratio limit is
/// disabled.
///
/// The aspect ratio is applied immediately to a windowed mode window and may cause it to be
/// resized.
///
/// If you set size limits and an aspect ratio that conflict, the results are undefined.
///
/// wayland: The aspect ratio will not be applied until the window is actually resized, either by
/// the user or by the compositor.
///
/// @thread_safety This function must only be called from the main thread.
///
/// WARNING: On Wayland the aspect ratio will not be applied until the window is resized
pub fn setAspectRatio(self: Window, numer: ?u32, denom: ?u32) void {
    requireInit();
    const n: c_int = if (numer) |num| @intCast(num) else -1;
    const d: c_int = if (denom) |num| @intCast(num) else -1;

    self.handle.numer = n;
    self.handle.denom = d;

    if (self.handle.monitor != null or self.handle.resizable == 0) return;
    _c._glfw.platform.setWindowAspectRatio.?(self.handle, n, d);
    internal.errorCheck(); // PlatformError
}

/// Retrieves the size of the framebuffer of the specified window.
///
/// This function retrieves the size, in pixels, of the framebuffer of the specified window.
/// If you wish to retrieve the size of the window in screen coordinates, see Window.getSize.
///
/// @thread_safety This function must only be called from the main thread.
pub fn getFramebufferSize(self: Window) Size {
    requireInit();
    var xsize: c_int = 0;
    var ysize: c_int = 0;
    _c._glfw.platform.getFramebufferSize.?(self.handle, &xsize, &ysize);
    return Size{ .width = @intCast(xsize), .height = @intCast(ysize) };
}

pub const FrameSize = struct {
    left: u32,
    top: u32,
    right: u32,
    bottom: u32,
};

/// Retrieves the size of the frame of the window.
///
/// This function retrieves the size, in screen coordinates, of each edge of the frame of the
/// specified window. This size includes the title bar, if the window has one. The size of the
/// frame may vary depending on the window-related hints used to create it.
///
/// Because this function retrieves the size of each window frame edge and not the offset along a
/// particular coordinate axis, the retrieved values will always be zero or positive.
///
/// @thread_safety This function must only be called from the main thread.
pub fn getFrameSize(self: Window) FrameSize {
    requireInit();
    var left: c_int = 0;
    var top: c_int = 0;
    var right: c_int = 0;
    var bottom: c_int = 0;
    _c._glfw.platform.getWindowFrameSize.?(self.handle, &left, &top, &right, &bottom);
    internal.errorCheck(); // PlatformError
    return FrameSize{
        .left = @as(u32, @intCast(left)),
        .top = @as(u32, @intCast(top)),
        .right = @as(u32, @intCast(right)),
        .bottom = @as(u32, @intCast(bottom)),
    };
}

pub const ContentScale = struct {
    x_scale: f32,
    y_scale: f32,
};

/// Retrieves the content scale for the specified window.
///
/// This function retrieves the content scale for the specified window. The content scale is the
/// ratio between the current DPI and the platform's default DPI. This is especially important for
/// text and any UI elements. If the pixel dimensions of your UI scaled by this look appropriate on
/// your machine then it should appear at a reasonable size on other machines regardless of their
/// DPI and scaling settings. This relies on the system DPI and scaling settings being somewhat
/// correct.
///
/// On platforms where each monitors can have its own content scale, the window content scale will
/// depend on which monitor the system considers the window to be on.
///
/// @thread_safety This function must only be called from the main thread.
pub fn getContentScale(self: Window) ContentScale {
    requireInit();
    var scale: ContentScale = .{ .x_scale = 0, .y_scale = 0 };
    _c._glfw.platform.getWindowContentScale.?(self.handle, &scale.x_scale, &scale.y_scale);
    internal.errorCheck(); // PlatformError
    return scale;
}

/// Returns the opacity of the whole window.
///
/// This function returns the opacity of the window, including any decorations.
///
/// The opacity (or alpha) value is a positive finite number between zero and one, where zero is
/// fully transparent and one is fully opaque. If the system does not support whole window
/// transparency, this function always returns one.
///
/// The initial opacity value for newly created windows is one.
///
/// Possible errors include glfw.ErrorCode.PlatformError.
/// Additionally returns a zero value in the event of an error.
///
/// @thread_safety This function must only be called from the main thread.
pub fn getOpacity(self: Window) f32 {
    requireInit();
    const res = _c._glfw.platform.getWindowOpacity.?(self.handle);
    internal.errorCheck(); // PlatformError
    return res;
}

/// Sets the opacity of the whole window.
///
/// This function sets the opacity of the window, including any decorations.
///
/// The opacity (or alpha) value is a positive finite number between zero and one, where zero is
/// fully transparent and one is fully opaque.
///
/// The initial opacity value for newly created windows is one.
///
/// A window created with framebuffer transparency may not use whole window transparency. The
/// results of doing this are undefined.
///
/// @thread_safety This function must only be called from the main thread.
///
/// wayland: There is no way to set opacity, this function will return glfw.Error.FeatureUnavailable
const IFPError = error{ InvalidValue, FeatureUnavailable, PlatformError };
pub fn setOpacity(self: Window, opacity: f32) IFPError!void {
    requireInit();
    if (opacity != opacity or opacity < 0 or opacity > 1) return Error.InvalidValue;
    _c._glfw.platform.setWindowOpacity.?(self.handle, opacity);
    try internal.subErrorCheck(IFPError);
}

/// Iconifies the specified window.
///
/// This function iconifies (minimizes) the specified window if it was previously restored. If the
/// window is already iconified, this function does nothing.
///
/// If the specified window is a full screen window, GLFW restores the original video mode of the
/// monitor. The window's desired video mode is set again when the window is restored.
///
/// wayland: Once a window is iconified, glfw.Window.restore won't be able to restore it. This is a design
/// decision of the xdg-shell protocol.
///
/// @thread_safety This function must only be called from the main thread.
pub fn iconify(self: Window) void {
    requireInit();
    _c._glfw.platform.iconifyWindow.?(self.handle);
    internal.errorCheck(); // PlatformError
}

pub fn isIconified(self: Window) bool {
    requireInit();
    return _c._glfw.platform.windowIconified.?(self.handle) != 0;
}

/// Restores the specified window.
///
/// This function restores the specified window if it was previously iconified (minimized) or
/// maximized. If the window is already restored, this function does nothing.
///
/// If the specified window is an iconified full screen window, its desired video mode is set
/// again for its monitor when the window is restored.
///
/// @thread_safety This function must only be called from the main thread.
pub fn restore(self: Window) void {
    requireInit();
    _c._glfw.platform.restoreWindow.?(self.handle);
    internal.errorCheck(); // PlatformError
}

/// Maximizes the specified window.
///
/// This function maximizes the specified window if it was previously not maximized. If the window
/// is already maximized, this function does nothing.
///
/// If the specified window is a full screen window, this function does nothing.
///
/// @thread_safety This function must only be called from the main thread.
pub fn maximize(self: Window) void {
    requireInit();
    if (self.handle.monitor != null) return;
    _c._glfw.platform.maximizeWindow.?(self.handle);
    internal.errorCheck(); // PlatformError
}

pub fn isMaximized(self: Window) bool {
    requireInit();
    return _c._glfw.platform.windowMaximized.?(self.handle) != 0;
}

/// Makes the specified window visible.
///
/// This function makes the specified window visible if it was previously hidden. If the window is
/// already visible or is in full screen mode, this function does nothing.
///
/// By default, windowed mode windows are focused when shown Set the glfw.focus_on_show window hint
/// to change this behavior for all newly created windows, or change the
/// behavior for an existing window with glfw.Window.setAttrib.
///
/// wayland: Because Wayland wants every frame of the desktop to be complete, this function does
/// not immediately make the window visible. Instead it will become visible the next time the window
/// framebuffer is updated after this call.
///
/// @thread_safety This function must only be called from the main thread.
pub fn show(self: Window) void {
    requireInit();
    if (self.handle.monitor != null) return;
    _c._glfw.platform.showWindow.?(self.handle);

    if (self.handle.focusOnShow != 0) self.focus();
    internal.errorCheck(); // PlatformError
}

pub fn isVisible(self: Window) bool {
    requireInit();
    return _c._glfw.platform.windowVisible.?(self.handle) != 0;
}

/// Hides the specified window.
///
/// This function hides the specified window if it was previously visible. If the window is already
/// hidden or is in full screen mode, this function does nothing.
///
/// @thread_safety This function must only be called from the main thread.
pub fn hide(self: Window) void {
    requireInit();
    if (self.handle.monitor != null) return;
    _c._glfw.platform.hideWindow.?(self.handle);
    internal.errorCheck(); // PlatformError
}

/// Brings the specified window to front and sets input focus.
///
/// This function brings the specified window to front and sets input focus. The window should
/// already be visible and not iconified.
///
/// By default, both windowed and full screen mode windows are focused when initially created. Set
/// the glfw.focused to disable this behavior.
///
/// Also by default, windowed mode windows are focused when shown with glfw.Window.show. Set the
/// glfw.focus_on_show to disable this behavior.
///
/// __Do not use this function__ to steal focus from other applications unless you are certain that
/// is what the user wants. Focus stealing can be extremely disruptive.
///
/// For a less disruptive way of getting the user's attention, see [attention requests (window_attention).
///
/// @thread_safety This function must only be called from the main thread.
pub fn focus(self: Window) void {
    requireInit();
    _c._glfw.platform.focusWindow.?(self.handle);
    internal.errorCheck(); // PlatformError
}

pub fn isFocused(self: Window) bool {
    requireInit();
    return _c._glfw.platform.windowFocused.?(self.handle) != 0;
}

pub fn isHovered(self: Window) bool {
    requireInit();
    return _c._glfw.platform.windowHovered.?(self.handle) != 0;
}

/// Requests user attention to the specified window.
///
/// This function requests user attention to the specified window. On platforms where this is not
/// supported, attention is requested to the application as a whole.
///
/// Once the user has given attention, usually by focusing the window or application, the system will end the request automatically.
///
/// macos: Attention is requested to the application as a whole, not the specific window.
///
/// @thread_safety This function must only be called from the main thread.
pub fn requestAttention(self: Window) void {
    requireInit();
    _c._glfw.platform.requestWindowAttention.?(self.handle);
    internal.errorCheck(); // PlatformError
}

/// Returns the monitor that the window uses for full screen mode.
///
/// This function returns the handle of the monitor that the specified window is in full screen on.
///
/// @return The monitor, or null if the window is in windowed mode.
pub fn getMonitor(self: Window) ?Monitor {
    requireInit();
    return .{ .handle = self.handle.monitor };
}

/// Sets the mode, monitor, video mode and placement of a window.
///
/// This function sets the monitor that the window uses for full screen mode or, if the monitor is
/// null, makes it windowed mode.
///
/// When setting a monitor, this function updates the width, height and refresh rate of the desired
/// video mode and switches to the video mode closest to it. The window position is ignored when
/// setting a monitor.
///
/// When the monitor is null, the position, width and height are used to place the window content
/// area. The refresh rate is ignored when no monitor is specified.
///
/// If you only wish to update the resolution of a full screen window or the size of a windowed
/// mode window, see window.setSize.
///
/// When a window transitions from full screen to windowed mode, this function restores any
/// previous window settings such as whether it is decorated, floating, resizable, has size or
/// aspect ratio limits, etc.
///
/// The OpenGL or OpenGL ES context will not be destroyed or otherwise affected by any resizing or
/// mode switching, although you may need to update your viewport if the framebuffer size has
/// changed.
///
/// wayland: The desired window position is ignored, as there is no way for an application to set
/// this property.
///
/// wayland: Setting the window to full screen will not attempt to change the mode, no matter what
/// the requested size or refresh rate.
///
/// @thread_safety This function must only be called from the main thread.
pub fn setMonitor(self: Window, monitor: ?*Monitor, pos: Position, size: Size, refreshRate: ?u32) void {
    requireInit();

    self.handle.videoMode.width = @intCast(size.width);
    self.handle.videoMode.height = @intCast(size.height);
    self.handle.videoMode.refreshRate = if (refreshRate) |rate| @intCast(rate) else -1;

    _c._glfw.platform.setWindowMonitor.?(
        self.handle,
        if (monitor) |m| m.handle else null,
        pos.x,
        pos.y,
        self.handle.videoMode.width,
        self.handle.videoMode.height,
        self.handle.videoMode.refreshRate,
    );

    internal.errorCheck(); // PlatformError
}

/// Sets the user pointer of the specified window.
///
/// This function sets the user-defined pointer of the specified window. The current value is
/// retained until the window is destroyed. The initial value is null.
///
/// @thread_safety This function may be called from any thread. Access is not synchronized.
pub fn setUserPointer(self: Window, pointer: *anyopaque) void {
    requireInit();
    self.handle.userPointer = pointer;
}

/// Returns the user pointer of the specified window.
///
/// This function returns the current value of the user-defined pointer of the specified window.
/// The initial value is null.
///
/// @thread_safety This function may be called from any thread. Access is not synchronized.
pub fn getUserPointer(self: Window) ?*anyopaque {
    requireInit();
    return self.handle.userPointer;
}

/// Window attributes
pub const Attrib = enum(c_int) {
    iconified = c.GLFW_ICONIFIED,
    resizable = c.GLFW_RESIZABLE,
    visible = c.GLFW_VISIBLE,
    decorated = c.GLFW_DECORATED,
    focused = c.GLFW_FOCUSED,
    auto_iconify = c.GLFW_AUTO_ICONIFY,
    floating = c.GLFW_FLOATING,
    maximized = c.GLFW_MAXIMIZED,
    transparent_framebuffer = c.GLFW_TRANSPARENT_FRAMEBUFFER,
    hovered = c.GLFW_HOVERED,
    focus_on_show = c.GLFW_FOCUS_ON_SHOW,
    mouse_passthrough = c.GLFW_MOUSE_PASSTHROUGH,
    doublebuffer = c.GLFW_DOUBLEBUFFER,

    client_api = c.GLFW_CLIENT_API,
    context_creation_api = c.GLFW_CONTEXT_CREATION_API,
    context_version_major = c.GLFW_CONTEXT_VERSION_MAJOR,
    context_version_minor = c.GLFW_CONTEXT_VERSION_MINOR,
    context_revision = c.GLFW_CONTEXT_REVISION,

    context_robustness = c.GLFW_CONTEXT_ROBUSTNESS,
    context_release_behavior = c.GLFW_CONTEXT_RELEASE_BEHAVIOR,
    context_no_error = c.GLFW_CONTEXT_NO_ERROR,
    context_debug = c.GLFW_CONTEXT_DEBUG,

    opengl_forward_compat = c.GLFW_OPENGL_FORWARD_COMPAT,
    opengl_profile = c.GLFW_OPENGL_PROFILE,
};
/// This function should not generally be used, window properties
/// can be accessed through the relevant function or through the handle
///
/// Returns an attribute of the specified window.
///
/// This function returns the value of an attribute of the specified window or its OpenGL or OpenGL
/// ES context.
///
/// wayland: The Wayland protocol provides no way to check whether a window is iconified, so
/// glfw.Window.Attrib.iconified always returns `false`.
pub fn getAttrib(self: Window, attrib: Attrib) Error!c_int {
    const res = c.glfwGetWindowAttrib(@ptrCast(self.handle), @intFromEnum(attrib));
    try errorCheck();
    return res;
}
/// This function should not generally be used, window properties
/// can be accessed through the relevant function or through the handle
/// /// This function sets the value of an attribute of the specified window.
///
/// The supported attributes are glfw.decorated, glfw.resizable, glfw.floating, glfw.auto_iconify,
/// glfw.focus_on_show.
///
/// Some of these attributes are ignored for full screen windows. The new value will take effect
/// if the window is later made windowed.
///
/// Some of these attributes are ignored for windowed mode windows. The new value will take effect
/// if the window is later made full screen.
///
/// @thread_safety This function must only be called from the main thread.
pub fn setAttrib(self: Window, attrib: Attrib, value: c_int) Error!void {
    c.glfwSetWindowAttrib(@ptrCast(self.handle), @intFromEnum(attrib), value);
    try errorCheck();
}

/// Returns a Zig GLFW window from an underlying C GLFW window handle.
pub fn from(handle: *anyopaque) Window {
    return Window{ .handle = @as(*_c._GLFWwindow, @ptrCast(@alignCast(handle))) };
}

/// Sets the position callback for the specified window.
///
/// This function sets the position callback of the specified window, which is called when the
/// window is moved. The callback is provided with the position, in screen coordinates, of the
/// upper-left corner of the content area of the window.
///
/// @param[in] callback The new callback, or null to remove the currently set callback.
///
/// @callback_param `window` the window that moved.
/// @callback_param `xpos` the new x-coordinate, in screen coordinates, of the upper-left corner of
/// the content area of the window.
/// @callback_param `ypos` the new y-coordinate, in screen coordinates, of the upper-left corner of
/// the content area of the window.
///
/// wayland: This callback will never be called, as there is no way for an application to know its
/// global position.
///
/// @thread_safety This function must only be called from the main thread.
pub inline fn setPosCallback(self: Window, comptime callback: ?fn (window: Window, pos: Position) void) void {
    requireInit();

    if (callback) |user_callback| {
        const CWrapper = struct {
            pub fn posCallbackWrapper(handle: ?*c.GLFWwindow, xpos: c_int, ypos: c_int) callconv(.C) void {
                @call(.always_inline, user_callback, .{
                    from(handle.?),
                    Position{
                        .x = @as(i32, @intCast(xpos)),
                        .y = @as(i32, @intCast(ypos)),
                    },
                });
            }
        };

        self.handle.callbacks.pos = CWrapper.posCallbackWrapper;
    } else {
        self.handle.callbacks.pos = null;
    }
}
/// Sets the size callback for the specified window.
///
/// This function sets the size callback of the specified window, which is called when the window
/// is resized. The callback is provided with the size, in screen coordinates, of the content area
/// of the window.
///
/// @callback_param `window` the window that was resized.
/// @callback_param `width` the new width, in screen coordinates, of the window.
/// @callback_param `height` the new height, in screen coordinates, of the window.
///
/// @thread_safety This function must only be called from the main thread.
///
/// see also: window_size
pub inline fn setSizeCallback(self: Window, comptime callback: ?fn (window: Window, size: Size) void) void {
    requireInit();

    if (callback) |user_callback| {
        const CWrapper = struct {
            pub fn sizeCallbackWrapper(handle: ?*c.GLFWwindow, width: c_int, height: c_int) callconv(.C) void {
                @call(.always_inline, user_callback, .{
                    from(handle.?),
                    Size{
                        .width = @as(u32, @intCast(width)),
                        .height = @as(u32, @intCast(height)),
                    },
                });
            }
        };

        self.handle.callbacks.size = CWrapper.sizeCallbackWrapper;
    } else {
        self.handle.callbacks.size = null;
    }
}

/// Sets the close callback for the specified window.
///
/// This function sets the close callback of the specified window, which is called when the user
/// attempts to close the window, for example by clicking the close widget in the title bar.
///
/// The close flag is set before this callback is called, but you can modify it at any time with
/// glfw.Window.close.
///
/// The close callback is not triggered by glfw.Window.deinit.
///
/// @param[in] window The window whose callback to set.
/// @param[in] callback The new callback, or null to remove the currently set callback.
///
/// @callback_param `window` the window that the user attempted to close.
///
/// macos: Selecting Quit from the application menu will trigger the close callback for all
/// windows.
///
/// @thread_safety This function must only be called from the main thread.
pub inline fn setCloseCallback(self: Window, comptime callback: ?fn (window: Window) void) void {
    requireInit();

    if (callback) |user_callback| {
        const CWrapper = struct {
            pub fn closeCallbackWrapper(handle: ?*c.GLFWwindow) callconv(.C) void {
                @call(.always_inline, user_callback, .{
                    from(handle.?),
                });
            }
        };

        self.handle.callbacks.close = CWrapper.closeCallbackWrapper;
    } else {
        self.handle.callbacks.close = null;
    }
}
/// Sets the refresh callback for the specified window.
///
/// This function sets the refresh callback of the specified window, which is
/// called when the content area of the window needs to be redrawn, for example
/// if the window has been exposed after having been covered by another window.
///
/// On compositing window systems such as Aero, Compiz, Aqua or Wayland, where
/// the window contents are saved off-screen, this callback may be called only
/// very infrequently or never at all.
///
/// @param[in] window The window whose callback to set.
/// @param[in] callback The new callback, or null to remove the currently set
/// callback.
///
/// @callback_param `window` the window whose content needs to be refreshed.
///
/// @thread_safety This function must only be called from the main thread.
pub inline fn setRefreshCallback(self: Window, comptime callback: ?fn (window: Window) void) void {
    requireInit();

    if (callback) |user_callback| {
        const CWrapper = struct {
            pub fn refreshCallbackWrapper(handle: ?*c.GLFWwindow) callconv(.C) void {
                @call(.always_inline, user_callback, .{
                    from(handle.?),
                });
            }
        };

        self.handle.callbacks.refresh = CWrapper.refreshCallbackWrapper;
    } else {
        self.handle.callbacks.refresh = null;
    }
}

/// Sets the focus callback for the specified window.
///
/// This function sets the focus callback of the specified window, which is
/// called when the window gains or loses input focus.
///
/// After the focus callback is called for a window that lost input focus,
/// synthetic key and mouse button release events will be generated for all such
/// that had been pressed. For more information, see window.setKeyCallback
/// and window.setMouseButtonCallback.
///
/// @param[in] window The window whose callback to set.
/// @param[in] callback The new callback, or null to remove the currently set
/// callback.
///
/// @callback_param `window` the window whose input focus has changed.
/// @callback_param `focused` `true` if the window was given input focus, or `false` if it lost it.
///
/// @thread_safety This function must only be called from the main thread.
pub inline fn setFocusCallback(self: Window, comptime callback: ?fn (window: Window, focused: bool) void) void {
    requireInit();

    if (callback) |user_callback| {
        const CWrapper = struct {
            pub fn focusCallbackWrapper(handle: ?*c.GLFWwindow, focused: c_int) callconv(.C) void {
                @call(.always_inline, user_callback, .{
                    from(handle.?),
                    focused == c.GLFW_TRUE,
                });
            }
        };

        self.handle.callbacks.focus = CWrapper.focusCallbackWrapper;
    } else {
        self.handle.callbacks.focus = null;
    }
}

/// Sets the iconify callback for the specified window.
///
/// This function sets the iconification callback of the specified window, which
/// is called when the window is iconified or restored.
///
/// @param[in] window The window whose callback to set.
/// @param[in] callback The new callback, or null to remove the currently set
/// callback.
///
/// @callback_param `window` the window which was iconified or restored.
/// @callback_param `iconified` `true` if the window was iconified, or `false` if it was restored.
///
/// @thread_safety This function must only be called from the main thread.
pub inline fn setIconifyCallback(self: Window, comptime callback: ?fn (window: Window, iconified: bool) void) void {
    requireInit();

    if (callback) |user_callback| {
        const CWrapper = struct {
            pub fn iconifyCallbackWrapper(handle: ?*c.GLFWwindow, iconified: c_int) callconv(.C) void {
                @call(.always_inline, user_callback, .{
                    from(handle.?),
                    iconified == c.GLFW_TRUE,
                });
            }
        };

        self.handle.callbacks.iconify = CWrapper.iconifyCallbackWrapper;
    } else {
        self.handle.callbacks.iconify = null;
    }
}

/// Sets the maximize callback for the specified window.
///
/// This function sets the maximization callback of the specified window, which
/// is called when the window is maximized or restored.
///
/// @param[in] window The window whose callback to set.
/// @param[in] callback The new callback, or null to remove the currently set
/// callback.
///
/// @callback_param `window` the window which was maximized or restored.
/// @callback_param `maximized` `true` if the window was maximized, or `false` if it was restored.
///
/// @thread_safety This function must only be called from the main thread.
pub inline fn setMaximizeCallback(self: Window, comptime callback: ?fn (window: Window, maximized: bool) void) void {
    requireInit();

    if (callback) |user_callback| {
        const CWrapper = struct {
            pub fn maximizeCallbackWrapper(handle: ?*c.GLFWwindow, maximized: c_int) callconv(.C) void {
                @call(.always_inline, user_callback, .{
                    from(handle.?),
                    maximized == c.GLFW_TRUE,
                });
            }
        };

        self.handle.callbacks.maximize = CWrapper.maximizeCallbackWrapper;
    } else {
        self.handle.callbacks.maximize = null;
    }
}

/// Sets the framebuffer resize callback for the specified window.
///
/// This function sets the framebuffer resize callback of the specified window,
/// which is called when the framebuffer of the specified window is resized.
///
/// @param[in] window The window whose callback to set.
/// @param[in] callback The new callback, or null to remove the currently set
/// callback.
///
/// @callback_param `window` the window whose framebuffer was resized.
/// @callback_param `width` the new width, in pixels, of the framebuffer.
/// @callback_param `height` the new height, in pixels, of the framebuffer.
///
/// @thread_safety This function must only be called from the main thread.
pub inline fn setFramebufferSizeCallback(self: Window, comptime callback: ?fn (window: Window, width: u32, height: u32) void) void {
    requireInit();

    if (callback) |user_callback| {
        const CWrapper = struct {
            pub fn framebufferSizeCallbackWrapper(handle: ?*c.GLFWwindow, width: c_int, height: c_int) callconv(.C) void {
                @call(.always_inline, user_callback, .{
                    from(handle.?),
                    @as(u32, @intCast(width)),
                    @as(u32, @intCast(height)),
                });
            }
        };

        self.handle.callbacks.fbsize = CWrapper.framebufferSizeCallbackWrapper;
    } else {
        self.handle.callbacks.fbsize = null;
    }
}

/// Sets the window content scale callback for the specified window.
///
/// This function sets the window content scale callback of the specified window,
/// which is called when the content scale of the specified window changes.
///
/// @param[in] window The window whose callback to set.
/// @param[in] callback The new callback, or null to remove the currently set
/// callback.
///
/// @callback_param `window` the window whose content scale changed.
/// @callback_param `scale` the new content scale of the window.
///
/// @thread_safety This function must only be called from the main thread.
pub inline fn setContentScaleCallback(self: Window, comptime callback: ?fn (window: Window, scale: ContentScale) void) void {
    requireInit();

    if (callback) |user_callback| {
        const CWrapper = struct {
            pub fn windowScaleCallbackWrapper(handle: ?*c.GLFWwindow, xscale: f32, yscale: f32) callconv(.C) void {
                @call(.always_inline, user_callback, .{
                    from(handle.?),
                    ContentScale{
                        .x_scale = xscale,
                        .y_scale = yscale,
                    },
                });
            }
        };

        self.handle.callbacks.scale = CWrapper.windowScaleCallbackWrapper;
    } else {
        self.handle.callbacks.scale = null;
    }
}

//
// Input
//
pub const InputMode = enum(c_int) {
    sticky_keys = c.GLFW_STICKY_KEYS,
    sticky_mouse_buttons = c.GLFW_STICKY_MOUSE_BUTTONS,
    lock_key_mods = c.GLFW_LOCK_KEY_MODS,
    unlimited_mouse_buttons = c.GLFW_UNLIMITED_MOUSE_BUTTONS,
    //RawMouseMotion = c.GLFW_RAW_MOUSE_MOTION,
    //Cursor = c.GLFW_CURSOR;
    pub const Cursor = enum(c_int) {
        /// Makes the cursor visible and behaving normally.
        normal = c.GLFW_CURSOR_NORMAL,
        /// Hides and grabs the cursor, providing virtual and unlimited cursor movement. This is useful
        /// for implementing for example 3D camera controls.
        disabled = c.GLFW_CURSOR_DISABLED,
        /// Makes the cursor invisible when it is over the content area of the window but does not
        /// restrict it from leaving.
        hidden = c.GLFW_CURSOR_HIDDEN,
        /// Makes the cursor visible but confines it to the content area of the window.
        captured = c.GLFW_CURSOR_CAPTURED,
    };
};
/// This function is valid for the hints in InputMode, for Cursor mode use set/getCursorMode
/// and for RawMouseMotion use set/getRawMouseMotion
pub fn setInputMode(self: Window, mode: InputMode, value: bool) void {
    requireInit();
    c.glfwSetInputMode(@ptrCast(self.handle), @intFromEnum(mode), @intFromBool(value));
}
/// This function is valid for the hints in InputMode, for Cursor mode use set/getCursorMode
/// and for RawMouseMotion use set/getRawMouseMotion
pub fn getInputMode(self: Window, mode: InputMode) bool {
    requireInit();
    const val = switch (mode) {
        .sticky_keys => self.handle.stickyKeys,
        .sticky_mouse_buttons => self.handle.stickyMouseButtons,
        .lock_key_mods => self.handle.lockKeyMods,
        .unlimited_mouse_buttons => self.handle.disableMouseButtonLimit,
    };
    return val != 0;
}
pub fn setCursorMode(self: Window, mode: InputMode.Cursor) void {
    requireInit();
    const m: c_int = @intFromEnum(mode);
    if (self.handle.cursorMode == m) return;

    _c._glfw.platform.getCursorPos.?(self.handle, &self.handle.virtualCursorPosX, &self.handle.virtualCursorPosY);
    _c._glfw.platform.setCursorMode.?(self.handle, m);
}
pub fn getCursorMode(self: Window) InputMode.Cursor {
    requireInit();
    return @enumFromInt(self.handle.cursorMode);
}
pub fn rawMouseMotionSupported() bool {
    requireInit();
    return _c._glfw.platform.rawMouseMotionSupported.?() != 0;
}
/// Sets whether the raw mouse motion input mode is enabled, if enabled unscaled and unaccelerated
/// mouse motion events will be sent, otherwise standard mouse motion events respecting the user's
/// OS settings will be sent.
///
/// If raw motion is not supported, attempting to set this will emit glfw.Error.FeatureUnavailable.
/// Call glfw.rawMouseMotionSupported to check for support.
pub fn setRawMouseMotion(self: Window, value: bool) !void {
    requireInit();
    if (!rawMouseMotionSupported()) return Error.FeatureUnavailable;
    const val: c_int = @intFromBool(value);
    if (self.handle.rawMouseMotion == val) return;

    self.handle.rawMouseMotion = val;
    _c._glfw.platform.setRawMouseMotion.?(self.handle, val);
}
/// Tells if the raw mouse motion input mode is enabled.
pub fn getRawMouseMotion(self: Window) bool {
    requireInit();
    return self.handle.rawMouseMotion != 0;
}

/// Returns the last reported press state of a keyboard key for the specified window.
///
/// This function returns the last press state reported for the specified key to the specified
/// window. The returned state is one of glfw.Input.Action.
///
/// * `glfw.Input.Action.repeat` is only reported to the key callback.
///
/// If the `glfw.sticky_keys` input mode is enabled, this function returns `glfw.Action.press` the
/// first time you call it for a key that was pressed, even if that key has already been released.
///
/// The key functions deal with physical keys, with key tokens (see keys) named after their use on
/// the standard US keyboard layout. If you want to input text, use the Unicode character callback
/// instead.
///
/// The modifier key bit masks (see mods) are not key tokens and cannot be used with this function.
///
/// __Do not use this function__ to implement text input, use glfw.Window.setCharCallback instead.
///
/// @param[in] window The desired window.
/// @param[in] key The desired keyboard key (see keys).
///
/// @thread_safety This function must only be called from the main thread.
pub fn getKey(self: Window, key: input.Key) input.Action {
    requireInit();
    const k: usize = @intCast(@intFromEnum(key));
    if (self.handle.keys[k] == 3) { // _GLFW_STICK
        // Sticky mode, so we release
        self.handle.keys[k] = @intFromEnum(input.Action.release);
        return .press;
    }
    return @enumFromInt(self.handle.keys[k]);
}

/// Returns the last reported state of a mouse button for the specified window.
///
/// This function returns whether the specified mouse button is pressed or not.
///
/// If the glfw.sticky_mouse_buttons input mode is enabled, this function returns `true` the first
/// time you call it for a mouse button that was pressed, even if that mouse button has already been
/// released.
///
/// @param[in] button The desired mouse button.
/// @return One of glfw.Input.Action
///
/// @thread_safety This function must only be called from the main thread.
pub fn getMouseButton(self: Window, key: input.Mouse) input.Action {
    requireInit();
    const k: usize = @intCast(@intFromEnum(key));
    if (self.handle.mouseButtons[k] == 3) {
        self.handle.mouseButtons[k] = @intFromEnum(input.Action.release);
        return .press;
    }
    return @enumFromInt(self.handle.mouseButtons[k]);
}

/// Sets the position of the cursor, relative to the content area of the window.
///
/// This function sets the position, in screen coordinates, of the cursor relative to the upper-left
/// corner of the content area of the specified window. The window must have input focus. If the
/// window does not have input focus when this function is called, it fails silently.
///
/// __Do not use this function__ to implement things like camera controls. GLFW already provides the
/// `InputMode.Cursor.disabled` cursor mode that hides the cursor, transparently re-centers it and
/// provides unconstrained cursor motion. See glfw.Window.setInputMode for more information.
///
/// If the cursor mode is `InputMode.Cursor.disabled` then the cursor position is unconstrained and
/// limited only by the minimum and maximum values of a `double`.
///
/// @param[in] window The desired window.
/// @param[in] xpos The desired x-coordinate, relative to the left edge of the content area.
/// @param[in] ypos The desired y-coordinate, relative to the top edge of the content area.
///
/// wayland: This function will only work when the cursor mode is `InputMode.Cursor.disabled`, otherwise
/// it will do nothing.
///
/// @thread_safety This function must only be called from the main thread.
pub fn setCursorPosition(self: Window, pos: glfw.Pos) !void {
    requireInit();
    if (pos.x != pos.x or pos.y != pos.y) return Error.InvalidValue;
    if (!self.isFocused()) return;

    if (self.handle.cursorMode == @intFromEnum(InputMode.Cursor.disabled)) {
        self.handle.virtualCursorPosX = pos.x;
        self.handle.virtualCursorPosY = pos.y;
    } else {
        _c._glfw.platform.setCursorPos.?(self.handle, pos.x, pos.y);
        internal.errorCheck();
    }
}

/// Retrieves the position of the cursor relative to the content area of the window.
///
/// This function returns the position of the cursor, in screen coordinates, relative to the
/// upper-left corner of the content area of the specified window.
///
/// If the cursor is disabled (with `InputMode.Cursor.disabled`) then the cursor position is unbounded
/// and limited only by the minimum and maximum values of a `f64`.
///
/// The coordinate can be converted to their integer equivalents with the `floor` function. Casting
/// directly to an integer type works for positive coordinates, but fails for negative ones.
///
/// Any or all of the position arguments may be null. If an error occurs, all non-null position
/// arguments will be set to zero.
///
/// @param[in] window The desired window.
/// @param[out] xpos Where to store the cursor x-coordinate, relative to the left edge of the
/// content area, or null.
/// @param[out] ypos Where to store the cursor y-coordinate, relative to the to top edge of the
/// content area, or null.
///
/// @thread_safety This function must only be called from the main thread.
pub fn getCursorPosition(self: Window) Cursor.Position {
    requireInit();
    if (self.handle.cursorMode == @intFromEnum(InputMode.Cursor.disabled)) {
        return .{ .x = self.handle.virtualCursorPosX, .y = self.handle.virtualCursorPosY };
    }
    var x: f64 = 0;
    var y: f64 = 0;
    _c._glfw.platform.getCursorPos.?(self.handle, &x, &y);
    internal.errorCheck();
    return .{ .x = x, .y = y };
}

/// Sets the cursor for the window.
///
/// This function sets the cursor image to be used when the cursor is over the content area of the
/// specified window. The set cursor will only be visible when the cursor mode (see cursor_mode) of
/// the window is `InputMode.Cursor.normal`.
///
/// On some platforms, the set cursor may not be visible unless the window also has input focus.
///
/// @param[in] cursor The cursor to set, or null to switch back to the default arrow cursor.
///
/// @thread_safety This function must only be called from the main thread.
pub fn setCursor(self: Window, cursor: ?Cursor) void {
    requireInit();
    if (cursor) |ptr| {
        self.handle.cursor = ptr.handle;
    } else self.handle.cursor = null;

    _c._glfw.platform.setCursor.?(self.handle, self.handle.cursor);
    internal.errorCheck();
}

/// Sets the key callback.
///
/// This function sets the key callback of the specified window, which is called when a key is
/// pressed, repeated or released.
///
/// The key functions deal with physical keys, with layout independent key tokens (see keys) named
/// after their values in the standard US keyboard layout. If you want to input text, use the
/// character callback (see glfw.Window.setCharCallback) instead.
///
/// When a window loses input focus, it will generate synthetic key release events for all pressed
/// keys. You can tell these events from user-generated events by the fact that the synthetic ones
/// are generated after the focus loss event has been processed, i.e. after the window focus
/// callback (see glfw.Window.setFocusCallback) has been called.
///
/// The scancode of a key is specific to that platform or sometimes even to that machine. Scancodes
/// are intended to allow users to bind keys that don't have a GLFW key token. Such keys have `key`
/// set to `glfw.key.unknown`, their state is not saved and so it cannot be queried with
/// glfw.Window.getKey.
///
/// Sometimes GLFW needs to generate synthetic key events, in which case the scancode may be zero.
///
/// @param[in] window The window whose callback to set.
/// @param[in] callback The new key callback, or null to remove the currently set callback.
///
/// @callback_param[in] window The window that received the event.
/// @callback_param[in] key The keyboard key (see keys) that was pressed or released.
/// @callback_param[in] scancode The platform-specific scancode of the key.
/// @callback_param[in] action `glfw.Action.press`, `glfw.Action.release` or `glfw.Action.repeat`.
/// Future releases may add more actions.
/// @callback_param[in] mods Bit field describing which modifier keys (see mods) were held down.
///
/// @thread_safety This function must only be called from the main thread.
pub inline fn setKeyCallback(self: Window, comptime callback: ?fn (window: Window, key: input.Key, scancode: i32, action: input.Action, mods: input.Modifier) void) void {
    requireInit();

    if (callback) |user_callback| {
        const CWrapper = struct {
            pub fn keyCallbackWrapper(handle: ?*c.GLFWwindow, key: c_int, scancode: c_int, action: c_int, mods: c_int) callconv(.C) void {
                @call(.always_inline, user_callback, .{
                    from(handle.?),
                    @as(input.Key, @enumFromInt(key)),
                    @as(i32, @intCast(scancode)),
                    @as(input.Action, @enumFromInt(action)),
                    @as(input.Modifier, @enumFromInt(mods)),
                    input.Modifier.fromInt(mods),
                });
            }
        };

        self.handle.callbacks.key = CWrapper.keyCallbackWrapper;
    } else {
        self.handle.callbacks.key = null;
    }
}

/// Sets the Unicode character callback.
///
/// This function sets the character callback of the specified window, which is called when a
/// Unicode character is input.
///
/// The character callback is intended for Unicode text input. As it deals with characters, it is
/// keyboard layout dependent, whereas the key callback (see glfw.Window.setKeyCallback) is not.
/// Characters do not map 1:1 to physical keys, as a key may produce zero, one or more characters.
/// If you want to know whether a specific physical key was pressed or released, see the key
/// callback instead.
///
/// The character callback behaves as system text input normally does and will not be called if
/// modifier keys are held down that would prevent normal text input on that platform, for example a
/// Super (Command) key on macOS or Alt key on Windows.
///
/// @param[in] window The window whose callback to set.
/// @param[in] callback The new callback, or null to remove the currently set callback.
///
/// @callback_param[in] window The window that received the event.
/// @callback_param[in] codepoint The Unicode code point of the character.
///
/// @thread_safety This function must only be called from the main thread.
pub inline fn setCharCallback(self: Window, comptime callback: ?fn (window: Window, codepoint: u21) void) void {
    requireInit();

    if (callback) |user_callback| {
        const CWrapper = struct {
            pub fn charCallbackWrapper(handle: ?*c.GLFWwindow, codepoint: c_uint) callconv(.C) void {
                @call(.always_inline, user_callback, .{
                    from(handle.?),
                    @as(u21, @intCast(codepoint)),
                });
            }
        };

        self.handle.callbacks.character = CWrapper.charCallbackWrapper;
    } else {
        self.handle.callbacks.character = null;
    }
}

pub fn setCharModsCallback(self: Window, callback: c.GLFWcharmodsfun) void {
    requireInit();
    self.handle.callbacks.charmods = callback;
}

/// Sets the mouse button callback.
///
/// This function sets the mouse button callback of the specified window, which is called when a
/// mouse button is pressed or released.
///
/// When a window loses input focus, it will generate synthetic mouse button release events for all
/// pressed mouse buttons. You can tell these events from user-generated events by the fact that the
/// synthetic ones are generated after the focus loss event has been processed, i.e. after the
/// window focus callback (see glfw.Window.setFocusCallback) has been called.
///
/// @param[in] window The window whose callback to set.
/// @param[in] callback The new callback, or null to remove the currently set callback.
///
/// @callback_param[in] window The window that received the event.
/// @callback_param[in] button The mouse button that was pressed or released.
/// @callback_param[in] action One of `glfw.Action.press` or `glfw.Action.release`. Future releases
/// may add more actions.
/// @callback_param[in] mods Bit field describing which modifier keys (see mods) were held down.
///
/// @thread_safety This function must only be called from the main thread.
pub inline fn setMouseButtonCallback(self: Window, comptime callback: ?fn (window: Window, button: input.Mouse, action: input.Action, mods: input.Modifier) void) void {
    requireInit();

    if (callback) |user_callback| {
        const CWrapper = struct {
            pub fn mouseButtonCallbackWrapper(handle: ?*c.GLFWwindow, button: c_int, action: c_int, mods: c_int) callconv(.C) void {
                @call(.always_inline, user_callback, .{
                    from(handle.?),
                    @as(input.MouseButton, @enumFromInt(button)),
                    @as(input.Action, @enumFromInt(action)),
                    input.Modifier.fromInt(mods),
                });
            }
        };

        self.handle.callbacks.mouseButton = CWrapper.mouseButtonCallbackWrapper;
    } else {
        self.handle.callbacks.mouseButton = null;
    }
}

/// Sets the cursor position callback.
///
/// This function sets the cursor position callback of the specified window, which is called when
/// the cursor is moved. The callback is provided with the position, in screen coordinates, relative
/// to the upper-left corner of the content area of the window.
///
/// @param[in] callback The new callback, or null to remove the currently set callback.
///
/// @callback_param[in] window The window that received the event.
/// @callback_param[in] xpos The new cursor x-coordinate, relative to the left edge of the content
/// area.
/// callback_@param[in] ypos The new cursor y-coordinate, relative to the top edge of the content
/// area.
///
/// @thread_safety This function must only be called from the main thread.
pub inline fn setCursorPosCallback(self: Window, comptime callback: ?fn (window: Window, pos: Cursor.Position) void) void {
    requireInit();

    if (callback) |user_callback| {
        const CWrapper = struct {
            pub fn cursorPosCallbackWrapper(handle: ?*c.GLFWwindow, xpos: f64, ypos: f64) callconv(.C) void {
                @call(.always_inline, user_callback, .{
                    from(handle.?),
                    Cursor.Position{
                        .x = xpos,
                        .y = ypos,
                    },
                });
            }
        };

        self.handle.callbacks.cursorPos = CWrapper.cursorPosCallbackWrapper;
    } else {
        self.handle.callbacks.cursorPos = null;
    }
}

/// Sets the cursor enter/leave callback.
///
/// This function sets the cursor boundary crossing callback of the specified window, which is
/// called when the cursor enters or leaves the content area of the window.
///
/// @param[in] callback The new callback, or null to remove the currently set callback.
///
/// @callback_param[in] window The window that received the event.
/// @callback_param[in] entered `true` if the cursor entered the window's content area, or `false`
/// if it left it.
///
/// @thread_safety This function must only be called from the main thread.
pub inline fn setCursorEnterCallback(self: Window, comptime callback: ?fn (window: Window, entered: bool) void) void {
    requireInit();

    if (callback) |user_callback| {
        const CWrapper = struct {
            pub fn cursorEnterCallbackWrapper(handle: ?*c.GLFWwindow, entered: c_int) callconv(.C) void {
                @call(.always_inline, user_callback, .{
                    from(handle.?),
                    entered == c.GLFW_TRUE,
                });
            }
        };

        self.handle.callbacks.cursorEnter = CWrapper.cursorEnterCallbackWrapper;
    } else {
        self.handle.callbacks.cursorEnter = null;
    }
}

/// Sets the scroll callback.
///
/// This function sets the scroll callback of the specified window, which is called when a scrolling
/// device is used, such as a mouse wheel or scrolling area of a touchpad.
///
/// The scroll callback receives all scrolling input, like that from a mouse wheel or a touchpad
/// scrolling area.
///
/// @param[in] window The window whose callback to set.
/// @param[in] callback The new scroll callback, or null to remove the currently set callback.
///
/// @callback_param[in] window The window that received the event.
/// @callback_param[in] xoffset The scroll offset along the x-axis.
/// @callback_param[in] yoffset The scroll offset along the y-axis.
///
/// @thread_safety This function must only be called from the main thread.
pub inline fn setScrollCallback(self: Window, comptime callback: ?fn (window: Window, offset: Cursor.Position) void) void {
    requireInit();

    if (callback) |user_callback| {
        const CWrapper = struct {
            pub fn scrollCallbackWrapper(handle: ?*c.GLFWwindow, xoffset: f64, yoffset: f64) callconv(.C) void {
                @call(.always_inline, user_callback, .{
                    from(handle.?),
                    Cursor.Position{
                        .x = xoffset,
                        .y = yoffset,
                    },
                });
            }
        };

        self.handle.callbacks.scroll = CWrapper.scrollCallbackWrapper;
    } else {
        self.handle.callbacks.scroll = null;
    }
}

/// Sets the path drop callback.
///
/// This function sets the path drop callback of the specified window, which is called when one or
/// more dragged paths are dropped on the window.
///
/// Because the path array and its strings may have been generated specifically for that event, they
/// are not guaranteed to be valid after the callback has returned. If you wish to use them after
/// the callback returns, you need to make a deep copy.
///
/// @param[in] callback The new file drop callback, or null to remove the currently set callback.
///
/// @callback_param[in] window The window that received the event.
/// @callback_param[in] path_count The number of dropped paths.
/// @callback_param[in] paths The UTF-8 encoded file and/or directory path names.
///
/// @callback_pointer_lifetime The path array and its strings are valid until the callback function
/// returns.
///
/// wayland: File drop is currently unimplemented.
///
/// @thread_safety This function must only be called from the main thread.
pub inline fn setDropCallback(self: Window, comptime callback: ?fn (window: Window, paths: [][*:0]const u8) void) void {
    requireInit();

    if (callback) |user_callback| {
        const CWrapper = struct {
            pub fn dropCallbackWrapper(handle: ?*c.GLFWwindow, path_count: c_int, paths: [*c][*c]const u8) callconv(.C) void {
                @call(.always_inline, user_callback, .{
                    from(handle.?),
                    @as([*][*:0]const u8, @ptrCast(paths))[0..@as(u32, @intCast(path_count))],
                });
            }
        };

        self.handle.callbacks.drop = CWrapper.dropCallbackWrapper;
    } else {
        self.handle.callbacks.drop = null;
    }
}

//
// Context
//

pub fn makeCurrentContext(self: Window) !void {
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

pub fn swapBuffers(self: Window) !void {
    requireInit();
    if (self.handle.context.client == @intFromEnum(glfw.Hint.Context.API.Client.Value.NoAPI))
        return Error.NoWindowContext;

    self.handle.context.swapBuffers(self.handle);
}
//
// Hints
//
const Hint = enum(c_int) {
    focused = c.GLFW_FOCUSED,
    iconified = c.GLFW_ICONIFIED,
    visible = c.GLFW_VISIBLE,
    decorated = c.GLFW_DECORATED,
    resizable = c.GLFW_RESIZABLE,
    auto_iconify = c.GLFW_AUTO_ICONIFY,
    floating = c.GLFW_FLOATING,
    maximized = c.GLFW_MAXIMIZED,
    center_cursor = c.GLFW_CENTER_CURSOR,
    hovered = c.GLFW_HOVERED,
    focus_on_show = c.GLFW_FOCUS_ON_SHOW,
    //Titlebar = c.GLFW_TITLEBAR,
    mouse_passthrough = c.GLFW_MOUSE_PASSTHROUGH,
    refresh_rate = c.GLFW_REFRESH_RATE,
    pub const Bits = enum(c_int) {
        red = c.GLFW_RED_BITS,
        green = c.GLFW_GREEN_BITS,
        blue = c.GLFW_BLUE_BITS,
        alpha = c.GLFW_ALPHA_BITS,
        depth = c.GLFW_DEPTH_BITS,
        stencil = c.GLFW_STENCIL_BITS,
        pub const Accumulate = enum(c_int) {
            red = c.GLFW_ACCUM_RED_BITS,
            green = c.GLFW_ACCUM_GREEN_BITS,
            blue = c.GLFW_ACCUM_BLUE_BITS,
            alpha = c.GLFW_ACCUM_ALPHA_BITS,
        };
    };
    /// Framebuffer hints
    pub const Framebuffer = enum(c_int) {
        transparent = c.GLFW_TRANSPARENT_FRAMEBUFFER,
        aux_buffers = c.GLFW_AUX_BUFFERS,
        stereo = c.GLFW_STEREO,
        samples = c.GLFW_SAMPLES,
        srgb_capable = c.GLFW_SRGB_CAPABLE,
        doublebuffer = c.GLFW_DOUBLEBUFFER,
        scale = c.GLFW_SCALE_FRAMEBUFFER,
    };
    /// Context hints
    pub const Context = enum(c_int) {
        revision = c.GLFW_CONTEXT_REVISION,
        debug = c.GLFW_CONTEXT_DEBUG,
        no_error = c.GLFW_CONTEXT_NO_ERROR,
        scale_to_monitor = c.GLFW_SCALE_TO_MONITOR,
        pub const API = struct {
            pub const Client = struct {
                pub const Value = enum(c_int) {
                    no_api = c.GLFW_NO_API,
                    open_gl = c.GLFW_OPENGL_API,
                    open_gles = c.GLFW_OPENGL_ES_API,
                };
            };
            pub const Creation = enum(c_int) {
                pub const Value = enum(c_int) {
                    native = c.GLFW_NATIVE_CONTEXT_API,
                    egl = c.GLFW_EGL_CONTEXT_API,
                    osmesa = c.GLFW_OSMESA_CONTEXT_API,
                };
            };
        };
        pub const Version = enum(c_int) {
            major = c.GLFW_CONTEXT_VERSION_MAJOR,
            minor = c.GLFW_CONTEXT_VERSION_MINOR,
            revision = c.GLFW_CONTEXT_REVISION,
        };
        pub const OpenGL = enum(c_int) {
            forward_compat = c.GLFW_OPENGL_FORWARD_COMPAT,
            /// This is deprecated, use Context.Debug instead
            debug_context = c.GLFW_OPENGL_DEBUG_CONTEXT,
        };
    };
    pub const Win32 = enum(c_int) {
        keyboard_menu = c.GLFW_WIN32_KEYBOARD_MENU,
        show_default = c.GLFW_WIN32_SHOWDEFAULT,
    };
    pub const Cocoa = enum(c_int) {
        graphics_switching = c.GLFW_COCOA_GRAPHICS_SWITCHING,
        frame_name = c.GLFW_COCOA_FRAME_NAME,
    };
    pub const X11 = enum(c_int) {
        class_name = c.GLFW_X11_CLASS_NAME,
        instance_name = c.GLFW_X11_INSTANCE_NAME,
    };
    pub const Wayland = enum(c_int) {
        app_id = c.GLFW_WAYLAND_APP_ID,
    };
};

pub const Hints = struct {
    /// Specifies whether the windowed mode window will be resizable by the user.
    /// The window will still be resizable using the .setSize function.
    /// This hint is ignored for full screen and undecorated windows.
    resizable: bool = true,
    /// Specifies whether the windowed mode window will be initially visible.
    /// This hint is ignored for full screen windows.
    visible: bool = true,
    /// Specifies whether the windowed mode window will have window decorations such as a border, a close widget, etc.
    /// An undecorated window will not be resizable by the user but will still allow the user to generate close events on some platforms.
    /// This hint is ignored for full screen windows.
    decorated: bool = true,
    /// Specifies whether the windowed mode window will be given input focus when created.
    /// This hint is ignored for full screen and initially hidden windows.
    focused: bool = true,
    /// Specifies whether the full screen window will automatically iconify and restore the previous video mode on input focus loss.
    /// This hint is ignored for windowed mode windows.
    auto_iconify: bool = true,
    /// Specifies whether the windowed mode window will be floating above other regular windows, lso called topmost or always-on-top.
    /// This is intended primarily for debugging purposes and cannot be used to implement proper full screen windows.
    /// This hint is ignored for full screen windows.
    floating: bool = false,
    /// Specifies whether the windowed mode window will be maximized when created.
    /// This hint is ignored for full screen windows.
    maximized: bool = false,
    /// Specifies whether the cursor should be centered over newly created full screen windows.
    /// This hint is ignored for windowed mode windows.
    center_cursor: bool = true,
    /// Specifies whether the window will be given input focus when glfwShowWindow is called.
    focus_on_show: bool = true,
    /// Specified whether the window content area should be resized based on content scale changes.
    /// This can be because of a global user settings change or because the window was moved to a monitor with different scale settings.
    ///
    /// This hint only has an effect on platforms where screen coordinates and pixels always map 1:1, such as Windows and X11.
    /// On platforms like macOS the resolution of the framebuffer can change independently of the window size.
    scale_to_monitor: bool = true,
    /// Specifies whether the window is transparent to mouse input, letting any mouse events pass through to whatever window is behind it.
    /// This is only supported for undecorated windows. Decorated windows with this enabled will behave differently between platforms.
    mouse_passthrough: bool = true,
    position_x: c_int = @bitCast(c.GLFW_ANY_POSITION),
    position_y: c_int = @bitCast(c.GLFW_ANY_POSITION),

    /// Specify the desired bit depths of the various components of the default framebuffer.
    /// A value of `null` means the application has no preference.
    bits: Bits = .{},

    /// Framebuffer related hints
    framebuffer: Framebuffer = .{},

    /// Specifies the desired refresh rate for full screen windows.
    /// A value of `null` means the highest available refresh rate will be used.
    /// This hint is ignored for windowed mode windows.
    refresh_rate: ?PositiveCInt = null,

    /// Context related hints
    context: Context = .{},

    /// Windows specific hints, these are ignored on other platforms
    win32: Win32 = .{},

    /// MacOS specific hints, these are ignored on other platforms
    cocoa: Cocoa = .{},

    /// Wayland specific hints, these are ignored on other platforms
    wayland: Wayland = .{},

    /// X11 specific hints, these are ignored on other platforms
    x11: X11 = .{},

    const PositiveCInt = std.math.IntFittingRange(0, std.math.maxInt(c_int));
    pub const Bits = struct {
        red: ?PositiveCInt = 8,
        green: ?PositiveCInt = 8,
        blue: ?PositiveCInt = 8,
        alpha: ?PositiveCInt = 8,
        depth: ?PositiveCInt = 24,
        stencil: ?PositiveCInt = 8,
        /// Specify the desired bit depths of the various components of the accumulation buffer.
        /// A value of `null` means the application has no preference.
        accum: Accum = Accum{},
        pub const Accum = struct {
            red: ?PositiveCInt = 0,
            green: ?PositiveCInt = 0,
            blue: ?PositiveCInt = 0,
            alpha: ?PositiveCInt = 0,
        };
    };

    pub const Framebuffer = struct {
        /// Specifies whether the window framebuffer will be transparent.
        /// If enabled and supported by the system, the window framebuffer alpha channel will be used to combine the framebuffer with the background. This does not affect window decorations.
        transparent: bool = false,
        /// Specifies the desired number of auxiliary buffers. A value of null means the application has no preference.
        ///
        /// Auxiliary buffers are a legacy OpenGL feature and should not be used in new code.
        aux_buffers: ?PositiveCInt = 0,
        /// Specifies whether to use OpenGL stereoscopic rendering.
        /// This is a hard constraint.
        stereo: bool = false,
        /// Specifies the desired number of samples to use for multisampling. Zero disables multisampling.
        /// A value of `null` means the application has no preference.
        samples: ?PositiveCInt = 0,
        /// Specifies whether the framebuffer should be sRGB capable.
        srgb_capable: bool = false,
        /// Specifies whether the framebuffer should be double buffered.
        /// You nearly always want to use double buffering. This is a hard constraint.
        doublebuffer: bool = false,
        /// Specifies whether the framebuffer should be resized based on content scale changes.
        /// This can be because of a global user settings change or because the window was moved to a monitor with different scale settings.
        ///
        /// This hint only has an effect on platforms where screen coordinates can be scaled relative to pixel coordinates, such as macOS and Wayland.
        /// On platforms like Windows and X11 the framebuffer and window content area sizes always map 1:1.
        scale: bool = false,
    };

    pub const Context = struct {
        //// Specifies whether the context should be created in debug mode, which may provide additional error and diagnostic reporting functionality.
        //// Debug contexts for OpenGL and OpenGL ES are described in detail by the GL_KHR_debug extension.
        debug: bool = false,
        /// Indicates whether errors are generated by the context.
        /// If enabled, situations that would have generated errors instead cause undefined behavior.
        no_error: bool = false,
        /// Specifies which client API to create the context for.
        /// This is a hard constraint.
        client: ClientAPI = .open_gl,
        /// Specifies which context creation API to use to create the context.
        /// This is a hard constraint. If no client API is requested, this hint is ignored.
        creation: CreationAPI = .native,
        /// Specify the client API version that the created context must be compatible with.
        /// The exact behavior of these hints depend on the requested client API.
        ///
        /// While there is no way to ask the driver for a context of the highest supported version,
        /// GLFW will attempt to provide this when you ask for a version 1.0 context, which is the default for these hints.
        version: Version = .{},
        /// Specifies the robustness strategy to be used by the context.
        robustness: Robustness = .none,
        /// Specifies the release behavior to be used by the context.
        release_behavior: ReleaseBehavior = .any,
        /// Set OpenGL specific properties
        open_gl: OpenGL = .{},
        pub const ClientAPI = enum(c_int) {
            none = c.GLFW_NO_API,
            open_gl = c.GLFW_OPENGL_API,
            open_gles = c.GLFW_OPENGL_ES_API,
        };
        pub const CreationAPI = enum(c_int) {
            native = c.GLFW_NATIVE_CONTEXT_API,
            egl = c.GLFW_EGL_CONTEXT_API,
            osmesa = c.GLFW_OSMESA_CONTEXT_API,
        };
        pub const Version = struct {
            /// The major version of the context
            major: c_int = 1,
            /// The minor version of the context
            minor: c_int = 0,
        };
        pub const Robustness = enum(c_int) {
            none = c.GLFW_NO_ROBUSTNESS,
            no_reset_notification = c.GLFW_NO_RESET_NOTIFICATION,
            lose_context_on_reset = c.GLFW_LOSE_CONTEXT_ON_RESET,
        };
        pub const ReleaseBehavior = enum(c_int) {
            /// The default behavior of the context creation API will be used.
            any = c.GLFW_ANY_RELEASE_BEHAVIOR,
            /// The pipeline will be flushed whenever the context is released from being the current one.
            flush = c.GLFW_RELEASE_BEHAVIOR_FLUSH,
            /// the pipeline will not be flushed on release.
            none = c.GLFW_RELEASE_BEHAVIOR_NONE,
        };
        pub const OpenGL = struct {
            /// Specifies whether the OpenGL context should be forward-compatible, i.e. one where all functionality deprecated in the requested version of OpenGL is removed.
            /// This must only be used if the requested OpenGL version is 3.0 or above.
            /// If OpenGL ES is requested, this hint is ignored.
            ///
            /// Forward-compatibility is described in detail in the OpenGL Reference Manual.
            forward_compat: bool = false,
            /// Specifies which OpenGL profile to create the context for.
            /// If requesting an OpenGL version below 3.2, .any must be used.
            /// If OpenGL ES is requested, this hint is ignored.
            profile: Profile = .any,
            pub const Profile = enum(c_int) {
                any = c.GLFW_OPENGL_ANY_PROFILE,
                core = c.GLFW_OPENGL_CORE_PROFILE,
                compat = c.GLFW_OPENGL_COMPAT_PROFILE,
            };
        };
    };
    pub const Win32 = struct {
        /// Specifies whether to allow access to the window menu via the Alt+Space and Alt-and-then-Space keyboard shortcuts.
        keyboard_menu: bool = false,
        /// Specifies whether to show the window the way specified in the program's STARTUPINFO when it is shown for the first time.
        /// This is the same information as the Run option in the shortcut properties window.
        /// If this information was not specified when the program was started, GLFW behaves as if this hint was set to `false`.
        show_default: bool = false,
    };
    pub const Cocoa = struct {
        /// Specifies whether to in Automatic Graphics Switching, i.e.
        /// to allow the system to choose the integrated GPU for the OpenGL context and move it between GPUs if necessary
        /// or whether to force it to always run on the discrete GPU.
        /// This only affects systems with both integrated and discrete GPUs.
        ///
        /// Simpler programs and tools may want to enable this to save power,
        /// while games and other applications performing advanced rendering will want to leave it disabled.
        ///
        /// A bundled application that wishes to participate in Automatic Graphics Switching should also declare this in its
        /// Info.plist by setting the NSSupportsAutomaticGraphicsSwitching key to true.
        graphics_switching: bool = false,
        /// Specifies the UTF-8 encoded name to use for autosaving the window frame, or if empty disables frame autosaving for the window.
        frame_name: [:0]const u8 = "",
    };
    pub const X11 = struct {
        /// Specifies the ASCII encoded class part of the ICCCM `WM_CLASS` window property
        class_name: [:0]const u8 = "",
        /// Specifies the ASCII encoded instance part of the ICCCM `WM_CLASS` window property
        instance_name: [:0]const u8 = "",
    };
    pub const Wayland = struct {
        /// Specifies the Wayland app_id for a window, used by window managers to identify types of windows
        app_id: [:0]const u8 = "",
    };

    inline fn pos_c_int_to_c_int(x: ?PositiveCInt) c_int {
        if (x) |e| return @intCast(e) else return -1;
    }
    fn set(hints: Hints) void {
        // The contents of this function are taken directly from window.c
        const h = &_c._glfw.hints;
        // Bits
        h.framebuffer.redBits = pos_c_int_to_c_int(hints.bits.red);
        h.framebuffer.greenBits = pos_c_int_to_c_int(hints.bits.green);
        h.framebuffer.blueBits = pos_c_int_to_c_int(hints.bits.blue);
        h.framebuffer.alphaBits = pos_c_int_to_c_int(hints.bits.alpha);
        h.framebuffer.depthBits = pos_c_int_to_c_int(hints.bits.depth);
        h.framebuffer.stencilBits = pos_c_int_to_c_int(hints.bits.stencil);
        h.framebuffer.accumRedBits = pos_c_int_to_c_int(hints.bits.accum.red);
        h.framebuffer.accumGreenBits = pos_c_int_to_c_int(hints.bits.accum.green);
        h.framebuffer.accumBlueBits = pos_c_int_to_c_int(hints.bits.accum.blue);
        h.framebuffer.accumAlphaBits = pos_c_int_to_c_int(hints.bits.accum.alpha);

        // Framebuffer
        h.framebuffer.auxBuffers = pos_c_int_to_c_int(hints.framebuffer.aux_buffers);
        h.framebuffer.stereo = @intFromBool(hints.framebuffer.stereo);
        h.framebuffer.doublebuffer = @intFromBool(hints.framebuffer.doublebuffer);
        h.framebuffer.transparent = @intFromBool(hints.framebuffer.transparent);
        h.framebuffer.samples = pos_c_int_to_c_int(hints.framebuffer.samples);
        h.framebuffer.sRGB = @intFromBool(hints.framebuffer.srgb_capable);

        // Window hints
        h.window.resizable = @intFromBool(hints.resizable);
        h.window.decorated = @intFromBool(hints.decorated);
        h.window.focused = @intFromBool(hints.focused);
        h.window.autoIconify = @intFromBool(hints.auto_iconify);
        h.window.floating = @intFromBool(hints.floating);
        h.window.maximized = @intFromBool(hints.maximized);
        h.window.visible = @intFromBool(hints.visible);
        h.window.xpos = hints.position_x;
        h.window.ypos = hints.position_y;
        h.window.scaleToMonitor = @intFromBool(hints.scale_to_monitor);
        h.window.scaleFramebuffer = @intFromBool(hints.framebuffer.scale);
        h.window.centerCursor = @intFromBool(hints.center_cursor);
        h.window.focusOnShow = @intFromBool(hints.focus_on_show);
        h.window.mousePassthrough = @intFromBool(hints.mouse_passthrough);

        // Context
        h.context.client = @intFromEnum(hints.context.client);
        h.context.source = @intFromEnum(hints.context.creation);
        h.context.major = hints.context.version.major;
        h.context.minor = hints.context.version.minor;
        h.context.robustness = @intFromEnum(hints.context.robustness);
        h.context.forward = @intFromBool(hints.context.open_gl.forward_compat);
        h.context.debug = @intFromBool(hints.context.debug);
        h.context.noerror = @intFromBool(hints.context.no_error);
        h.context.profile = @intFromEnum(hints.context.open_gl.profile);
        h.context.release = @intFromEnum(hints.context.release_behavior);
        h.refreshRate = pos_c_int_to_c_int(hints.refresh_rate);

        // Win32
        h.window.win32.keymenu = @intFromBool(hints.win32.keyboard_menu);
        h.window.win32.showDefault = @intFromBool(hints.win32.show_default);

        // Cocoa
        h.context.nsgl.offline = @intFromBool(hints.cocoa.graphics_switching);
        _ = strncpy(&h.window.ns.frameName[0], hints.cocoa.frame_name, 255);
        // Wayland
        _ = strncpy(&h.window.wl.appId[0], hints.wayland.app_id, 255);
        // X11
        _ = strncpy(&h.window.x11.instanceName[0], hints.x11.instance_name, 255);
        _ = strncpy(&h.window.x11.className[0], hints.x11.class_name, 255);
    }
};
