//! This module should only be accesed internally, not exposed to the user
const builtin = @import("builtin");
pub const c = @cImport(@cInclude("glfw3.h"));
pub const _c = @cImport(@cInclude("../../src/internal.h"));
pub const glfw = @import("module.zig");
pub const err = @import("error.zig");
pub const Error = err.Error;
/// An error check for all the glfw functions, only runs in debug mode by default
/// we use this instead of error callback in order to be able to return errors
pub fn errorCheck() Error!void {
    if (builtin.mode == .Debug) {
        var description: [*c]const u8 = undefined;
        return err.toZigError(c.glfwGetError(&description));
    }
}
pub fn requireInit() Error!void {
    if (_c._glfw.initialized == 0) return Error.NotInitialized;
}
