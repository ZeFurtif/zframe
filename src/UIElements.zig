const std = @import("std");
//const math = std.math;
const Allocator = std.mem.Allocator;

const raylib = @cImport({
    @cInclude("raylib.h");
});

const App = @import("App.zig");

pub const Anchor = enum {
    top_left,
    top_center,
    top_right,
    middle_left,
    middle_center,
    middle_right,
    bottom_left,
    bottom_center,
    bottom_right,
};

const UIElement = @This();
x: i16,
y: i16,
width: i16,
height: i16,
anchor: Anchor,
content: std.ArrayList(u8),

pub fn init(refs: App.AppRefs) UIElement {
    return .{
        .x = 0,
        .y = 0,
        .width = 0,
        .height = 0,
        .anchor = Anchor.top_left,
        .content = std.ArrayList(u8).init(refs.alloc),
    };
}

pub fn args_init(refs: App.AppRefs, x: i16, y: i16, width: i16, height: i16, anchoring: Anchor, content: []const u8) UIElement {
    var to_ret: UIElement = .{
        .x = x,
        .y = y,
        .width = width,
        .height = height,
        .anchor = anchoring,
        .content = std.ArrayList(u8).init(refs.alloc),
    };
    if (to_ret.content.appendSlice(content)) |stmt| {
        _ = stmt;
    } else |e| {
        std.log.debug("ERROR {any}", .{e});
    }
    return to_ret;
}

pub fn deinit(self: *UIElement) void {
    self.content.deinit();
}
