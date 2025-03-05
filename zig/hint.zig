//! See the full documentation at
//! https://www.glfw.org/docs/latest/window_guide.html
const c = @cImport(@cInclude("glfw3.h"));
const internal = @cImport(@cInclude("../../src/internal.h"));
const glfw = @import("module.zig");
const Error = glfw.Error;
const errorCheck = glfw.errorCheck;
pub const DontCare = c.GLFW_DONT_CARE;
fn requireInit() Error!void {
    if (internal._glfw.initialized == 0) return Error.NotInitialized;
}
/// Window creation hints, these do _not_ represent state,
/// but rather hints for creation only, possible values are
/// true/false
fn baseHint(h: anytype, value: c_int) Error!void {
    try requireInit();
    c.glfwWindowHint(@intFromEnum(h), value);
}
fn enumHint(h: c_int, value: anytype) Error!void {
    try requireInit();
    c.glfwWindowHint(h, @intFromEnum(value));
}
fn stringHint(h: c_int, value: [*c]const u8) Error!void {
    try requireInit();
    c.glfwWindowHintString(h, value);
}

pub const Window = enum(c_int) {
    Focused = c.GLFW_FOCUSED,
    Iconified = c.GLFW_ICONIFIED,
    Visible = c.GLFW_VISIBLE,
    Decorated = c.GLFW_DECORATED,
    Resizable = c.GLFW_RESIZABLE,
    AutoIconify = c.GLFW_AUTO_ICONIFY,
    Floating = c.GLFW_FLOATING,
    Maximized = c.GLFW_MAXIMIZED,
    CenterCursor = c.GLFW_CENTER_CURSOR,
    Hovered = c.GLFW_HOVERED,
    FocusOnShow = c.GLFW_FOCUS_ON_SHOW,
    //Titlebar = c.GLFW_TITLEBAR,
    MousePassthrough = c.GLFW_MOUSE_PASSTHROUGH,
    RefreshRate = c.GLFW_REFRESH_RATE,
    pub fn set(hint: Window, value: bool) !void {
        try baseHint(hint, @intFromBool(value));
    }
    pub fn defaultHints() Error!void {
        c.glfwDefaultWindowHints();
        try errorCheck();
    }
};
/// Framebuffer creation hints, these do _not_ represent state,
/// but rather hints for creation only, possible values are
/// true/false
pub const Framebuffer = enum(c_int) {
    Transparent = c.GLFW_TRANSPARENT_FRAMEBUFFER,
    AuxBuffers = c.GLFW_AUX_BUFFERS,
    Stereo = c.GLFW_STEREO,
    Samples = c.GLFW_SAMPLES,
    SrgbCapable = c.GLFW_SRGB_CAPABLE,
    Doublebuffer = c.GLFW_DOUBLEBUFFER,
    Scale = c.GLFW_SCALE_FRAMEBUFFER,
    pub fn set(hint: Framebuffer, value: bool) !void {
        baseHint(hint, @intFromBool(value));
    }
    /// Hints for the number of bits in a framebuffer, possible values are a positive
    /// int, or -1 (glfw.Hint.DontCare) to let glfw choose
    pub const Bits = enum(c_int) {
        Red = c.GLFW_RED_BITS,
        Green = c.GLFW_GREEN_BITS,
        Blue = c.GLFW_BLUE_BITS,
        Alpha = c.GLFW_ALPHA_BITS,
        Depth = c.GLFW_DEPTH_BITS,
        Stencil = c.GLFW_STENCIL_BITS,
        pub fn set(hint: Bits, value: c_int) !void {
            baseHint(hint, value);
        }
        pub const Accumulate = enum(c_int) {
            Red = c.GLFW_ACCUM_RED_BITS,
            Green = c.GLFW_ACCUM_GREEN_BITS,
            Blue = c.GLFW_ACCUM_BLUE_BITS,
            Alpha = c.GLFW_ACCUM_ALPHA_BITS,
            pub fn set(hint: Accumulate, value: c_int) !void {
                baseHint(hint, value);
            }
        };
    };
};
/// Context creation hints, these do _not_ represent state,
/// but rather hints for creation only, possible values are
/// true/false
pub const Context = enum(c_int) {
    Revision = c.GLFW_CONTEXT_REVISION,
    Debug = c.GLFW_CONTEXT_DEBUG,
    NoError = c.GLFW_CONTEXT_NO_ERROR,
    ScaleToMonitor = c.GLFW_SCALE_TO_MONITOR,
    pub fn set(hint: Context, value: bool) !void {
        baseHint(hint, @intFromBool(value));
    }
    pub const API = struct {
        pub const Client = struct {
            pub fn set(value: Value) !void {
                enumHint(c.GLFW_CLIENT_API, value);
            }
            pub const Value = enum(c_int) {
                NoAPI = c.GLFW_NO_API,
                OpenGL = c.GLFW_OPENGL_API,
                OpenGLES = c.GLFW_OPENGL_ES_API,
            };
        };
        pub const Creation = enum(c_int) {
            pub fn set(value: Value) !void {
                enumHint(c.GLFW_CONTEXT_CREATION_API, value);
            }
            pub const Value = enum(c_int) {
                Native = c.GLFW_NATIVE_CONTEXT_API,
                EGL = c.GLFW_EGL_CONTEXT_API,
                OSMESA = c.GLFW_OSMESA_CONTEXT_API,
            };
        };
    };
    pub const Version = enum(c_int) {
        Major = c.GLFW_CONTEXT_VERSION_MAJOR,
        Minor = c.GLFW_CONTEXT_VERSION_MINOR,
        pub fn set(hint: Version, value: c_int) !void {
            baseHint(hint, value);
        }
    };
    pub const Robustness = enum(c_int) {
        pub fn set(value: Value) !void {
            enumHint(c.GLFW_CONTEXT_ROBUSTNESS, value);
        }
        pub const Value = enum(c_int) {
            None = c.GLFW_NO_ROBUSTNESS,
            NoResetNotification = c.GLFW_NO_RESET_NOTIFICATION,
            LoseContextOnReset = c.GLFW_LOSE_CONTEXT_ON_RESET,
        };
    };
    pub const ReleaseBehavior = enum(c_int) {
        pub fn set(value: Value) !void {
            enumHint(c.GLFW_CONTEXT_RELEASE_BEHAVIOR, value);
        }
        pub const Value = enum(c_int) {
            Any = c.GLFW_ANY_RELEASE_BEHAVIOR,
            Flush = c.GLFW_RELEASE_BEHAVIOR_FLUSH,
            None = c.GLFW_RELEASE_BEHAVIOR_NONE,
        };
    };
    pub const OpenGL = enum(c_int) {
        ForwardCompat = c.GLFW_OPENGL_FORWARD_COMPAT,
        /// This is deprecated, use Context.Debug instead
        DebugContext = c.GLFW_OPENGL_DEBUG_CONTEXT,
        pub fn set(hint: OpenGL, value: bool) !void {
            baseHint(hint, @intFromBool(value));
        }
        pub const Profile = enum(c_int) {
            pub fn set(value: Value) !void {
                enumHint(c.GLFW_OPENGL_PROFILE, value);
            }
            pub const Value = enum(c_int) {
                Any = c.GLFW_OPENGL_ANY_PROFILE,
                Core = c.GLFW_OPENGL_CORE_PROFILE,
                Compat = c.GLFW_OPENGL_COMPAT_PROFILE,
            };
        };
    };
    pub const Win32 = enum(c_int) {
        KeyboardMenu = c.GLFW_WIN32_KEYBOARD_MENU,
        ShowDefault = c.GLFW_WIN32_SHOWDEFAULT,
        pub fn set(hint: Win32, value: bool) !void {
            baseHint(hint, @intFromBool(value));
        }
    };
    pub const Cocoa = enum(c_int) {
        GraphicsSwitching = c.GLFW_COCOA_GRAPHICS_SWITCHING,
        pub fn set(hint: Cocoa, value: bool) !void {
            baseHint(hint, @intFromBool(value));
        }
        pub const FrameName = enum(c_int) {
            pub fn set(value: [:0]const u8) !void {
                stringHint(c.GLFW_COCOA_FRAME_NAME, @ptrCast(value));
            }
        };
    };
    pub const X11 = enum(c_int) {
        ClassName = c.GLFW_X11_CLASS_NAME,
        InstanceName = c.GLFW_X11_INSTANCE_NAME,
        pub fn set(hint: X11, value: [:0]const u8) !void {
            stringHint(hint, @ptrCast(value));
        }
    };
    pub const Wayland = enum(c_int) {
        AppID = c.GLFW_WAYLAND_APP_ID,
        pub fn set(hint: Wayland, value: [:0]const u8) !void {
            stringHint(hint, @ptrCast(value));
        }
    };
};

