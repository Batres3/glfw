//! Constants for input
const std = @import("std");
const internal = @import("internal.zig");
const c = internal.c;
const _c = internal._c;
pub const State = enum(c_int) {
    Release = c.GLFW_RELEASE,
    Press = c.GLFW_PRESS,
    Repeat = c.GLFW_REPEAT,
};

pub const Key = enum(c_int) {
    // Unknown = c.GLFW_KEY_UNKNOWN,
    Space = c.GLFW_KEY_SPACE,
    Apostrophe = c.GLFW_KEY_APOSTROPHE,
    Comma = c.GLFW_KEY_COMMA,
    Minus = c.GLFW_KEY_MINUS,
    Period = c.GLFW_KEY_PERIOD,
    Slash = c.GLFW_KEY_SLASH,
    Num0 = c.GLFW_KEY_0,
    Num1 = c.GLFW_KEY_1,
    Num2 = c.GLFW_KEY_2,
    Num3 = c.GLFW_KEY_3,
    Num4 = c.GLFW_KEY_4,
    Num5 = c.GLFW_KEY_5,
    Num6 = c.GLFW_KEY_6,
    Num7 = c.GLFW_KEY_7,
    Num8 = c.GLFW_KEY_8,
    Num9 = c.GLFW_KEY_9,
    Semicolon = c.GLFW_KEY_SEMICOLON,
    Equal = c.GLFW_KEY_EQUAL,
    A = c.GLFW_KEY_A,
    B = c.GLFW_KEY_B,
    C = c.GLFW_KEY_C,
    D = c.GLFW_KEY_D,
    E = c.GLFW_KEY_E,
    F = c.GLFW_KEY_F,
    G = c.GLFW_KEY_G,
    H = c.GLFW_KEY_H,
    I = c.GLFW_KEY_I,
    J = c.GLFW_KEY_J,
    K = c.GLFW_KEY_K,
    L = c.GLFW_KEY_L,
    M = c.GLFW_KEY_M,
    N = c.GLFW_KEY_N,
    O = c.GLFW_KEY_O,
    P = c.GLFW_KEY_P,
    Q = c.GLFW_KEY_Q,
    R = c.GLFW_KEY_R,
    S = c.GLFW_KEY_S,
    T = c.GLFW_KEY_T,
    U = c.GLFW_KEY_U,
    V = c.GLFW_KEY_V,
    W = c.GLFW_KEY_W,
    X = c.GLFW_KEY_X,
    Y = c.GLFW_KEY_Y,
    Z = c.GLFW_KEY_Z,
    LeftBracket = c.GLFW_KEY_LEFT_BRACKET,
    Backslash = c.GLFW_KEY_BACKSLASH,
    RightBracket = c.GLFW_KEY_RIGHT_BRACKET,
    GraveAccent = c.GLFW_KEY_GRAVE_ACCENT,
    World1 = c.GLFW_KEY_WORLD_1,
    World2 = c.GLFW_KEY_WORLD_2,

    // Function keys
    Escape = c.GLFW_KEY_ESCAPE,
    Enter = c.GLFW_KEY_ENTER,
    Tab = c.GLFW_KEY_TAB,
    Backspace = c.GLFW_KEY_BACKSPACE,
    Insert = c.GLFW_KEY_INSERT,
    Delete = c.GLFW_KEY_DELETE,
    Right = c.GLFW_KEY_RIGHT,
    Left = c.GLFW_KEY_LEFT,
    Down = c.GLFW_KEY_DOWN,
    Up = c.GLFW_KEY_UP,
    PageUp = c.GLFW_KEY_PAGE_UP,
    PageDown = c.GLFW_KEY_PAGE_DOWN,
    Home = c.GLFW_KEY_HOME,
    End = c.GLFW_KEY_END,
    CapsLock = c.GLFW_KEY_CAPS_LOCK,
    ScrollLock = c.GLFW_KEY_SCROLL_LOCK,
    NumLock = c.GLFW_KEY_NUM_LOCK,
    PrintScreen = c.GLFW_KEY_PRINT_SCREEN,
    Pause = c.GLFW_KEY_PAUSE,
    F1 = c.GLFW_KEY_F1,
    F2 = c.GLFW_KEY_F2,
    F3 = c.GLFW_KEY_F3,
    F4 = c.GLFW_KEY_F4,
    F5 = c.GLFW_KEY_F5,
    F6 = c.GLFW_KEY_F6,
    F7 = c.GLFW_KEY_F7,
    F8 = c.GLFW_KEY_F8,
    F9 = c.GLFW_KEY_F9,
    F10 = c.GLFW_KEY_F10,
    F11 = c.GLFW_KEY_F11,
    F12 = c.GLFW_KEY_F12,
    F13 = c.GLFW_KEY_F13,
    F14 = c.GLFW_KEY_F14,
    F15 = c.GLFW_KEY_F15,
    F16 = c.GLFW_KEY_F16,
    F17 = c.GLFW_KEY_F17,
    F18 = c.GLFW_KEY_F18,
    F19 = c.GLFW_KEY_F19,
    F20 = c.GLFW_KEY_F20,
    F21 = c.GLFW_KEY_F21,
    F22 = c.GLFW_KEY_F22,
    F23 = c.GLFW_KEY_F23,
    F24 = c.GLFW_KEY_F24,
    F25 = c.GLFW_KEY_F25,
    Kp0 = c.GLFW_KEY_KP_0,
    Kp1 = c.GLFW_KEY_KP_1,
    Kp2 = c.GLFW_KEY_KP_2,
    Kp3 = c.GLFW_KEY_KP_3,
    Kp4 = c.GLFW_KEY_KP_4,
    Kp5 = c.GLFW_KEY_KP_5,
    Kp6 = c.GLFW_KEY_KP_6,
    Kp7 = c.GLFW_KEY_KP_7,
    Kp8 = c.GLFW_KEY_KP_8,
    Kp9 = c.GLFW_KEY_KP_9,
    KpDecimal = c.GLFW_KEY_KP_DECIMAL,
    KpDivide = c.GLFW_KEY_KP_DIVIDE,
    KpMultiply = c.GLFW_KEY_KP_MULTIPLY,
    KpSubtract = c.GLFW_KEY_KP_SUBTRACT,
    KpAdd = c.GLFW_KEY_KP_ADD,
    KpEnter = c.GLFW_KEY_KP_ENTER,
    KpEqual = c.GLFW_KEY_KP_EQUAL,
    LeftShift = c.GLFW_KEY_LEFT_SHIFT,
    LeftControl = c.GLFW_KEY_LEFT_CONTROL,
    LeftAlt = c.GLFW_KEY_LEFT_ALT,
    LeftSuper = c.GLFW_KEY_LEFT_SUPER,
    RightShift = c.GLFW_KEY_RIGHT_SHIFT,
    RightControl = c.GLFW_KEY_RIGHT_CONTROL,
    RightAlt = c.GLFW_KEY_RIGHT_ALT,
    RightSuper = c.GLFW_KEY_RIGHT_SUPER,
    Menu = c.GLFW_KEY_MENU,
    pub fn getScancode(key: Key) c_int {
        return _c._glfw.platform.getKeyScancode.?(@intFromEnum(key));
    }
    pub fn getName(key: Key) ?[]const u8 {
        const code = @intFromEnum(key);
        // TODO: Figure out a more "zig" way of doing this
        // see https://www.glfw.org/docs/latest/group__input.html#gaeaed62e69c3bd62b7ff8f7b19913ce4f
        if (key != .KpEqual and
            (code < @intFromEnum(Key.Kp0) or code > @intFromEnum(Key.KpAdd)) and
            (code < @intFromEnum(Key.Apostrophe) or code > @intFromEnum(Key.World2)))
            return null;

        const res: ?[*:0]const u8 = @ptrCast(_c._glfw.platform.getScancodeName.?(getScancode(key)));
        return std.mem.span(res);
    }
};

