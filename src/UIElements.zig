const std = @import("std");
//const math = std.math;
const Allocator = std.mem.Allocator;

const raylib = @cImport({
    @cInclude("raylib.h");
});

const App = @import("App.zig");

const Anchor = enum {
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

pub fn arg_init(refs: App.AppRefs, x: i16, y: i16, width: i16, height: i16, anchoring: Anchor, content: [50]u8) UIElement {
    var cntnt = std.ArrayList(u8).init(refs.alloc);
    cntnt.appendSlice(content);

    return .{
        .x = x,
        .y = y,
        .width = width,
        .height = height,
        .anchor = anchoring,
        .content = cntnt,
    };
}

pub fn deinit(self: *UIElement) void {
    self.content.deinit();
}
