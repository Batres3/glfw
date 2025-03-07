const std = @import("std");
const internal = @import("internal.zig");
const c = internal.c;
const _c = internal._c;
const Joystick = @This();
const requireInit = internal.requireInit;

handle: *_c._GLFWjoystick,
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
pub const ID = enum(c_int) {
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
};
pub const Event = enum(c_int) {
    // Its crazy that glfw connected is a macro for a joystick
    Connected = c.GLFW_CONNECTED,
    Disconnected = c.GLFW_DISCONNECTED,
};

fn initJoysticks() bool {
    if (_c._glfw.joysticksInitialized == 0) {
        if (_c._glfw.platform.initJoysticks.?() == 0) {
            _c._glfw.platform.terminateJoysticks.?();
            return false;
        }
        _c._glfw.joysticksInitialized = 1;
    }
    return true;
}
//
// Static functions
//
pub fn setCallback(callback: c.GLFWjoystickfun) void {
    requireInit();
    if (!initJoysticks()) return;
    _c._glfw.callbacks.joystick = callback;
}

pub fn updateGamepadMappings(string: []const u8) bool {
    requireInit();
    return c.glfwUpdateGamepadMappings(string) != 0;
}

pub fn init(id: ID) ?Joystick {
    requireInit();
    if (!initJoysticks()) return null;

    var j: Joystick = .{ .handle = &_c._glfw.joysticks[@intCast(@intFromEnum(id))] };
    if (!j.isPresent()) return null;

    return j;
}

pub fn deinit(self: *Joystick) void {
    requireInit();
    _ = self;
}

pub fn isPresent(self: *Joystick) bool {
    requireInit();
    if (self.handle.connected == 0) return false;
    if (_c._glfw.platform.pollJoystick.?(self.handle, _c._GLFW_POLL_PRESENCE) == 0) return false;
    return true;
}
//
// Member functions
//
// TODO: All these functions are nullable because I assume that a once present (at init) joystick
// may lose presence, when being disconncted, figure out a way to account for that and remove the optional
pub fn getAxes(self: *Joystick) ?[]f32 {
    requireInit();
    if (!self.isPresent()) return null;

    const count: usize = @intCast(self.handle.axisCount);
    return self.handle.axes[0..count];
}

pub fn getButtons(self: *Joystick) ?[]const u8 {
    requireInit();
    if (!self.isPresent()) return null;
    if (_c._glfw.hints.init.hatButtons != 0) {
        const count: usize = @intCast(self.handle.buttonCount + self.handle.hatCount * 4);
        return self.handle.buttons[0..count];
    } else {
        const count: usize = @intCast(self.handle.buttonCount);
        return self.handle.buttons[0..count];
    }
}

pub fn getHats(self: *Joystick) ?[]const u8 {
    requireInit();
    if (!self.isPresent()) return null;
    const count: usize = @intCast(self.handle.hatCount);
    return self.handle.hats[0..count];
}

pub fn getName(self: *Joystick) ?[]const u8 {
    requireInit();
    if (!self.isPresent()) return null;
    const count: usize = std.mem.len(@as([*:0]u8, @ptrCast(&self.handle.name)));
    return self.handle.name[0..count];
}

pub fn getGUID(self: *Joystick) ?[]const u8 {
    requireInit();
    if (!self.isPresent()) return null;
    const count: usize = std.mem.len(@as([*:0]u8, @ptrCast(&self.handle.guid)));
    return self.handle.guid[0..count];
}

pub fn setUserPointer(self: *Joystick, ptr: ?*anyopaque) void {
    requireInit();
    if (self.handle.allocated == 0) return null;
    self.handle.userPointer = ptr;
}

pub fn getUserPointer(self: *Joystick) ?*anyopaque {
    requireInit();
    if (self.handle.allocated == 0) return null;
    return self.handle.userPointer;
}

pub fn isGamepad(self: *Joystick) bool {
    requireInit();
    if (!self.isPresent()) return false;
    return self.handle.mapping != null;
}

pub fn getGamepadName(self: *Joystick) ?[]const u8 {
    if (!self.isPresent()) return null;
    if (self.handle.mapping == null) return null;
    const map: *_c._GLFWmapping = @ptrCast(self.handle.mapping);
    const len: usize = std.mem.len(@as([*:0]u8, @ptrCast(&map.name)));
    return map.name[0..len];
}

pub fn getGamepadState(self: *Joystick, state: *c.GLFWgamepadstate) bool {
    requireInit();
    const j: c_int = @intCast(@intFromPtr(&_c._glfw.joysticks[0]) - @intFromPtr(self.handle));
    return c.glfwGetGamepadState(j, @ptrCast(state)) == 0;
}
