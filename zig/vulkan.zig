const internal = @import("internal.zig");
const c = internal.c;
const _c = internal._c;
const VkInstance = _c.VkInstance;
const VkPhysicalDevice = _c.VkPhysicalDevice;
const VkSurfaceKHR = _c.VkSurfaceKHR;
const VkFlags = _c.VkFlags;
const VkBool32 = _c.VkBool32;
const VkAllocationCallbacks = _c.VkAllocationCallbacks;
pub fn vulkan_supported() bool {
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

pub fn getInstanceProcAddress(instance: VkInstance, procname: [*:0]const u8) ?c.GLFWvkproc {
    const res = c.glfwGetInstanceProcAddress(@ptrCast(instance), procname);
    internal.errorCheck();
    return res;
}

pub fn getPhysicalDevicePresentationSupport(instance: VkInstance, device: VkPhysicalDevice, queuefamily: u32) bool {
    const res = c.glfwGetPhysicalDevicePresentationSupport(@ptrCast(instance), @ptrCast(device), queuefamily);
    internal.errorCheck();
    return res != 0;
}

pub fn createWindowSurface(instance: VkInstance, window: ?*c.GLFWwindow, allocator: ?*const VkAllocationCallbacks, surface: ?*VkSurfaceKHR) c.VkResult {
    const res = c.glfwCreateWindowSurface(@ptrCast(instance), @ptrCast(window), @ptrCast(@alignCast(allocator)), @ptrCast(surface));
    internal.errorCheck();
    return res;
}
