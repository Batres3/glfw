const internal = @import("internal.zig");
const requireInit = internal.requireInit;
const c = internal.c;
const _c = internal._c;
const Cursor = @This();
const Window = @import("window.zig");

handle: *_c._GLFWcursor,

pub const Shape = enum(c_int) {
    Arrow = c.GLFW_ARROW_CURSOR,
    Ibeam = c.GLFW_IBEAM_CURSOR,
    Crosshair = c.GLFW_CROSSHAIR_CURSOR,
    //PointingHand = c.GLFW_POINTING_HAND_CURSOR,
    //same as Hand
    Hand = c.GLFW_HAND_CURSOR,
    /// Alias for compatibility
    NotAllowed = c.GLFW_NOT_ALLOWED_CURSOR,
    /// Alias for compatibility
    Hresize = c.GLFW_HRESIZE_CURSOR,
    /// Alias for compatibility
    Vresize = c.GLFW_VRESIZE_CURSOR,
    /// These are provided by a newer standard and may not by supported by all themes
    pub const Resize = enum(c_int) {
        EW = c.GLFW_RESIZE_EW_CURSOR,
        NS = c.GLFW_RESIZE_NS_CURSOR,
        NWSE = c.GLFW_RESIZE_NWSE_CURSOR,
        NESW = c.GLFW_RESIZE_NESW_CURSOR,
        All = c.GLFW_RESIZE_ALL_CURSOR,
    };
};

pub fn initCustom(image: *const c.GLFWimage, xhot: c_int, yhot: c_int) internal.Error!?Cursor {
    if (c.glfwCreateCursor(image, xhot, yhot)) |cursor| {
        return .{ .handle = cursor };
    }
    internal.glfw.errorCheck();
    return null;
}

pub fn init(shape: Shape) ?Cursor {
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

pub fn deinit(self: *Cursor) void {
    c.glfwDestroyCursor(@ptrCast(self.handle));
    internal.errorCheck();
}
