//! Represents a Joystick or gamepad
//!
//! It can be manually created using glfw.Joystick.init(.one) but typically
//! it's better to discover joysticks using the callback
const std = @import("std");
const internal = @import("internal.zig");
const input = @import("input.zig");
const Error = @import("error.zig").Error;
const c = internal.c;
const _c = internal._c;
const Joystick = @This();
const requireInit = internal.requireInit;

handle: *_c._GLFWjoystick,
pub const Hat = packed struct(u8) {
    up: bool = false,
    right: bool = false,
    down: bool = false,
    left: bool = false,
    _padding: u4 = 0,

    pub inline fn centered(self: Hat) bool {
        return self.up == false and self.right == false and self.down == false and self.left == false;
    }

    inline fn verifyIntType(comptime IntType: type) void {
        comptime {
            switch (@typeInfo(IntType)) {
                .int => {},
                else => @compileError("Int was not of int type"),
            }
        }
    }

    pub inline fn toInt(self: Hat, comptime IntType: type) IntType {
        verifyIntType(IntType);
        return @as(IntType, @intCast(@as(u8, @bitCast(self))));
    }

    pub inline fn fromInt(flags: anytype) Hat {
        verifyIntType(@TypeOf(flags));
        return @as(Hat, @bitCast(@as(u8, @intCast(flags))));
    }
};
pub const RawHat = enum(c_int) {
    centered = c.GLFW_HAT_CENTERED,
    up = c.GLFW_HAT_UP,
    right = c.GLFW_HAT_RIGHT,
    down = c.GLFW_HAT_DOWN,
    left = c.GLFW_HAT_LEFT,
    right_up = c.GLFW_HAT_RIGHT_UP,
    right_down = c.GLFW_HAT_RIGHT_DOWN,
    left_up = c.GLFW_HAT_LEFT_UP,
    left_down = c.GLFW_HAT_LEFT_DOWN,
};
pub const ID = enum(c_int) {
    one = c.GLFW_JOYSTICK_1,
    two = c.GLFW_JOYSTICK_2,
    three = c.GLFW_JOYSTICK_3,
    four = c.GLFW_JOYSTICK_4,
    five = c.GLFW_JOYSTICK_5,
    six = c.GLFW_JOYSTICK_6,
    seven = c.GLFW_JOYSTICK_7,
    eight = c.GLFW_JOYSTICK_8,
    nine = c.GLFW_JOYSTICK_9,
    ten = c.GLFW_JOYSTICK_10,
    eleven = c.GLFW_JOYSTICK_11,
    twelve = c.GLFW_JOYSTICK_12,
    thirteen = c.GLFW_JOYSTICK_13,
    fourteen = c.GLFW_JOYSTICK_14,
    fifteen = c.GLFW_JOYSTICK_15,
    sixteen = c.GLFW_JOYSTICK_16,
};
pub const Event = enum(c_int) {
    connected = c.GLFW_CONNECTED,
    disconnected = c.GLFW_DISCONNECTED,
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
pub fn init(id: ID) ?Joystick {
    requireInit();
    if (!initJoysticks()) return null;

    var j: Joystick = .{ .handle = &_c._glfw.joysticks[@intCast(@intFromEnum(id))] };
    if (!j.isPresent()) return null;

    return j;
}

pub fn deinit(self: Joystick) void {
    requireInit();
    _ = self;
}

/// Returns whether the specified joystick is present.
///
/// There is no need to call this function before other functions, as
/// they all check for presence before performing any other work.
///
/// @return `true` if the joystick is present, or `false` otherwise.
///
/// @thread_safety This function must only be called from the main thread.
pub fn isPresent(self: Joystick) bool {
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
//

/// Returns the values of all axes of the specified joystick.
///
/// This function returns the values of all axes of the specified joystick. Each element in the
/// array is a value between -1.0 and 1.0.
///
/// If the specified joystick is not present this function will return null but will not generate
/// an error. This can be used instead of first calling glfw.Joystick.isPresent.
///
/// @return An array of axis values, or null if the joystick is not present.
///
/// @pointer_lifetime The returned array is allocated and freed by GLFW. You should not free it
/// yourself. It is valid until the specified joystick is disconnected or the library is
/// terminated.
///
/// @thread_safety This function must only be called from the main thread.
pub fn getAxes(self: Joystick) ?[]const f32 {
    requireInit();
    if (!self.isPresent()) return null;

    const count: usize = @intCast(self.handle.axisCount);
    return self.handle.axes[0..count];
}

/// Returns the state of all buttons of the specified joystick.
///
/// This function returns the state of all buttons of the specified joystick. Each element in the
/// array is either `glfw.Action.press` or `glfw.Action.release`.
///
/// For backward compatibility with earlier versions that did not have glfw.Joystick.getHats, the
/// button array also includes all hats, each represented as four buttons. The hats are in the same
/// order as returned by glfw.Joystick.getHats and are in the order _up_, _right_, _down_ and
/// _left_. To disable these extra buttons, set the glfw.joystick_hat_buttons init hint before
/// initialization.
///
/// If the specified joystick is not present this function will return null but will not generate an
/// error. This can be used instead of first calling glfw.Joystick.isPresent.
///
/// @return An array of button states, or null if the joystick is not present.
///
/// @pointer_lifetime The returned array is allocated and freed by GLFW. You should not free it
/// yourself. It is valid until the specified joystick is disconnected or the library is terminated.
///
/// @thread_safety This function must only be called from the main thread.
pub fn getButtons(self: Joystick) ?[]const input.Action {
    requireInit();
    if (!self.isPresent()) return null;
    var count: usize = 0;
    if (_c._glfw.hints.init.hatButtons != 0) {
        count = @intCast(self.handle.buttonCount + self.handle.hatCount * 4);
    } else {
        count = @intCast(self.handle.buttonCount);
    }
    return @as(*const []const input.Action, @ptrCast(&self.handle.buttons[0..count])).*;
}

/// Returns the state of all hats of the specified joystick.
///
/// This function returns the state of all hats of the specified joystick. Each element in the array
/// is one of the following values:
///
/// | Name                           | Value                                                 |
/// |--------------------------------|-------------------------------------------------------|
/// | `glfw.Joystick.RawHat.centered`   | 0                                                     |
/// | `glfw.Joystick.RawHat.up`         | 1                                                     |
/// | `glfw.Joystick.RawHat.right`      | 2                                                     |
/// | `glfw.Joystick.RawHat.down`       | 4                                                     |
/// | `glfw.Joystick.RawHat.left`       | 8                                                     |
/// | `glfw.Joystick.RawHat.right_up`   | `glfw.Joystick.RawHat.right` \| `glfw.Joystick.RawHat.up`   |
/// | `glfw.Joystick.RawHat.right_down` | `glfw.Joystick.RawHat.right` \| `glfw.Joystick.RawHat.down` |
/// | `glfw.Joystick.RawHat.left_up`    | `glfw.Joystick.RawHat.left` \| `glfw.Joystick.RawHat.up`    |
/// | `glfw.Joystick.RawHat.left_down`  | `glfw.Joystick.RawHat.left` \| `glfw.Joystick.RawHat.down`  |
///
/// The diagonal directions are bitwise combinations of the primary (up, right, down and left)
/// directions, since the Zig GLFW wrapper returns a packed struct it is trivial to test for these:
///
/// ```
/// if (hats.up and hats.right) {
///     // up-right!
/// }
/// ```
///
/// If the specified joystick is not present this function will return null but will not generate an
/// error. This can be used instead of first calling glfw.Joystick.isPresent.
///
/// @return An array of hat states, or null if the joystick is not present.
///
/// @pointer_lifetime The returned array is allocated and freed by GLFW. You should not free it
/// yourself. It is valid until the specified joystick is disconnected, this function is called
/// again for that joystick or the library is terminated.
///
/// @thread_safety This function must only be called from the main thread.
pub fn getHats(self: Joystick) ?[]const Hat {
    requireInit();
    if (!self.isPresent()) return null;
    const count: usize = @intCast(self.handle.hatCount);
    return @as(*const []const Hat, @ptrCast(&self.handle.hats[0..count])).*;
}

/// Returns the name of the specified joystick.
///
/// This function returns the name, encoded as UTF-8, of the specified joystick. The returned string
/// is allocated and freed by GLFW. You should not free it yourself.
///
/// If the specified joystick is not present this function will return null but will not generate an
/// error. This can be used instead of first calling glfw.Joystick.isPresent.
///
/// @return The UTF-8 encoded name of the joystick, or null if the joystick is not present or an
/// error occurred.
///
/// @pointer_lifetime The returned string is allocated and freed by GLFW. You should not free it
/// yourself. It is valid until the specified joystick is disconnected or the library is terminated.
///
/// @thread_safety This function must only be called from the main thread.
pub fn getName(self: Joystick) ?[]const u8 {
    requireInit();
    if (!self.isPresent()) return null;
    const count: usize = std.mem.len(@as([*:0]u8, @ptrCast(&self.handle.name)));
    return self.handle.name[0..count];
}

/// Returns the SDL compatible GUID of the specified joystick.
///
/// This function returns the SDL compatible GUID, as a UTF-8 encoded hexadecimal string, of the
/// specified joystick. The returned string is allocated and freed by GLFW. You should not free it
/// yourself.
///
/// The GUID is what connects a joystick to a gamepad mapping. A connected joystick will always have
/// a GUID even if there is no gamepad mapping assigned to it.
///
/// If the specified joystick is not present this function will return null but will not generate an
/// error. This can be used instead of first calling glfw.Joystick.isPresent.
///
/// The GUID uses the format introduced in SDL 2.0.5. This GUID tries to uniquely identify the make
/// and model of a joystick but does not identify a specific unit, e.g. all wired Xbox 360
/// controllers will have the same GUID on that platform. The GUID for a unit may vary between
/// platforms depending on what hardware information the platform specific APIs provide.
///
/// @return The UTF-8 encoded GUID of the joystick, or null if the joystick is not present.
///
/// @pointer_lifetime The returned string is allocated and freed by GLFW. You should not free it
/// yourself. It is valid until the specified joystick is disconnected or the library is terminated.
///
/// @thread_safety This function must only be called from the main thread.
pub fn getGUID(self: Joystick) ?[]const u8 {
    requireInit();
    if (!self.isPresent()) return null;
    const count: usize = std.mem.len(@as([*:0]u8, @ptrCast(&self.handle.guid)));
    return self.handle.guid[0..count];
}

/// Sets the user pointer of the specified joystick.
///
/// This function sets the user-defined pointer of the specified joystick. The current value is
/// retained until the joystick is disconnected. The initial value is null.
///
/// This function may be called from the joystick callback, even for a joystick that is being disconnected.
///
/// @thread_safety This function may be called from any thread. Access is not synchronized.
pub fn setUserPointer(self: Joystick, ptr: ?*anyopaque) void {
    requireInit();
    if (self.handle.allocated == 0) return null;
    self.handle.userPointer = ptr;
}

/// Returns the user pointer of the specified joystick.
///
/// This function returns the current value of the user-defined pointer of the specified joystick.
/// The initial value is null.
///
/// This function may be called from the joystick callback, even for a joystick that is being
/// disconnected.
///
/// @thread_safety This function may be called from any thread. Access is not synchronized.
pub fn getUserPointer(self: Joystick) ?*anyopaque {
    requireInit();
    if (self.handle.allocated == 0) return null;
    return self.handle.userPointer;
}

/// Sets the joystick configuration callback.
///
/// This function sets the joystick configuration callback, or removes the currently set callback.
/// This is called when a joystick is connected to or disconnected from the system.
///
/// For joystick connection and disconnection events to be delivered on all platforms, you need to
/// call one of the event processing (see events) functions. Joystick disconnection may also be
/// detected and the callback called by joystick functions. The function will then return whatever
/// it returns if the joystick is not present.
///
/// The new callback may be null to remove the currently set callback.
///
/// @callback_param `joystick` The joystick that was connected or disconnected.
/// @callback_param `event` One of `.connected` or `.disconnected`. Future releases may add
/// more events.
///
/// @thread_safety This function must only be called from the main thread.
pub inline fn setCallback(comptime callback: ?fn (joystick: Joystick, event: Event) void) void {
    requireInit();

    if (callback) |user_callback| {
        const CWrapper = struct {
            pub fn joystickCallbackWrapper(jid: c_int, event: c_int) callconv(.C) void {
                @call(.always_inline, user_callback, .{
                    init(@enumFromInt(jid)),
                    @as(Event, @enumFromInt(event)),
                });
            }
        };

        _c._glfw.callbacks.joystick = CWrapper.joystickCallbackWrapper;
    } else {
        _c._glfw.callbacks.joystick = null;
    }
}
/// Adds the specified SDL_GameControllerDB gamepad mappings.
///
/// This function parses the specified ASCII encoded string and updates the internal list with any
/// gamepad mappings it finds. This string may contain either a single gamepad mapping or many
/// mappings separated by newlines. The parser supports the full format of the `gamecontrollerdb.txt`
/// source file including empty lines and comments.
///
/// See gamepad_mapping for a description of the format.
///
/// If there is already a gamepad mapping for a given GUID in the internal list, it will be
/// replaced by the one passed to this function. If the library is terminated and re-initialized
/// the internal list will revert to the built-in default.
///
/// @param[in] string The string containing the gamepad mappings.
///
///
/// @thread_safety This function must only be called from the main thread.
pub fn updateGamepadMappings(string: []const u8) GamepadError!void {
    requireInit();
    _ = c.glfwUpdateGamepadMappings(string);
    try internal.subErrorCheck(GamepadError);
}
const GamepadError = error{InvalidValue};

/// Returns whether the specified joystick has a gamepad mapping.
///
/// This function returns whether the specified joystick is both present and has a gamepad mapping.
///
/// If the specified joystick is present but does not have a gamepad mapping this function will
/// return `false` but will not generate an error. Call glfw.Joystick.present to check if a
/// joystick is present regardless of whether it has a mapping.
///
/// @return `true` if a joystick is both present and has a gamepad mapping, or `false` otherwise.
///
/// @thread_safety This function must only be called from the main thread.
pub fn isGamepad(self: Joystick) bool {
    requireInit();
    if (!self.isPresent()) return false;
    return self.handle.mapping != null;
}

/// Returns the human-readable gamepad name for the specified joystick.
///
/// This function returns the human-readable name of the gamepad from the gamepad mapping assigned
/// to the specified joystick.
///
/// If the specified joystick is not present or does not have a gamepad mapping this function will
/// return null, not an error. Call glfw.Joystick.present to check whether it is
/// present regardless of whether it has a mapping.
///
/// @return The UTF-8 encoded name of the gamepad, or null if the joystick is not present or does
/// not have a mapping.
///
/// @pointer_lifetime The returned string is allocated and freed by GLFW. You should not free it
/// yourself. It is valid until the specified joystick is disconnected, the gamepad mappings are
/// updated or the library is terminated.
///
/// @thread_safety This function must only be called from the main thread.
pub fn getGamepadName(self: Joystick) ?[]const u8 {
    if (!self.isPresent()) return null;
    if (self.handle.mapping == null) return null;
    const map: *_c._GLFWmapping = @ptrCast(self.handle.mapping);
    const len: usize = std.mem.len(@as([*:0]u8, @ptrCast(&map.name)));
    return map.name[0..len];
}

/// Retrieves the state of the joystick remapped as a gamepad.
///
/// This function retrieves the state of the joystick remapped to an Xbox-like gamepad.
///
/// If the specified joystick is not present or does not have a gamepad mapping this function will
/// return `false`. Call glfw.joystickPresent to check whether it is present regardless of whether
/// it has a mapping.
///
/// The Guide button may not be available for input as it is often hooked by the system or the
/// Steam client.
///
/// Not all devices have all the buttons or axes provided by GamepadState. Unavailable buttons
/// and axes will always report `glfw.Action.release` and 0.0 respectively.
///
/// @param[in] jid The joystick (see joysticks) to query.
/// @param[out] state The gamepad input state of the joystick.
/// @return the gamepad input state if successful, or null if no joystick is connected or it has no
/// gamepad mapping.
///
/// @thread_safety This function must only be called from the main thread.
pub fn getGamepadState(self: *Joystick) ?input.Gamepad.State {
    requireInit();
    var state: input.Gamepad.State = undefined;
    const j: c_int = @intCast(@intFromPtr(&_c._glfw.joysticks[0]) - @intFromPtr(self.handle));
    if (c.glfwGetGamepadState(j, @ptrCast(&state)) == c.GLFW_TRUE) return state else return null;
}