pub const Cursor = struct {
    pub const Shape = enum(c_int) {
        Arrow = c.GLFW_ARROW_CURSOR,
        Ibeam = c.GLFW_IBEAM_CURSOR,
        Crosshair = c.GLFW_CROSSHAIR_CURSOR,
        PointingHand = c.GLFW_POINTING_HAND_CURSOR,
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
};

fn initHint(h: anytype, value: c_int) Error!void {
    c.glfwInitHint(@intFromEnum(h), value);
}
fn initEnum(hint: c_int, value: anytype) !void {
    c.glfwInitHint(hint, @intFromEnum(value));
}
pub const Init = enum(c_int) {
    HatButtons = c.GLFW_JOYSTICK_HAT_BUTTONS,
    pub fn set(hint: Init, value: bool) !void {
        try initHint(hint, @intFromBool(value));
    }
    pub const Platform = enum(c_int) {
        pub fn set(value: Values) !void {
            try initEnum(c.GLFW_PLATFORM, value);
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
        pub fn set(value: Values) !void {
            try initEnum(c.GLFW_ANGLE_PLATFORM_TYPE, value);
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
        pub fn set(hint: Cocoa, value: bool) !void {
            try initHint(hint, @intFromBool(value));
        }
    };
    /// X11 specific hints
    pub const X11 = enum(c_int) {
        XCBVulkanSurface = c.GLFW_X11_XCB_VULKAN_SURFACE,
        pub fn set(hint: X11, value: bool) !void {
            try initHint(hint, @intFromBool(value));
        }
    };
    // Wayland specific hints
    pub const Wayland = enum(c_int) {
        pub const Libdecor = struct {
            pub fn set(value: Values) !void {
                try initEnum(c.GLFW_WAYLAND_LIBDECOR, value);
            }
            pub const Values = enum(c_int) {
                Prefer = c.GLFW_WAYLAND_PREFER_LIBDECOR,
                Disable = c.GLFW_WAYLAND_DISABLE_LIBDECOR,
            };
        };
    };
};
