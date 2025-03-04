const glfw = @import("glfw");
const std = @import("std");
const expect = std.testing.expect;
test "glfw init hits" {
    try glfw.initHint(glfw.Hint.Init.HatButtons, glfw.False);
}
test "glfw version" {
    var major: c_int = 0;
    var minor: c_int = 0;
    var rev: c_int = 0;
    glfw.c.glfwGetVersion(&major, &minor, &rev);
    try expect(major == glfw.Version.Major);
    try expect(minor == glfw.Version.Minor);
    try expect(rev == glfw.Version.Revision);
}
test "glfw error checking" {
    std.debug.print("Error expected: ", .{});
    glfw.initHint(0, 0) catch |e| {
        try expect(e == glfw.Error.InvalidEnum);
    };
}
var callback_test = false;
var callback_err: c_int = 0;
fn callback(err: c_int, desc: [*c]const u8) callconv(.C) void {
    callback_test = true;
    callback_err = err;
    _ = desc;
}
test "glfw error callback" {
    _ = glfw.setErrorCallback(callback);
    glfw.c.glfwInitHint(0, 0);
    try expect(callback_test);
    try expect(callback_err == glfw.c.GLFW_INVALID_ENUM);
    // Clear error log
    _ = glfw.c.glfwGetError(null);
}

test "glfw OpenGL" {
    try glfw.init();
    defer glfw.deinit();

    try glfw.Window.hint(glfw.Hint.Context.Version.Major, 3);
    try glfw.Window.hint(glfw.Hint.Context.Version.Minor, 3);
    try glfw.Window.hint(glfw.Hint.Context.OpenGL.Profile, glfw.Hint.Context.OpenGL.ProfileValues.Core);

    var window = try glfw.Window.init(640, 480, "OpenGL Test", null, null);
    defer window.deinit();

    var count: f32 = 0;
    while (!try window.shouldClose()) {
        count += 1;
        if (count > 1000) break;
    }
}
