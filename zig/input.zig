//! Constants for input
const std = @import("std");
const internal = @import("internal.zig");
const c = internal.c;
const _c = internal._c;
pub const Action = enum(c_int) {
    release = c.GLFW_RELEASE,
    press = c.GLFW_PRESS,
    repeat = c.GLFW_REPEAT,
};

pub const Key = enum(c_int) {
    // Unknown = c.GLFW_KEY_UNKNOWN,
    space = c.GLFW_KEY_SPACE,
    apostrophe = c.GLFW_KEY_APOSTROPHE,
    comma = c.GLFW_KEY_COMMA,
    minus = c.GLFW_KEY_MINUS,
    period = c.GLFW_KEY_PERIOD,
    slash = c.GLFW_KEY_SLASH,
    num0 = c.GLFW_KEY_0,
    num1 = c.GLFW_KEY_1,
    num2 = c.GLFW_KEY_2,
    num3 = c.GLFW_KEY_3,
    num4 = c.GLFW_KEY_4,
    num5 = c.GLFW_KEY_5,
    num6 = c.GLFW_KEY_6,
    num7 = c.GLFW_KEY_7,
    num8 = c.GLFW_KEY_8,
    num9 = c.GLFW_KEY_9,
    semicolon = c.GLFW_KEY_SEMICOLON,
    equal = c.GLFW_KEY_EQUAL,
    a = c.GLFW_KEY_A,
    b = c.GLFW_KEY_B,
    c = c.GLFW_KEY_C,
    d = c.GLFW_KEY_D,
    e = c.GLFW_KEY_E,
    f = c.GLFW_KEY_F,
    g = c.GLFW_KEY_G,
    h = c.GLFW_KEY_H,
    i = c.GLFW_KEY_I,
    j = c.GLFW_KEY_J,
    k = c.GLFW_KEY_K,
    l = c.GLFW_KEY_L,
    m = c.GLFW_KEY_M,
    n = c.GLFW_KEY_N,
    o = c.GLFW_KEY_O,
    p = c.GLFW_KEY_P,
    q = c.GLFW_KEY_Q,
    r = c.GLFW_KEY_R,
    s = c.GLFW_KEY_S,
    t = c.GLFW_KEY_T,
    u = c.GLFW_KEY_U,
    v = c.GLFW_KEY_V,
    w = c.GLFW_KEY_W,
    x = c.GLFW_KEY_X,
    y = c.GLFW_KEY_Y,
    z = c.GLFW_KEY_Z,
    left_bracket = c.GLFW_KEY_LEFT_BRACKET,
    backslash = c.GLFW_KEY_BACKSLASH,
    right_bracket = c.GLFW_KEY_RIGHT_BRACKET,
    grave_accent = c.GLFW_KEY_GRAVE_ACCENT,
    world1 = c.GLFW_KEY_WORLD_1,
    world2 = c.GLFW_KEY_WORLD_2,

    // Function keys
    escape = c.GLFW_KEY_ESCAPE,
    enter = c.GLFW_KEY_ENTER,
    tab = c.GLFW_KEY_TAB,
    backspace = c.GLFW_KEY_BACKSPACE,
    insert = c.GLFW_KEY_INSERT,
    delete = c.GLFW_KEY_DELETE,
    right = c.GLFW_KEY_RIGHT,
    left = c.GLFW_KEY_LEFT,
    down = c.GLFW_KEY_DOWN,
    up = c.GLFW_KEY_UP,
    page_up = c.GLFW_KEY_PAGE_UP,
    page_down = c.GLFW_KEY_PAGE_DOWN,
    home = c.GLFW_KEY_HOME,
    end = c.GLFW_KEY_END,
    caps_lock = c.GLFW_KEY_CAPS_LOCK,
    scroll_lock = c.GLFW_KEY_SCROLL_LOCK,
    num_lock = c.GLFW_KEY_NUM_LOCK,
    print_screen = c.GLFW_KEY_PRINT_SCREEN,
    pause = c.GLFW_KEY_PAUSE,
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
    kp0 = c.GLFW_KEY_KP_0,
    kp1 = c.GLFW_KEY_KP_1,
    kp2 = c.GLFW_KEY_KP_2,
    kp3 = c.GLFW_KEY_KP_3,
    kp4 = c.GLFW_KEY_KP_4,
    kp5 = c.GLFW_KEY_KP_5,
    kp6 = c.GLFW_KEY_KP_6,
    kp7 = c.GLFW_KEY_KP_7,
    kp8 = c.GLFW_KEY_KP_8,
    kp9 = c.GLFW_KEY_KP_9,
    kp_decimal = c.GLFW_KEY_KP_DECIMAL,
    kp_divide = c.GLFW_KEY_KP_DIVIDE,
    kp_multiply = c.GLFW_KEY_KP_MULTIPLY,
    kp_subtract = c.GLFW_KEY_KP_SUBTRACT,
    kp_add = c.GLFW_KEY_KP_ADD,
    kp_enter = c.GLFW_KEY_KP_ENTER,
    kp_equal = c.GLFW_KEY_KP_EQUAL,
    left_shift = c.GLFW_KEY_LEFT_SHIFT,
    left_control = c.GLFW_KEY_LEFT_CONTROL,
    left_alt = c.GLFW_KEY_LEFT_ALT,
    left_super = c.GLFW_KEY_LEFT_SUPER,
    right_shift = c.GLFW_KEY_RIGHT_SHIFT,
    right_control = c.GLFW_KEY_RIGHT_CONTROL,
    right_alt = c.GLFW_KEY_RIGHT_ALT,
    right_super = c.GLFW_KEY_RIGHT_SUPER,
    menu = c.GLFW_KEY_MENU,
    pub fn getScancode(key: Key) c_int {
        return _c._glfw.platform.getKeyScancode.?(@intFromEnum(key));
    }
    pub fn getName(key: Key) ?[]const u8 {
        const code = @intFromEnum(key);
        // TODO: Figure out a more "zig" way of doing this
        // see https://www.glfw.org/docs/latest/group__input.html#gaeaed62e69c3bd62b7ff8f7b19913ce4f
        if (key != .kp_equal and
            (code < @intFromEnum(Key.kp0) or code > @intFromEnum(Key.kp_add)) and
            (code < @intFromEnum(Key.apostrophe) or code > @intFromEnum(Key.world2)))
            return null;

        const res: ?[*:0]const u8 = @ptrCast(_c._glfw.platform.getScancodeName.?(getScancode(key)));
        return std.mem.span(res);
    }
};

