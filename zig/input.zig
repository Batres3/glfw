//! Constants for input
const c = @cImport(@cInclude("glfw3.h"));
pub const State = struct {
    pub const Release = c.GLFW_RELEASE;
    pub const Press = c.GLFW_PRESS;
    pub const Repeat = c.GLFW_REPEAT;
};

pub const Mode = struct {
    pub const Cursor = c.GLFW_CURSOR;
    pub const CursorValues = struct {
        pub const Normal = c.GLFW_CURSOR_NORMAL;
        pub const Hidden = c.GLFW_CURSOR_HIDDEN;
        pub const Disabled = c.GLFW_CURSOR_DISABLED;
    };
    pub const StickyKeys = c.GLFW_STICKY_KEYS;
    pub const StickyMouseButtons = c.GLFW_STICKY_MOUSE_BUTTONS;
    pub const LockKeyMods = c.GLFW_LOCK_KEY_MODS;
    /// Check if it is supported with glfwRawMouseMotionSupported
    pub const RawMouseMotion = c.GLFW_RAW_MOUSE_MOTION;
};

pub const Key = struct {
    pub const Unknown = c.GLFW_KEY_UNKNOWN;
    pub const Space = c.GLFW_KEY_SPACE;
    pub const Apostrophe = c.GLFW_KEY_APOSTROPHE;
    pub const Comma = c.GLFW_KEY_COMMA;
    pub const Minus = c.GLFW_KEY_MINUS;
    pub const Period = c.GLFW_KEY_PERIOD;
    pub const Slash = c.GLFW_KEY_SLASH;
    pub const Num0 = c.GLFW_KEY_0;
    pub const Num1 = c.GLFW_KEY_1;
    pub const Num2 = c.GLFW_KEY_2;
    pub const Num3 = c.GLFW_KEY_3;
    pub const Num4 = c.GLFW_KEY_4;
    pub const Num5 = c.GLFW_KEY_5;
    pub const Num6 = c.GLFW_KEY_6;
    pub const Num7 = c.GLFW_KEY_7;
    pub const Num8 = c.GLFW_KEY_8;
    pub const Num9 = c.GLFW_KEY_9;
    pub const Semicolon = c.GLFW_KEY_SEMICOLON;
    pub const Equal = c.GLFW_KEY_EQUAL;
    pub const A = c.GLFW_KEY_A;
    pub const B = c.GLFW_KEY_B;
    pub const C = c.GLFW_KEY_C;
    pub const D = c.GLFW_KEY_D;
    pub const E = c.GLFW_KEY_E;
    pub const F = c.GLFW_KEY_F;
    pub const G = c.GLFW_KEY_G;
    pub const H = c.GLFW_KEY_H;
    pub const I = c.GLFW_KEY_I;
    pub const J = c.GLFW_KEY_J;
    pub const K = c.GLFW_KEY_K;
    pub const L = c.GLFW_KEY_L;
    pub const M = c.GLFW_KEY_M;
    pub const N = c.GLFW_KEY_N;
    pub const O = c.GLFW_KEY_O;
    pub const P = c.GLFW_KEY_P;
    pub const Q = c.GLFW_KEY_Q;
    pub const R = c.GLFW_KEY_R;
    pub const S = c.GLFW_KEY_S;
    pub const T = c.GLFW_KEY_T;
    pub const U = c.GLFW_KEY_U;
    pub const V = c.GLFW_KEY_V;
    pub const W = c.GLFW_KEY_W;
    pub const X = c.GLFW_KEY_X;
    pub const Y = c.GLFW_KEY_Y;
    pub const Z = c.GLFW_KEY_Z;
    pub const LeftBracket = c.GLFW_KEY_LEFT_BRACKET;
    pub const Backslash = c.GLFW_KEY_BACKSLASH;
    pub const RightBracket = c.GLFW_KEY_RIGHT_BRACKET;
    pub const GraveAccent = c.GLFW_KEY_GRAVE_ACCENT;
    pub const World1 = c.GLFW_KEY_WORLD_1;
    pub const World2 = c.GLFW_KEY_WORLD_2;

    // Function keys
    pub const Escape = c.GLFW_KEY_ESCAPE;
    pub const Enter = c.GLFW_KEY_ENTER;
    pub const Tab = c.GLFW_KEY_TAB;
    pub const Backspace = c.GLFW_KEY_BACKSPACE;
    pub const Insert = c.GLFW_KEY_INSERT;
    pub const Delete = c.GLFW_KEY_DELETE;
    pub const Right = c.GLFW_KEY_RIGHT;
    pub const Left = c.GLFW_KEY_LEFT;
    pub const Down = c.GLFW_KEY_DOWN;
    pub const Up = c.GLFW_KEY_UP;
    pub const PageUp = c.GLFW_KEY_PAGE_UP;
    pub const PageDown = c.GLFW_KEY_PAGE_DOWN;
    pub const Home = c.GLFW_KEY_HOME;
    pub const End = c.GLFW_KEY_END;
    pub const CapsLock = c.GLFW_KEY_CAPS_LOCK;
    pub const ScrollLock = c.GLFW_KEY_SCROLL_LOCK;
    pub const NumLock = c.GLFW_KEY_NUM_LOCK;
    pub const PrintScreen = c.GLFW_KEY_PRINT_SCREEN;
    pub const Pause = c.GLFW_KEY_PAUSE;
    pub const F1 = c.GLFW_KEY_F1;
    pub const F2 = c.GLFW_KEY_F2;
    pub const F3 = c.GLFW_KEY_F3;
    pub const F4 = c.GLFW_KEY_F4;
    pub const F5 = c.GLFW_KEY_F5;
    pub const F6 = c.GLFW_KEY_F6;
    pub const F7 = c.GLFW_KEY_F7;
    pub const F8 = c.GLFW_KEY_F8;
    pub const F9 = c.GLFW_KEY_F9;
    pub const F10 = c.GLFW_KEY_F10;
    pub const F11 = c.GLFW_KEY_F11;
    pub const F12 = c.GLFW_KEY_F12;
    pub const F13 = c.GLFW_KEY_F13;
    pub const F14 = c.GLFW_KEY_F14;
    pub const F15 = c.GLFW_KEY_F15;
    pub const F16 = c.GLFW_KEY_F16;
    pub const F17 = c.GLFW_KEY_F17;
    pub const F18 = c.GLFW_KEY_F18;
    pub const F19 = c.GLFW_KEY_F19;
    pub const F20 = c.GLFW_KEY_F20;
    pub const F21 = c.GLFW_KEY_F21;
    pub const F22 = c.GLFW_KEY_F22;
    pub const F23 = c.GLFW_KEY_F23;
    pub const F24 = c.GLFW_KEY_F24;
    pub const F25 = c.GLFW_KEY_F25;
    pub const Kp0 = c.GLFW_KEY_KP_0;
    pub const Kp1 = c.GLFW_KEY_KP_1;
    pub const Kp2 = c.GLFW_KEY_KP_2;
    pub const Kp3 = c.GLFW_KEY_KP_3;
    pub const Kp4 = c.GLFW_KEY_KP_4;
    pub const Kp5 = c.GLFW_KEY_KP_5;
    pub const Kp6 = c.GLFW_KEY_KP_6;
    pub const Kp7 = c.GLFW_KEY_KP_7;
    pub const Kp8 = c.GLFW_KEY_KP_8;
    pub const Kp9 = c.GLFW_KEY_KP_9;
    pub const KpDecimal = c.GLFW_KEY_KP_DECIMAL;
    pub const KpDivide = c.GLFW_KEY_KP_DIVIDE;
    pub const KpMultiply = c.GLFW_KEY_KP_MULTIPLY;
    pub const KpSubtract = c.GLFW_KEY_KP_SUBTRACT;
    pub const KpAdd = c.GLFW_KEY_KP_ADD;
    pub const KpEnter = c.GLFW_KEY_KP_ENTER;
    pub const KpEqual = c.GLFW_KEY_KP_EQUAL;
    pub const LeftShift = c.GLFW_KEY_LEFT_SHIFT;
    pub const LeftControl = c.GLFW_KEY_LEFT_CONTROL;
    pub const LeftAlt = c.GLFW_KEY_LEFT_ALT;
    pub const LeftSuper = c.GLFW_KEY_LEFT_SUPER;
    pub const RightShift = c.GLFW_KEY_RIGHT_SHIFT;
    pub const RightControl = c.GLFW_KEY_RIGHT_CONTROL;
    pub const RightAlt = c.GLFW_KEY_RIGH_TALT;
    pub const RightSuper = c.GLFW_KEY_RIGHT_SUPER;
    pub const Menu = c.GLFW_KEY_MENU;
    pub const Last = c.GLFW_KEY_LAST;
};

