//! Error codes
/// Zig errors, the user should only be interacting with these
const c = @import("internal.zig").c;
pub const Error = error{
    NotInitialized,
    NoCurrentContext,
    InvalidEnum,
    InvalidValue,
    OutOfMemory,
    APIUnavailable,
    VersionUnavailable,
    PlatformError,
    FormatUnavailable,
    NoWindowContext,
    CursorUnavailable,
    FeatureUnavailable,
    FeatureUnimplemented,
    PlatformUnavailable,
};

pub fn toZigError(err: c_int) ?Error {
    const code: ErrorCode = @enumFromInt(err);
    return switch (code) {
        .NoError => null,
        .NotInitialized => Error.NotInitialized,
        .NoCurrentContext => Error.NoCurrentContext,
        .InvalidEnum => Error.InvalidEnum,
        .InvalidValue => Error.InvalidValue,
        .OutOfMemory => Error.OutOfMemory,
        .APIUnavailable => Error.APIUnavailable,
        .VersionUnavailable => Error.VersionUnavailable,
        .PlatformError => Error.PlatformError,
        .FormatUnavailable => Error.FormatUnavailable,
        .NoWindowContext => Error.NoWindowContext,
        .CursorUnavailable => Error.CursorUnavailable,
        .FeatureUnavailable => Error.FeatureUnavailable,
        .FeatureUnimplemented => Error.FeatureUnimplemented,
        .PlatformUnavailable => Error.PlatformUnavailable,
    };
}
/// glfw error codes, should not be used directly by the user
const ErrorCode = enum(u32) {
    NoError = c.GLFW_NO_ERROR,
    NotInitialized = c.GLFW_NOT_INITIALIZED,
    NoCurrentContext = c.GLFW_NO_CURRENT_CONTEXT,
    InvalidEnum = c.GLFW_INVALID_ENUM,
    InvalidValue = c.GLFW_INVALID_VALUE,
    OutOfMemory = c.GLFW_OUT_OF_MEMORY,
    APIUnavailable = c.GLFW_API_UNAVAILABLE,
    VersionUnavailable = c.GLFW_VERSION_UNAVAILABLE,
    PlatformError = c.GLFW_PLATFORM_ERROR,
    FormatUnavailable = c.GLFW_FORMAT_UNAVAILABLE,
    NoWindowContext = c.GLFW_NO_WINDOW_CONTEXT,
    CursorUnavailable = c.GLFW_CURSOR_UNAVAILABLE,
    FeatureUnavailable = c.GLFW_FEATURE_UNAVAILABLE,
    FeatureUnimplemented = c.GLFW_FEATURE_UNIMPLEMENTED,
    PlatformUnavailable = c.GLFW_PLATFORM_UNAVAILABLE,
};
