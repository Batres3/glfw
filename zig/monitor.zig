const std = @import("std");
const c = @cImport(@cInclude("glfw3.h"));
const Error = @import("module.zig").Error;
const errorCheck = @import("module.zig").errorCheck;
const Monitor = @This();

handle: *c.GLFWmonitor = undefined,

pub fn init(glfw_handle: *c.GLFWmonitor) Monitor {
    return .{ .handle = glfw_handle };
}

pub fn getPosition(self: *Monitor) Error!struct { x: i32, y: i32 } {
    var pos = .{ .x = 0, .y = 0 };
    c.glfwGetMonitorPos(self.handle, &pos.x, &pos.y);
    try errorCheck();
    return pos;
}

pub fn getWorkarea(self: *Monitor) Error!struct { x: i32, y: i32, width: i32, height: i32 } {
    var data = .{ .x = 0, .y = 0, .width = 0, .height = 0 };
    c.glfwGetMonitorWorkarea(self.handle, &data.x, &data.y, &data.width, &data.height);
    try errorCheck();
    return data;
}

pub fn getPhysicalSize(self: *Monitor) Error!struct { width: i32, height: i32 } {
    var data = .{ .width = 0, .height = 0 };
    c.glfwGetMonitorPhysicalSize(self.handle, &data.width, &data.height);
    try errorCheck();
    return data;
}

pub fn getContentScale(self: *Monitor) Error!struct { x: f32, y: f32 } {
    var data = .{ .x = 0, .y = 0 };
    c.glfwGetMonitorContentScale(self.handle, &data.x, &data.y);
    try errorCheck();
    return data;
}

pub fn getName(self: *Monitor) Error![]const u8 {
    const res = c.glfwGetMonitorName(self.handle);
    try errorCheck();
    return std.mem.span(res);
}

pub fn setUserPointer(self: *Monitor, pointer: *anyopaque) Error!void {
    c.glfwSetMonitorUserPointer(self.handle, pointer);
    try errorCheck();
}

pub fn getUserPointer(self: *Monitor) Error!?*anyopaque {
    const res = c.glfwGetMonitorUserPointer(self.handle);
    try errorCheck();
    return res;
}
