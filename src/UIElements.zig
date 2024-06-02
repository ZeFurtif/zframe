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

pub const ElementType = enum {
    text,
    button,
};

const UIElement = @This();
x: i16,
y: i16,
width: i16,
height: i16,
anchor: Anchor,
content: [128]u8,
get_content: *const fn (App.AppRefs) ?[128]u8,
element_type: ElementType,

pub fn init() UIElement {
    return .{
        .x = 0,
        .y = 0,
        .width = 0,
        .height = 0,
        .anchor = Anchor.top_left,
        .content = [128]u8,
        .get_content = &base_get,
        .element_type = ElementType.text,
    };
}

pub fn args_init(x: i16, y: i16, width: i16, height: i16, anchoring: Anchor, content: []const u8, element_type: ElementType) UIElement {
    var to_ret: UIElement = .{
        .x = x,
        .y = y,
        .width = width,
        .height = height,
        .anchor = anchoring,
        .content = [_]u8{undefined} ** 128,
        .get_content = &base_get,
        .element_type = element_type,
    };
    for (content, 0..) |byte, i| {
        to_ret.content[i] = byte;
    }
    return to_ret;
}

pub fn base_get(refs: App.AppRefs) ?[128]u8 {
    _ = refs;
    return null;
}

pub fn render(self: *UIElement, parent_x: i32, parent_y: i32, refs: App.AppRefs) void {
    const world_x = parent_x + self.x;
    const world_y = parent_y + self.y;
    switch (self.element_type) {
        ElementType.button => {
            raylib.DrawRectangle(world_x, world_y, self.width, self.height, raylib.DARKGRAY);
        },
        ElementType.text => {
            self.content = self.get_content(refs) orelse self.content;
            std.log.debug("\n{s}", .{&self.content});
            raylib.DrawText(&self.content, world_x, world_y, self.height, raylib.WHITE);
        },
    }
}
