//! See the full documentation at
//! https://www.glfw.org/docs/latest/window_guide.html
const c = @cImport(@cInclude("glfw3.h"));
pub const DontCare = c.GLFW_DONT_CARE;
/// Window creation hints, these do _not_ represent state,
/// but rather hints for creation only
pub const Window = struct {
    pub const Focused = c.GLFW_FOCUSED;
    pub const Iconified = c.GLFW_ICONIFIED;
    pub const Visible = c.GLFW_VISIBLE;
    pub const Decorated = c.GLFW_DECORATED;
    pub const Resizable = c.GLFW_RESIZABLE;
    pub const AutoIconify = c.GLFW_AUTO_ICONIFY;
    pub const Floating = c.GLFW_FLOATING;
    pub const Maximized = c.GLFW_MAXIMIZED;
    pub const CenterCursor = c.GLFW_CENTER_CURSOR;
    pub const Hovered = c.GLFW_HOVERED;
    pub const FocusOnShow = c.GLFW_FOCUS_ON_SHOW;
    pub const Titlebar = c.GLFW_TITLEBAR;
    pub const MousePassthrough = c.GLFW_MOUSE_PASSTHROUGH;
    pub const RefreshRate = c.GLFW_REFRESH_RATE;
};
pub const Framebuffer = struct {
    pub const Transparent = c.GLFW_TRANSPARENT_FRAMEBUFFER;
    pub const Bits = struct {
        pub const Red = c.GLFW_RED_BITS;
        pub const Green = c.GLFW_GREEN_BITS;
        pub const Blue = c.GLFW_BLUE_BITS;
        pub const Alpha = c.GLFW_ALPHA_BITS;
        pub const Depth = c.GLFW_DEPTH_BITS;
        pub const Stencil = c.GLFW_STENCIL_BITS;
        pub const Accumulate = struct {
            pub const Red = c.GLFW_ACCUM_RED_BITS;
            pub const Green = c.GLFW_ACCUM_GREEN_BITS;
            pub const Blue = c.GLFW_ACCUM_BLUE_BITS;
            pub const Alpha = c.GLFW_ACCUM_ALPHA_BITS;
        };
    };
    pub const AuxBuffers = c.GLFW_AUX_BUFFERS;
    pub const Stereo = c.GLFW_STEREO;
    pub const Samples = c.GLFW_SAMPLES;
    pub const SrgbCapable = c.GLFW_SRGB_CAPABLE;
    pub const Doublebuffer = c.GLFW_DOUBLEBUFFER;
};
pub const Context = struct {
    pub const API = struct {
        pub const Client = c.GLFW_CLIENT_API;
        pub const ClientValues = struct {
            pub const NoAPI = c.GLFW_NO_API;
            pub const OpenGL = c.GLFW_OPENGL_API;
            pub const OpenGLES = c.GLFW_OPENGL_ES_API;
        };
        pub const Creation = c.GLFW_CONTEXT_CREATION_API;
        pub const CreationValues = struct {
            pub const Native = c.GLFW_NATIVE_CONTEXT_API;
            pub const EGL = c.GLFW_EGL_CONTEXT_API;
            pub const OSMESA = c.GLFW_OSMESA_CONTEXT_API;
        };
    };
    pub const Version = struct {
        pub const Major = c.GLFW_CONTEXT_VERSION_MAJOR;
        pub const Minor = c.GLFW_CONTEXT_VERSION_MINOR;
    };
    pub const Revision = c.GLFW_CONTEXT_REVISION;
    pub const Robustness = c.GLFW_CONTEXT_ROBUSTNESS;
    pub const RobustnessValues = struct {
        pub const None = c.GLFW_NO_ROBUSTNESS;
        pub const NoResetNotification = c.GLFW_NO_RESET_NOTIFICATION;
        pub const LoseContextOnReset = c.GLFW_LOSE_CONTEXT_ON_RESET;
    };
    pub const Debug = c.GLFW_CONTEXT_DEBUG;
    pub const ReleaseBehavior = c.GLFW_CONTEXT_RELEASE_BEHAVIOR;
    pub const ReleaseBehaviorValues = struct {
        pub const Any = c.GLFW_ANY_RELEASE_BEHAVIOR;
        pub const Flush = c.GLFW_RELEASE_BEHAVIOR_FLUSH;
        pub const None = c.GLFW_RELEASE_BEHAVIOR_NONE;
    };
    pub const NoError = c.GLFW_CONTEXT_NO_ERROR;
    pub const ScaleToMonitor = c.GLFW_SCALE_TO_MONITOR;
    pub const OpenGL = struct {
        pub const ForwardCompat = c.GLFW_OPENGL_FORWARD_COMPAT;
        /// This is deprecated, use Context.Debug instead
        pub const DebugContext = c.GLFW_OPENGL_DEBUG_CONTEXT;
        pub const Profile = c.GLFW_OPENGL_PROFILE;
        pub const ProfileValues = struct {
            pub const Any = c.GLFW_OPENGL_ANY_PROFILE;
            pub const Core = c.GLFW_OPENGL_CORE_PROFILE;
            pub const Compat = c.GLFW_OPENGL_COMPAT_PROFILE;
        };
    };
    pub const Win32 = struct {
        pub const KeyboardMenu = c.GLFW_WIN32_KEYBOARD_MENU;
    };
    pub const Cocoa = struct {
        pub const RetinaFramebuffer = c.GLFW_COCOA_RETINA_FRAMEBUFFER;
        pub const FrameName = c.GLFW_COCOA_FRAME_NAME;
        pub const GraphicsSwitching = c.GLFW_COCOA_GRAPHICS_SWITCHING;
    };
    pub const X11 = struct {
        pub const ClassName = c.GLFW_X11_CLASS_NAME;
        pub const InstanceName = c.GLFW_X11_INSTANCE_NAME;
    };
};

