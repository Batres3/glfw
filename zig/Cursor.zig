//! Represents a cursor
const internal = @import("internal.zig");
const requireInit = internal.requireInit;
const c = internal.c;
const _c = internal._c;
const Cursor = @This();
const Window = @import("Window.zig");

handle: *_c._GLFWcursor,

/// Standard system cursor shapes
pub const Shape = enum(c_int) {
    /// The regular arrow cursor shape
    arrow = c.GLFW_ARROW_CURSOR,
    /// The text input I beam cursor shape
    ibeam = c.GLFW_IBEAM_CURSOR,
    /// The crosshair cursor shape
    crosshair = c.GLFW_CROSSHAIR_CURSOR,
    /// This is the same as the old hand enum
    pointing_hand = c.GLFW_HAND_CURSOR,
    /// The operation-not-allowed shape
    /// x11: This shape is provided by a newer standard not supported by all cursor themes.
    ///
    /// wayland: This shape is provided by a newer standard not supported by all cursor themes.
    not_allowed = c.GLFW_NOT_ALLOWED_CURSOR,
    /// The resize/move cursor shapes
    pub const Resize = enum(c_int) {
        /// The horizontal resize cursor shape
        ///
        /// NOTE: This supersedes the old `hresize` enum
        ew = c.GLFW_RESIZE_EW_CURSOR,
        /// The vertical resize cursor shape
        ///
        /// NOTE: This supersedes the old `vresize` enum
        ns = c.GLFW_RESIZE_NS_CURSOR,
        /// The top-left to bottom-right diagonal resize/move shape. This is usually a diagonal
        /// double-headed arrow.
        ///
        /// macos: This shape is provided by a private system API and may fail CursorUnavailable in the
        /// future.
        ///
        /// x11: This shape is provided by a newer standard not supported by all cursor themes.
        ///
        /// wayland: This shape is provided by a newer standard not supported by all cursor themes.
        nwse = c.GLFW_RESIZE_NWSE_CURSOR,
        /// The top-right to bottom-left diagonal resize/move shape. This is usually a diagonal
        /// double-headed arrow.
        ///
        /// macos: This shape is provided by a private system API and may fail with CursorUnavailable
        /// in the future.
        ///
        /// x11: This shape is provided by a newer standard not supported by all cursor themes.
        ///
        /// wayland: This shape is provided by a newer standard not supported by all cursor themes.
        nesw = c.GLFW_RESIZE_NESW_CURSOR,
        /// The omni-directional resize cursor/move shape. This is usually either a combined horizontal
        /// and vertical double-headed arrow or a grabbing hand.
        all = c.GLFW_RESIZE_ALL_CURSOR,
    };
};

/// Creates a new custom cursor image that can be set for a window with my_window.setCursor. The cursor
/// can be destroyed with my_cursor.deinit. Any remaining cursors are destroyed by glfw.terminate.
///
/// The pixels are 32-bit, little-endian, non-premultiplied RGBA, i.e. eight bits per channel with
/// the red channel first. They are arranged canonically as packed sequential rows, starting from
/// the top-left corner.
///
/// The cursor hotspot is specified in pixels, relative to the upper-left corner of the cursor
/// image. Like all other coordinate systems in GLFW, the X-axis points to the right and the Y-axis
/// points down.
///
/// Parameters:
///  - image The desired cursor image.
///  - xhot The desired x-coordinate, in pixels, of the cursor hotspot.
///  - yhot The desired y-coordinate, in pixels, of the cursor hotspot.
/// Returns:
///  - The created cursor.
///
/// @pointer_lifetime The specified image data is copied before this function returns.
///
/// @thread_safety This function must only be called from the main thread.
pub fn init(image: *const c.GLFWimage, xhot: c_int, yhot: c_int) error{ PlatformError, InvalidValue }!?Cursor {
    if (c.glfwCreateCursor(image, xhot, yhot)) |cursor| {
        return .{ .handle = cursor };
    }
    internal.glfw.errorCheck();
    return null;
}

/// Returns a cursor with a standard shape, that can be set for a window with glfw.Window.setCursor.
/// The images for these cursors come from the system cursor theme and their exact appearance will
/// vary between platforms.
///
/// Most of these shapes are guaranteed to exist on every supported platform but a few may not be
/// present. See the table below for details.
///
/// | Cursor shape     | Windows | macOS           | X11               | Wayland           |
/// |------------------|---------|-----------------|-------------------|-------------------|
/// | `.arrow`         | Yes     | Yes             | Yes               | Yes               |
/// | `.ibeam`         | Yes     | Yes             | Yes               | Yes               |
/// | `.crosshair`     | Yes     | Yes             | Yes               | Yes               |
/// | `.pointing_hand` | Yes     | Yes             | Yes               | Yes               |
/// | `.Resize.ew`     | Yes     | Yes             | Yes               | Yes               |
/// | `.Resize.ns`     | Yes     | Yes             | Yes               | Yes               |
/// | `.Resize.nwse`   | Yes     | Yes             | Maybe             | Maybe             |
/// | `.Resize.nesw`   | Yes     | Yes             | Maybe             | Maybe             |
/// | `.Resize.all`    | Yes     | Yes             | Yes               | Yes               |
/// | `.not_allowed`   | Yes     | Yes             | Maybe             | Maybe             |
///
/// 1. This uses a private system API and may fail in the future.
/// 2. This uses a newer standard that not all cursor themes support.
///
/// If the requested shape is not available, this function emits a CursorUnavailable error
/// Possible errors include glfw.ErrorCode.PlatformError and glfw.ErrorCode.CursorUnavailable.
/// null is returned in the event of an error.
///
/// @thread_safety: This function must only be called from the main thread.
pub fn initStandard(shape: Shape) ?Cursor {
    requireInit();
    var cursor: Cursor = .{ .handle = @ptrCast(@alignCast(_c._glfw_calloc(1, @sizeOf(_c._GLFWcursor)).?)) };
    cursor.handle.next = _c._glfw.cursorListHead;
    _c._glfw.cursorListHead = cursor.handle;

    if (_c._glfw.platform.createStandardCursor.?(cursor.handle, @intFromEnum(shape)) == 0) {
        cursor.deinit();
        return null;
    }

    return cursor;
}

/// This function destroys a cursor previously created with glfw.Cursor.init. Any remaining
/// cursors will be destroyed by glfw.deinit.
///
/// If the specified cursor is current for any window, that window will be reverted to the default
/// cursor. This does not affect the cursor mode.
///
/// This function must not be called from a callback.
///
/// @thread_safety This function must only be called from the main thread.
pub fn deinit(self: *Cursor) void {
    c.glfwDestroyCursor(@ptrCast(self.handle));
    internal.errorCheck();
}
