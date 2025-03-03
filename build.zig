const std = @import("std");
const Compile = std.Build.Step.Compile;
const Target = std.Build.ResolvedTarget;
const Optimize = std.builtin.OptimizeMode;

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .name = "glfw",
        .target = target,
        .optimize = optimize,
    });
    // Link the C standard library
    lib.linkLibC();

    const files = [_][]const u8{
        //"include/GLFW/glfw3.h",
        //"include/GLFW/glfw3native.h",
        //"src/glfw_config.h",
        "src/context.c",
        "src/init.c",
        "src/input.c",
        "src/monitor.c",

        "src/null_init.c",
        "src/null_joystick.c",
        "src/null_monitor.c",
        "src/null_window.c",

        "src/platform.c",
        "src/vulkan.c",
        "src/window.c",
    };
    lib.addCSourceFiles(.{ .files = &files });

    lib.addIncludePath(b.path("include/GLFW/"));

    if (target.result.os.tag == .linux) {
        lib.addCSourceFiles(.{ .files = &.{
            "src/x11_init.c",
            "src/x11_monitor.c",
            "src/x11_window.c",
            "src/xkb_unicode.c",
            "src/posix_time.c",
            "src/posix_thread.c",
            "src/posix_module.c",
            "src/glx_context.c",
            "src/egl_context.c",
            "src/osmesa_context.c",
            "src/linux_joystick.c",
        } });

        lib.defineCMacro("_GLFW_X11", null);
    }

    if (target.result.os.tag == .macos) {
        lib.addCSourceFiles(.{ .files = &.{
            "src/cocoa_init.m",
            "src/cocoa_monitor.m",
            "src/cocoa_window.m",
            "src/cocoa_joystick.m",
            "src/cocoa_time.c",
            "src/nsgl_context.m",
            "src/posix_thread.c",
            "src/posix_module.c",
            "src/osmesa_context.c",
            "src/egl_context.c",
        } });

        lib.defineCMacro("_GLFW_COCOA", null);
    }

    if (target.result.os.tag == .windows) {
        lib.addCSourceFiles(.{ .files = &.{
            "src/win32_init.c",
            "src/win32_joystick.c",
            "src/win32_module.c",
            "src/win32_monitor.c",
            "src/win32_time.c",
            "src/win32_thread.c",
            "src/win32_window.c",
            "src/wgl_context.c",
            "src/egl_context.c",
            "src/osmesa_context.c",
        } });

        lib.defineCMacro("_GLFW_WIN32", null);
        lib.defineCMacro("_CRT_SECURE_NO_WARNINGS", null);
    }
    b.installArtifact(lib);
}
