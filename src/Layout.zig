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

pub fn addElement(self: *Layout, refs: App.AppRefs) void {
    if (self.ui_elements.append(UIElement.args_init(refs, 5, 5, 100, 100, UIElement.Anchor.top_left, "Hello World"))) |stmt| {
        _ = stmt;
    } else |e| {
        std.log.debug("ERROR {any}", .{e});
    }
}
