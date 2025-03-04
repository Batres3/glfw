const std = @import("std");
const glfw = @import("glfw");
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

test "glfw monitor" {
    try glfw.init();
    defer glfw.deinit();

    const monitors = try glfw.Monitor.getAll();
    var primary = try glfw.Monitor.getPrimary();

    try expect(monitors[0] == primary.handle);

    // Can't really check without knowing some things about the setup,
    // but we at least check that the functions can run
    _ = try primary.getPosition();
    _ = try primary.getWorkarea();
    _ = try primary.getPhysicalSize();
    _ = try primary.getContentScale();
    _ = try primary.getName();
    // User pointer
    const TestPtr = struct { name: []const u8, othervar: u32 };
    var usr = TestPtr{ .name = "HI", .othervar = 123 };
    primary.setUserPointer(&usr);
    const ptr: *TestPtr = @ptrCast(@alignCast(primary.getUserPointer().?));
    try expect(usr.othervar == ptr.othervar);

    // Callback
    _ = try glfw.Monitor.setCallback(null);

    // Video modes
    _ = try primary.getVideoModes();
    _ = try primary.getVideoMode();

    // Gamma
    try primary.setGamma(1);
    const res = try primary.getGammaRamp();
    if (res) |ramp| {
        try primary.setGammaRamp(ramp);
    }
}
test "glfw window" {
    try glfw.init();
    defer glfw.deinit();

    try glfw.Window.defaultHints();

    var window = try glfw.Window.init(640, 480, "OpenGL Test", null, null);
    defer window.deinit();

    var count: f32 = 0;
    while (!try window.shouldClose()) {
        count += 1;
        if (count > 10) break;
    }

    {
        // Title
        var title = try window.getTitle();
        try expect(std.mem.eql(u8, title, "OpenGL Test"));
        try window.setTitle("New Title");
        title = std.mem.span(glfw.c.glfwGetWindowTitle(@ptrCast(window.handle)));
        try expect(std.mem.eql(u8, title, "New Title"));
        title = try window.getTitle();
        try expect(std.mem.eql(u8, title, "New Title"));
    }
    {
        // Position
        // Not testing setPosition because I have a tiling window manager
        try window.setPosition(.{ .x = 10, .y = 10 });
        const pos = try window.getPosition();
        var x: c_int = 0;
        var y: c_int = 0;
        glfw.c.glfwGetWindowPos(@ptrCast(window.handle), &x, &y);
        try expect(x == pos.x);
        try expect(y == pos.y);
    }
    {
        // Size
        // Not testing setSize because I have a tiling window manager
        try window.setSize(.{ .width = 10, .height = 10 });
        const size = try window.getSize();
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
        try window.setAspectRatio(10, 10);
        _ = try window.getFramebufferSize();
        _ = try window.getFrameSize();
        _ = try window.getContentScale();
    }
    {
        // Opacity
        try window.setOpacity(0.5);
        const o = try window.getOpacity();
        try expect(o == 0.5);
    }
    {
        // Minimize
        try window.iconify();
        // Again, not checking this because of the tiling window manager
        // try expect(try window.isIconified());
        _ = try window.isIconified();
        try window.restore();
        // Maximize
        try window.maximize();
        _ = try window.isMaximized();
        try window.restore();
        // Show / Hide
        try window.hide();
        _ = try window.isVisible();
        try window.show();
        // Attention
        try window.requestAttention();
    }
    {
        // Events
        try glfw.pollEvents();
        try glfw.waitEvents();
        try glfw.waitEventsTimeout(0.01);
        try glfw.postEmptyEvent();
    }
}
