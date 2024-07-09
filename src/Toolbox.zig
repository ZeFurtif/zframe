const std = @import("std");
const math = std.math;
const Allocator = std.mem.Allocator;

const raylib = @import("raylib");

const Toolbox = @This();
current_color: raylib.Color,
current_timeline_pos: raylib.Vector2,

pub fn init() Toolbox {
    return .{
        .current_color = raylib.Color.black,
        .current_timeline_pos = raylib.Vector2{ .x = 0, .y = 0 },
    };
}

pub fn deinit(self: *Toolbox) void {
    std.log.debug("{any}", .{self.current_color});
}