pub const Modifier = enum(c_int) {
    Shift = c.GLFW_MOD_SHIFT,
    Control = c.GLFW_MOD_CONTROL,
    Alt = c.GLFW_MOD_ALT,
    Super = c.GLFW_MOD_SUPER,
    CapsLock = c.GLFW_MOD_CAPS_LOCK,
    NumLock = c.GLFW_MOD_NUM_LOCK,
};

pub const Mouse = enum(c_int) {
    Left = c.GLFW_MOUSE_BUTTON_LEFT,
    Right = c.GLFW_MOUSE_BUTTON_RIGHT,
    Middle = c.GLFW_MOUSE_BUTTON_MIDDLE,
    // _1 = c.GLFW_MOUSE_BUTTON_1,
    // _2 = c.GLFW_MOUSE_BUTTON_2,
    // _3 = c.GLFW_MOUSE_BUTTON_3,
    _4 = c.GLFW_MOUSE_BUTTON_4,
    _5 = c.GLFW_MOUSE_BUTTON_5,
    _6 = c.GLFW_MOUSE_BUTTON_6,
    _7 = c.GLFW_MOUSE_BUTTON_7,
    _8 = c.GLFW_MOUSE_BUTTON_8,
};

pub const Joystick = struct {
    pub const Hat = enum(c_int) {
        Centered = c.GLFW_HAT_CENTERED,
        Up = c.GLFW_HAT_UP,
        Right = c.GLFW_HAT_RIGHT,
        Down = c.GLFW_HAT_DOWN,
        Left = c.GLFW_HAT_LEFT,
        RightUp = c.GLFW_HAT_RIGHT_UP,
        RightDown = c.GLFW_HAT_RIGHT_DOWN,
        LeftUp = c.GLFW_HAT_LEFT_UP,
        LeftDown = c.GLFW_HAT_LEFT_DOWN,
    };
    pub const Button = enum(c_int) {
        // TODO: Consider changing this notation
        _1 = c.GLFW_JOYSTICK_1,
        _2 = c.GLFW_JOYSTICK_2,
        _3 = c.GLFW_JOYSTICK_3,
        _4 = c.GLFW_JOYSTICK_4,
        _5 = c.GLFW_JOYSTICK_5,
        _6 = c.GLFW_JOYSTICK_6,
        _7 = c.GLFW_JOYSTICK_7,
        _8 = c.GLFW_JOYSTICK_8,
        _9 = c.GLFW_JOYSTICK_9,
        _10 = c.GLFW_JOYSTICK_10,
        _11 = c.GLFW_JOYSTICK_11,
        _12 = c.GLFW_JOYSTICK_12,
        _13 = c.GLFW_JOYSTICK_13,
        _14 = c.GLFW_JOYSTICK_14,
        _15 = c.GLFW_JOYSTICK_15,
        _16 = c.GLFW_JOYSTICK_16,
        Last = c.GLFW_JOYSTICK_LAST,
    };
    pub const Event = enum(c_int) {
        // Its crazy that glfw connected is a macro for a joystick
        Connected = c.GLFW_CONNECTED,
        Disconnected = c.GLFW_DISCONNECTED,
    };
};