pub const RawModifier = enum(c_int) {
    shift = c.GLFW_MOD_SHIFT,
    control = c.GLFW_MOD_CONTROL,
    alt = c.GLFW_MOD_ALT,
    super = c.GLFW_MOD_SUPER,
    caps_lock = c.GLFW_MOD_CAPS_LOCK,
    num_lock = c.GLFW_MOD_NUM_LOCK,
};

/// A bitmask of all key modifiers
pub const Modifier = packed struct(u8) {
    shift: bool = false,
    control: bool = false,
    alt: bool = false,
    super: bool = false,
    caps_lock: bool = false,
    num_lock: bool = false,
    _padding: u2 = 0,

    inline fn verifyIntType(comptime IntType: type) void {
        comptime {
            switch (@typeInfo(IntType)) {
                .int => {},
                else => @compileError("Int was not of int type"),
            }
        }
    }

    pub inline fn toInt(self: Modifier, comptime IntType: type) IntType {
        verifyIntType(IntType);
        return @as(IntType, @intCast(@as(u8, @bitCast(self))));
    }

    pub inline fn fromInt(flags: anytype) Modifier {
        verifyIntType(@TypeOf(flags));
        return @as(Modifier, @bitCast(@as(u8, @intCast(flags))));
    }
};

pub const Mouse = enum(c_int) {
    left = c.GLFW_MOUSE_BUTTON_LEFT,
    right = c.GLFW_MOUSE_BUTTON_RIGHT,
    middle = c.GLFW_MOUSE_BUTTON_MIDDLE,
    // _1 = c.GLFW_MOUSE_BUTTON_1,
    // _2 = c.GLFW_MOUSE_BUTTON_2,
    // _3 = c.GLFW_MOUSE_BUTTON_3,
    four = c.GLFW_MOUSE_BUTTON_4,
    five = c.GLFW_MOUSE_BUTTON_5,
    six = c.GLFW_MOUSE_BUTTON_6,
    seven = c.GLFW_MOUSE_BUTTON_7,
    eight = c.GLFW_MOUSE_BUTTON_8,
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