pub const Modifier = struct {
    pub const Shift = c.GLFW_MOD_SHIFT;
    pub const Control = c.GLFW_MOD_CONTROL;
    pub const Alt = c.GLFW_MOD_ALT;
    pub const Super = c.GLFW_MOD_SUPER;
    pub const CapsLock = c.GLFW_MOD_CAPS_LOCK;
    pub const NumLock = c.GLFW_MOD_NUM_LOCK;
};

pub const Mouse = struct {
    pub const Button = struct {
        pub const _1 = c.GLFW_MOUSE_BUTTON_1;
        pub const _2 = c.GLFW_MOUSE_BUTTON_2;
        pub const _3 = c.GLFW_MOUSE_BUTTON_3;
        pub const _4 = c.GLFW_MOUSE_BUTTON_4;
        pub const _5 = c.GLFW_MOUSE_BUTTON_5;
        pub const _6 = c.GLFW_MOUSE_BUTTON_6;
        pub const _7 = c.GLFW_MOUSE_BUTTON_7;
        pub const _8 = c.GLFW_MOUSE_BUTTON_8;
        pub const Last = c.GLFW_MOUSE_BUTTON_LAST;
        pub const Left = c.GLFW_MOUSE_BUTTON_LEFT;
        pub const Right = c.GLFW_MOUSE_BUTTON_RIGHT;
        pub const Middle = c.GLFW_MOUSE_BUTTON_MIDDLE;
    };
};