pub const Gamepad = struct {
    pub const Button = enum(c_int) {
        A = c.GLFW_GAMEPAD_BUTTON_A,
        B = c.GLFW_GAMEPAD_BUTTON_B,
        X = c.GLFW_GAMEPAD_BUTTON_X,
        Y = c.GLFW_GAMEPAD_BUTTON_Y,
        LeftBumper = c.GLFW_GAMEPAD_BUTTON_LEFT_BUMPER,
        RightBumper = c.GLFW_GAMEPAD_BUTTON_RIGHT_BUMPER,
        Back = c.GLFW_GAMEPAD_BUTTON_BACK,
        Start = c.GLFW_GAMEPAD_BUTTON_START,
        Guide = c.GLFW_GAMEPAD_BUTTON_GUIDE,
        LeftThumb = c.GLFW_GAMEPAD_BUTTON_LEFT_THUMB,
        RightThumb = c.GLFW_GAMEPAD_BUTTON_RIGHT_THUMB,
        DpadUp = c.GLFW_GAMEPAD_BUTTON_DPAD_UP,
        DpadRight = c.GLFW_GAMEPAD_BUTTON_DPAD_RIGHT,
        DpadDown = c.GLFW_GAMEPAD_BUTTON_DPAD_DOWN,
        DpadLeft = c.GLFW_GAMEPAD_BUTTON_DPAD_LEFT,
        Last = c.GLFW_GAMEPAD_BUTTON_LAST,

        // Alternatives
        Cross = c.GLFW_GAMEPAD_BUTTON_CROSS,
        Circle = c.GLFW_GAMEPAD_BUTTON_CIRCLE,
        Square = c.GLFW_GAMEPAD_BUTTON_SQUARE,
        Triangle = c.GLFW_GAMEPAD_BUTTON_TRIANGLE,
    };

    /// Gamepad axes, C convention is GLFW_GAMEPAD_AXIS_
    pub const Axis = enum(c_int) {
        LeftX = c.GLFW_GAMEPAD_AXIS_LEFT_X,
        LeftY = c.GLFW_GAMEPAD_AXIS_LEFT_Y,
        RightX = c.GLFW_GAMEPAD_AXIS_RIGHT_X,
        RightY = c.GLFW_GAMEPAD_AXIS_RIGHT_Y,
        LeftTrigger = c.GLFW_GAMEPAD_AXIS_LEFT_TRIGGER,
        RightTrigger = c.GLFW_GAMEPAD_AXIS_RIGHT_TRIGGER,
        Last = c.GLFW_GAMEPAD_AXIS_LAST,
    };
};