pub const Cursor = struct {
    pub const Shape = struct {
        pub const Arrow = c.GLFW_ARROW_CURSOR;
        pub const Ibeam = c.GLFW_IBEAM_CURSOR;
        pub const Crosshair = c.GLFW_CROSSHAIR_CURSOR;
        pub const PointingHand = c.GLFW_POINTING_HAND_CURSOR;
        pub const Hand = c.GLFW_HAND_CURSOR;
        /// These are provided by a newer standard and may not by supported by all themes
        pub const Resize = struct {
            pub const EW = c.GLFW_RESIZE_EW_CURSOR;
            pub const NS = c.GLFW_RESIZE_NS_CURSOR;
            pub const NWSE = c.GLFW_RESIZE_NWSE_CURSOR;
            pub const NESW = c.GLFW_RESIZE_NESW_CURSOR;
            pub const All = c.GLFW_RESIZE_ALL_CURSOR;
        };
        /// Alias for compatibility
        pub const NotAllowed = c.GLFW_NOT_ALLOWED_CURSOR;
        /// Alias for compatibility
        pub const Hresize = c.GLFW_HRESIZE_CURSOR;
        /// Alias for compatibility
        pub const Vresize = c.GLFW_VRESIZE_CURSOR;
    };
};

pub const Init = struct {
    pub const HatButtons = c.GLFW_JOYSTICK_HAT_BUTTONS;
    pub const Platform = c.GLFW_PLATFORM;
    pub const PlatformValues = struct {
        pub const Any = c.GLFW_ANY_PLATFORM;
        pub const Win32 = c.GLFW_PLATFORM_WIN32;
        pub const Cocoa = c.GLFW_PLATFORM_COCOA;
        pub const Wayland = c.GLFW_PLATFORM_WAYLAND;
        pub const X11 = c.GLFW_PLATFORM_X11;
        pub const Null = c.GLFW_PLATFORM_NULL;
    };
    pub const Angle = c.GLFW_ANGLE_PLATFORM_TYPE;
    pub const AngleValues = struct {
        pub const None = c.GLFW_ANGLE_PLATFORM_TYPE_NONE;
        pub const OpenGL = c.GLFW_ANGLE_PLATFORM_TYPE_OPENGL;
        pub const OpenGLES = c.GLFW_ANGLE_PLATFORM_TYPE_OPENGLES;
        pub const D3D9 = c.GLFW_ANGLE_PLATFORM_TYPE_D3D9;
        pub const D3D11 = c.GLFW_ANGLE_PLATFORM_TYPE_D3D11;
        pub const Vulkan = c.GLFW_ANGLE_PLATFORM_TYPE_VULKAN;
        pub const Metal = c.GLFW_ANGLE_PLATFORM_TYPE_METAL;
    };
    /// MacOS specific hints
    pub const Cocoa = struct {
        pub const CHDirResources = c.GLFW_COCOA_CHDIR_RESOURCES;
        pub const Menubar = c.GLFW_COCOA_MENUBAR;
    };
    /// X11 specific hints
    pub const X11 = struct {
        pub const XCBVulkanSurface = c.GLFW_X11_XCB_VULKAN_SURFACE;
    };
};