pub const Joystick = struct {
    /// Hint for initialization, it specifies wether to expose hats at all
    pub const HatButtons = c.GLFW_JOYSTICK_HAT_BUTTONS;
    pub const Hat = struct {
        pub const Centered = c.GLFW_HAT_CENTERED;
        pub const Up = c.GLFW_HAT_UP;
        pub const Right = c.GLFW_HAT_RIGHT;
        pub const Down = c.GLFW_HAT_DOWN;
        pub const Left = c.GLFW_HAT_LEFT;
        pub const RightUp = Right | Up;
        pub const RightDown = Right | Down;
        pub const LeftUp = Left | Up;
        pub const LeftDown = Left | Down;
    };
    pub const Button = struct {
        // TODO: Consider changing this notation
        pub const _1 = c.GLFW_JOYSTICK_1;
        pub const _2 = c.GLFW_JOYSTICK_2;
        pub const _3 = c.GLFW_JOYSTICK_3;
        pub const _4 = c.GLFW_JOYSTICK_4;
        pub const _5 = c.GLFW_JOYSTICK_5;
        pub const _6 = c.GLFW_JOYSTICK_6;
        pub const _7 = c.GLFW_JOYSTICK_7;
        pub const _8 = c.GLFW_JOYSTICK_8;
        pub const _9 = c.GLFW_JOYSTICK_9;
        pub const _10 = c.GLFW_JOYSTICK_10;
        pub const _11 = c.GLFW_JOYSTICK_11;
        pub const _12 = c.GLFW_JOYSTICK_12;
        pub const _13 = c.GLFW_JOYSTICK_13;
        pub const _14 = c.GLFW_JOYSTICK_14;
        pub const _15 = c.GLFW_JOYSTICK_15;
        pub const _16 = c.GLFW_JOYSTICK_16;
        pub const Last = c.GLFW_JOYSTICK_LAST;
    };
    pub const Event = struct {
        // Its crazy that glfw connected is a macro for a joystick
        pub const Connected = c.GLFW_CONNECTED;
        pub const Disconnected = c.GLFW_DISCONNECTED;
    };
};

pub const Gamepad = struct {
    pub const Button = struct {
        pub const A = c.GLFW_GAMEPAD_BUTTON_A;
        pub const B = c.GLFW_GAMEPAD_BUTTON_B;
        pub const X = c.GLFW_GAMEPAD_BUTTON_X;
        pub const Y = c.GLFW_GAMEPAD_BUTTON_Y;
        pub const LeftBumper = c.GLFW_GAMEPAD_BUTTON_LEFT_BUMPER;
        pub const RightBumper = c.GLFW_GAMEPAD_BUTTON_RIGHT_BUMPER;
        pub const Back = c.GLFW_GAMEPAD_BUTTON_BACK;
        pub const Start = c.GLFW_GAMEPAD_BUTTON_START;
        pub const Guide = c.GLFW_GAMEPAD_BUTTON_GUIDE;
        pub const LeftThumb = c.GLFW_GAMEPAD_BUTTON_LEFT_THUMB;
        pub const RightThumb = c.GLFW_GAMEPAD_BUTTON_RIGHT_THUMB;
        pub const DpadUp = c.GLFW_GAMEPAD_BUTTON_DPAD_UP;
        pub const DpadRight = c.GLFW_GAMEPAD_BUTTON_DPAD_RIGHT;
        pub const DpadDown = c.GLFW_GAMEPAD_BUTTON_DPAD_DOWN;
        pub const DpadLeft = c.GLFW_GAMEPAD_BUTTON_DPAD_LEFT;
        pub const Last = c.GLFW_GAMEPAD_BUTTON_LAST;

        // Alternatives
        pub const Cross = c.GLFW_GAMEPAD_BUTTON_CROSS;
        pub const Circle = c.GLFW_GAMEPAD_BUTTON_CIRCLE;
        pub const Square = c.GLFW_GAMEPAD_BUTTON_SQUARE;
        pub const Triangle = c.GLFW_GAMEPAD_BUTTON_TRIANGLE;
    };

    /// Gamepad axes, C convention is GLFW_GAMEPAD_AXIS_
    pub const Axis = struct {
        pub const LeftX = c.GLFW_GAMEPAD_AXIS_LEFT_X;
        pub const LeftY = c.GLFW_GAMEPAD_AXIS_LEFT_Y;
        pub const RightX = c.GLFW_GAMEPAD_AXIS_RIGHT_X;
        pub const RightY = c.GLFW_GAMEPAD_AXIS_RIGHT_Y;
        pub const LeftTrigger = c.GLFW_GAMEPAD_AXIS_LEFT_TRIGGER;
        pub const RightTrigger = c.GLFW_GAMEPAD_AXIS_RIGHT_TRIGGER;
        pub const Last = c.GLFW_GAMEPAD_AXIS_LAST;
    };
};
