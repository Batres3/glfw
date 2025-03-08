const std = @import("std");
const glfw = @import("glfw");
const expect = std.testing.expect;
const allocator = std.testing.allocator;

test "glfw init hits" {
    var hints: glfw.InitHints = .{};
    hints.joystick_hat_buttons = false;
    hints.cocoa.menubar = true;
}
test "glfw version" {
    var major: c_int = 0;
    var minor: c_int = 0;
    var rev: c_int = 0;
    glfw.c.glfwGetVersion(&major, &minor, &rev);
    try expect(major == glfw.version.major);
    try expect(minor == glfw.version.minor);
    try expect(rev == glfw.version.revision);
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
    try glfw.init(.{});
    defer glfw.deinit();

    const monitors = glfw.Monitor.getAll();
    var primary = glfw.Monitor.getPrimary();

    try expect(std.meta.eql(monitors[0], primary));

    // Can't really check without knowing some things about the setup,
    // but we at least check that the functions can run
    _ = try primary.getPosition();
    _ = try primary.getWorkarea();
    _ = primary.getPhysicalSize();
    _ = try primary.getContentScale();
    _ = primary.getName();
    // User pointer
    const TestPtr = struct { name: []const u8, othervar: u32 };
    var usr = TestPtr{ .name = "HI", .othervar = 123 };
    primary.setUserPointer(&usr);
    const ptr: *TestPtr = @ptrCast(@alignCast(primary.getUserPointer().?));
    try expect(usr.othervar == ptr.othervar);

    // Callback
    const Holder = struct {
        pub fn monitorCallback(monitor: glfw.Monitor, event: glfw.Monitor.Event) void {
            _ = monitor;
            _ = event;
        }
    };
    _ = glfw.Monitor.setCallback(Holder.monitorCallback);

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
    try glfw.init(.{});
    defer glfw.deinit();

    const hints: glfw.Window.Hints = .{ .focused = true };

    var window = try glfw.Window.init(640, 480, "OpenGL Test", null, null, hints);
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
        try window.setTitle("New Title");
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
        try window.setSizeLimits(.{ .width = null, .height = null }, .{ .width = 100, .height = null });

        window.setSizeLimits(.{ .width = 100, .height = null }, .{ .width = 10, .height = null }) catch |e| {
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
        window.setInputMode(.sticky_keys, true);
        try expect(window.getInputMode(.sticky_keys));
        // Cursor
        window.setCursorMode(.normal);
        try expect(window.getCursorMode() == .normal);
        // RawMouseMotion
        if (glfw.rawMouseMotionSupported()) {
            try window.setRawMouseMotion(true);
            try expect(window.getRawMouseMotion());
            try window.setRawMouseMotion(false);
        }

        try expect(window.getKey(.a) == glfw.Input.Action.release);
        try expect(window.getMouseButton(.left) == glfw.Input.Action.release);

        _ = window.getCursorPosition();
        try window.setCursorPosition(.{ .x = 0, .y = 0 });
    }
    {
        // Cursor
        if (try glfw.Cursor.initStandard(.pointing_hand)) |c| {
            var cursor = c;
            defer cursor.deinit();

            window.setCursor(cursor);
            try expect(window.handle.cursor == cursor.handle);
        }

        var image = try glfw.Image.init(allocator, 32, 32, 4);
        defer image.deinit(allocator);

        if (try glfw.Cursor.init(image, 0, 0)) |cursor| {
            var c = cursor;
            c.deinit();
        }
    }
    {
        // OpenGL
        if (!glfw.build_options.vulkan) {
            try glfw.makeCurrentContext(window);
            if (glfw.getCurrentContext()) |current| {
                try expect(current.handle == window.handle);
            }
            try glfw.swapInterval(1);
            _ = try glfw.extensionSupported("GL_ARB_gl_spirv");
            _ = glfw.getProcAddress("glSpecializeShaderARB");
        }
    }
}

test "glfw input" {
    try glfw.init(.{});
    defer glfw.deinit();

    try expect(std.mem.eql(u8, "a", glfw.Input.Key.getName(.a).?));
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
    if (glfw.Joystick.init(.one)) |joystick| {
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
        _ = j.getGamepadState();
    }

    // Time
    try glfw.setTime(0);
    const t = glfw.getTime();
    try expect(t < 0.01);
    _ = glfw.getTimerValue();
    _ = glfw.getTimerFrequency();
}

test "glfw vulkan" {
    if (glfw.build_options.vulkan) {
        try glfw.init(.{});
        defer glfw.deinit();
        if (glfw.vulkan_supported()) {
            if (glfw.getRequiredInstanceExtensions()) |extensions| {
                for (extensions) |extension| {
                    _ = extension;
                }
            }
            // TODO: Make actual tests
            // _ = glfw.Vulkan.getInstanceProcAddress(null, "vkGetInstanceProcAddr");
            // _ = glfw.Vulkan.getPhysicalDevicePresentationSupport(null, null, 0);
            // _ = glfw.Vulkan.createWindowSurface(null, null, null, null);
        }
    }
}
