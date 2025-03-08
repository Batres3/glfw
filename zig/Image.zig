/// Image type and related functions
///
/// An Image may be .owned (initialized by the user) or not (retrieved from glfw). If it is owned, .deinit should be called
const internal = @import("internal.zig");
const c = internal.c;
const Image = @This();
const std = @import("std");

/// The width of the image, in pixels
width: u32,

/// The height of the image, in pixels
height: u32,

/// The pixel data of the image, left-to-right and top-to-bottom
pixels: []u8,

/// Whether the pixel data is owned by you (true) or glfw (false)
owned: bool,

/// Initializes a new owned image of the specified size, with the specified number of bytes
pub fn init(allocator: std.mem.Allocator, width: u32, height: u32, bytes_per_pixel: u32) !Image {
    const buf = try allocator.alloc(u8, width * height * bytes_per_pixel);
    return .{
        .width = width,
        .height = height,
        .pixels = buf,
        .owned = true,
    };
}

/// If owned, frees the memory allocated for the pixels
pub fn deinit(self: *Image, allocator: std.mem.Allocator) void {
    if (self.owned) allocator.free(self.pixels);
}

/// Creates a non owning zig image from a C image
///
/// The bytes per pixel must be supplied as glfw does not specify this
///
/// The returned object is valid as long as the underlying C object is
pub fn fromC(image: c.GLFWimage, bytes_per_pixel: u32) Image {
    return .{
        .width = @as(u32, @intCast(image.width)),
        .height = @as(u32, @intCast(image.height)),
        .pixels = image.pixels[0 .. .width * .height * bytes_per_pixel],
        .owned = false,
    };
}

/// Creates a C image from a zig image
///
/// The returned objects is valid as long as the zig memory is valid
pub fn toC(self: Image) c.GLFWimage {
    return .{
        .width = @as(c_int, @intCast(self.width)),
        .height = @as(c_int, @intCast(self.height)),
        .pixels = &self.pixels[0],
    };
}
