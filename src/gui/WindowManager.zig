const std = @import("std");
const Allocator = std.mem.Allocator;

const raylib = @cImport({
    @cInclude("raylib.h");
});

const Window = @import("window.zig");

const WindowManager = @This();
windows: std.ArrayList(Window),
selected_window_id: usize,

pub fn init(alloc: Allocator) !WindowManager {
    return .{
        .windows = std.ArrayList(Window).init(alloc),
        .selected_window_id = 0,
    };
}

pub fn deinit(self: *WindowManager) void {
    self.windows.deinit();
}
