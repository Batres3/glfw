const internal = @import("internal.zig");
const c = internal.c;
pub fn supported() bool {
    const res = c.glfwVulkanSupported();
    internal.errorCheck();
    return res != 0;
}

pub fn getRequiredInstanceExtensions() ?[][*:0]const u8 {
    var count: u32 = 0;
    const res = c.glfwGetRequiredInstanceExtensions(&count);
    internal.errorCheck();
    return @as([*c][*:0]const u8, @ptrCast(res))[0..2];
}

// pub fn getInstanceProcAddress(instance: c.VkInstance, procname: [*:0]const u8) ?c.GLFWvkproc {
//     const res = c.glfwGetInstanceProcAddress(instance, procname);
//     internal.errorCheck();
//     return res;
// }
//
// pub fn getPhysicalDevicePresentationSupport(instance: c.VkInstance, device: c.VkPhysicalDevice, queuefamily: u32) bool {
//     const res = c.glfwGetPhysicalDevicePresentationSupport(instance, device, queuefamily);
//     internal.errorCheck();
//     return res != 0;
// }
//
// pub fn createWindowSurface(instance: c.VkInstance, window: *c.GLFWwindow, allocator: ?*const c.VkAllocationCallbacks, surface: *c.VkSurfaceKHR) c.VkResult {
//     const res = c.glfwCreateWindowSurface(instance, window, allocator, surface);
//     internal.errorCheck();
//     return res;
// }
