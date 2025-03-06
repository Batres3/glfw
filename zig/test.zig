const std = @import("std");
const glfw = @import("glfw");
const expect = std.testing.expect;

test "glfw init hits" {
    glfw.Hint.Init.set(.HatButtons, false);
    glfw.Hint.Init.Cocoa.set(.Menubar, true);
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
// TODO: Find a way to test if the function actually panicks
// https://github.com/ziglang/zig/issues/1356
// test "glfw error checking" {
//     glfw.pollEvents();
// }
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

test "glfw monitor" {
    try glfw.init();
    defer glfw.deinit();

    const monitors = glfw.Monitor.getAll();
    var primary = glfw.Monitor.getPrimary();

    try expect(monitors[0] == primary.handle);

    // Can't really check without knowing some things about the setup,
    // but we at least check that the functions can run
    _ = primary.getPosition();
    _ = primary.getWorkarea();
    _ = primary.getPhysicalSize();
    _ = primary.getContentScale();
    _ = primary.getName();
    // User pointer
    const TestPtr = struct { name: []const u8, othervar: u32 };
    var usr = TestPtr{ .name = "HI", .othervar = 123 };
    primary.setUserPointer(&usr);
    const ptr: *TestPtr = @ptrCast(@alignCast(primary.getUserPointer().?));
    try expect(usr.othervar == ptr.othervar);

    // Callback
    _ = glfw.Monitor.setCallback(null);

    // Video modes
    _ = primary.getVideoModes();
    _ = primary.getVideoMode();

    // Gamma
    try primary.setGamma(1);
    const res = try primary.getGammaRamp();
    if (res) |ramp| {
        primary.setGammaRamp(ramp);
    }
}
test "glfw window" {
    try glfw.init();
    defer glfw.deinit();

    glfw.Hint.Window.set(.Focused, true);
    glfw.Hint.Window.defaultHints();

    var window = try glfw.Window.init(640, 480, "OpenGL Test", null, null);
    defer window.deinit();

    var count: f32 = 0;
    while (!window.shouldClose()) {
        count += 1;
        if (count > 10) break;
    }

    {
        // Title
        var title = window.getTitle();
        try expect(std.mem.eql(u8, title, "OpenGL Test"));
        window.setTitle("New Title");
        title = std.mem.span(glfw.c.glfwGetWindowTitle(@ptrCast(window.handle)));
        try expect(std.mem.eql(u8, title, "New Title"));
        title = window.getTitle();
        try expect(std.mem.eql(u8, title, "New Title"));
    }
    {
        // Position
        // Not testing setPosition because I have a tiling window manager
        window.setPosition(.{ .x = 10, .y = 10 });
        const pos = window.getPosition();
        var x: c_int = 0;
        var y: c_int = 0;
        glfw.c.glfwGetWindowPos(@ptrCast(window.handle), &x, &y);
        try expect(x == pos.x);
        try expect(y == pos.y);
    }
    {
        // Size
        // Not testing setSize because I have a tiling window manager
        window.setSize(.{ .width = 10, .height = 10 });
        const size = window.getSize();
        var xsize: c_int = 0;
        var ysize: c_int = 0;
        glfw.c.glfwGetWindowSize(@ptrCast(window.handle), &xsize, &ysize);
        try expect(xsize == size.width);
        try expect(ysize == size.height);
    }
    {
        // Size limits
        try window.setSizeLimits(null, null, 100, null);

        window.setSizeLimits(100, null, 10, null) catch |e| {
            try expect(e == glfw.Error.InvalidValue);
        };
    }
    {
        // Some random ones
        window.setAspectRatio(10, 10);
        _ = window.getFramebufferSize();
        _ = window.getFrameSize();
        _ = window.getContentScale();
    }
    {
        // Opacity
        try window.setOpacity(0.5);
        const o = window.getOpacity();
        try expect(o == 0.5);
    }
    {
        // Minimize
        window.iconify();
        // Again, not checking this because of the tiling window manager
        // try expect(try window.isIconified());
        _ = window.isIconified();
        window.restore();
        // Maximize
        window.maximize();
        _ = window.isMaximized();
        window.restore();
        // Show / Hide
        window.hide();
        _ = window.isVisible();
        window.show();
        // Attention
        window.requestAttention();
    }
    {
        // Events
        glfw.pollEvents();
        glfw.waitEvents();
        try glfw.waitEventsTimeout(0.01);
        glfw.postEmptyEvent();
    }
    {
        // Input Modes
        window.setInputMode(.StickyKeys, true);
        try expect(window.getInputMode(.StickyKeys));
        // Cursor
        window.setCursorMode(.Normal);
        try expect(window.getCursorMode() == .Normal);
        // RawMouseMotion
        if (glfw.Window.rawMouseMotionSupported()) {
            try window.setRawMouseMotion(true);
            try expect(window.getRawMouseMotion());
            try window.setRawMouseMotion(false);
        }

        try expect(window.getKey(.A) == glfw.Input.State.Release);
        try expect(window.getMouseButton(.Left) == glfw.Input.State.Release);

        _ = window.getCursorPosition();
        try window.setCursorPosition(.{ .x = 0, .y = 0 });
    }
    {
        // Cursor
        if (glfw.Cursor.init(.Hand)) |c| {
            var cursor = c;
            defer cursor.deinit();

            window.setCursor(cursor);
            try expect(window.handle.cursor == cursor.handle);
        }
    }
}

test "glfw input" {
    try glfw.init();
    defer glfw.deinit();

    try expect(std.mem.eql(u8, "a", glfw.Input.Key.getName(.A).?));
    // inline for (std.meta.fields(glfw.Input.Key)) |key| {
    //     if (glfw.Input.Key.getName(@enumFromInt(key.value))) |k| {
    //         std.debug.print("{s}, {s}\n", .{ k, key.name });
    //     } else {
    //         std.debug.print("null, {s}\n", .{key.name});
    //     }
    // }
    glfw.setClipboardString("Test string");
    try expect(std.mem.eql(u8, glfw.getClipboardString(), "Test string"));

    // Joysticks
    if (glfw.Joystick.init(._1)) |joystick| {
        // defer j.deinit() doesn't actually do anything at the moment
        var j = joystick;
        _ = j.isPresent();
        _ = j.getAxes();
        _ = j.getButtons();
        _ = j.getName();
        _ = j.getGUID();
        _ = j.getUserPointer();
        _ = j.isGamepad();
        _ = j.getGamepadName();
        var state: glfw.GamepadState = glfw.GamepadState{};
        _ = j.getGamepadState(&state);
    }
}
