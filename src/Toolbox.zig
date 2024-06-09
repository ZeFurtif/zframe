const std = @import("std");
const math = std.math;
const Allocator = std.mem.Allocator;

const raylib = @import("raylib");

const Toolbox = @This();
current_color: raylib.Color,

pub fn init() Toolbox {
    return .{
        .current_color = raylib.Color.white,
    };
}

pub fn deinit(self: *Toolbox) void {
    std.log.debug("{any}", .{self.current_color});
}
