const std = @import("std");
//const math = std.math;
const Allocator = std.mem.Allocator;

const raylib = @cImport({
    @cInclude("raylib.h");
});

const App = @import("App.zig");
const UIElement = @import("UIElements.zig");

const Layout = @This();
ui_elements: std.ArrayList(UIElement),

pub fn init(refs: App.AppRefs) Layout {
    return .{
        .ui_elements = std.ArrayList(UIElement).init(refs.alloc),
    };
}

pub fn deinit(self: *Layout) void {
    self.ui_elements.deinit();
}
