//! See the full documentation at
//! https://www.glfw.org/docs/latest/window_guide.html
const internal = @import("internal.zig");
const c = internal.c;
const Error = internal.Error;
pub const DontCare = c.GLFW_DONT_CARE;
/// Window creation hints, these do _not_ represent state,
/// but rather hints for creation only, possible values are
/// true/false
fn baseHint(h: anytype, value: c_int) void {
    internal.requireInit();
    c.glfwWindowHint(@intFromEnum(h), value);
}
fn enumHint(h: c_int, value: anytype) void {
    internal.requireInit();
    c.glfwWindowHint(h, @intFromEnum(value));
}
fn stringHint(h: c_int, value: [*c]const u8) void {
    internal.requireInit();
    c.glfwWindowHintString(h, value);
}

fn initHint(h: anytype, value: c_int) void {
    c.glfwInitHint(@intFromEnum(h), value);
    internal.errorCheck();
}
fn initEnum(hint: c_int, value: anytype) void {
    c.glfwInitHint(hint, @intFromEnum(value));
    internal.errorCheck();
}
pub const Init = enum(c_int) {
    HatButtons = c.GLFW_JOYSTICK_HAT_BUTTONS,
    pub fn set(hint: Init, value: bool) void {
        initHint(hint, @intFromBool(value));
    }
    pub const Platform = enum(c_int) {
        pub fn set(value: Values) void {
            initEnum(c.GLFW_PLATFORM, value);
        }
        pub const Values = enum(c_int) {
            Any = c.GLFW_ANY_PLATFORM,
            Win32 = c.GLFW_PLATFORM_WIN32,
            Cocoa = c.GLFW_PLATFORM_COCOA,
            Wayland = c.GLFW_PLATFORM_WAYLAND,
            X11 = c.GLFW_PLATFORM_X11,
            Null = c.GLFW_PLATFORM_NULL,
        };
    };
    pub const Angle = enum(c_int) {
        pub fn set(value: Values) void {
            initEnum(c.GLFW_ANGLE_PLATFORM_TYPE, value);
        }
        pub const Values = enum(c_int) {
            None = c.GLFW_ANGLE_PLATFORM_TYPE_NONE,
            OpenGL = c.GLFW_ANGLE_PLATFORM_TYPE_OPENGL,
            OpenGLES = c.GLFW_ANGLE_PLATFORM_TYPE_OPENGLES,
            D3D9 = c.GLFW_ANGLE_PLATFORM_TYPE_D3D9,
            D3D11 = c.GLFW_ANGLE_PLATFORM_TYPE_D3D11,
            Vulkan = c.GLFW_ANGLE_PLATFORM_TYPE_VULKAN,
            Metal = c.GLFW_ANGLE_PLATFORM_TYPE_METAL,
        };
    };
    /// MacOS specific hints
    pub const Cocoa = enum(c_int) {
        CHDirResources = c.GLFW_COCOA_CHDIR_RESOURCES,
        Menubar = c.GLFW_COCOA_MENUBAR,
        pub fn set(hint: Cocoa, value: bool) void {
            initHint(hint, @intFromBool(value));
        }
    };
    /// X11 specific hints
    pub const X11 = enum(c_int) {
        XCBVulkanSurface = c.GLFW_X11_XCB_VULKAN_SURFACE,
        pub fn set(hint: X11, value: bool) void {
            initHint(hint, @intFromBool(value));
        }
    };
    // Wayland specific hints
    pub const Wayland = enum(c_int) {
        pub const Libdecor = struct {
            pub fn set(value: Values) void {
                initEnum(c.GLFW_WAYLAND_LIBDECOR, value);
            }
            pub const Values = enum(c_int) {
                Prefer = c.GLFW_WAYLAND_PREFER_LIBDECOR,
                Disable = c.GLFW_WAYLAND_DISABLE_LIBDECOR,
            };
        };
    };
};
