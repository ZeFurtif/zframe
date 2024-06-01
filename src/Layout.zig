const std = @import("std");
//const math = std.math;
const Allocator = std.mem.Allocator;

const raylib = @cImport({
    @cInclude("raylib.h");
});

const App = @import("App.zig");
const UIElement = @import("UIElements.zig");
const ElementType = UIElement.ElementType;

const LayoutType = enum {
    user_action_history,
    timeline,
    onion_skin,
};

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

pub fn addElement(self: *Layout) void {
    if (self.ui_elements.append(UIElement.args_init(5, 5, 100, 100, UIElement.Anchor.top_left, "Hello World", ElementType.text))) |stmt| {
        _ = stmt;
    } else |e| {
        std.log.debug("ERROR {any}", .{e});
    }
}

pub fn fillLayout(self: *Layout, window_type: LayoutType) void {
    switch (window_type) {
        LayoutType.user_action_history => {
            self.ui_elements.append(UIElement.args_init(5, 5, 100, 20, UIElement.Anchor.top_left, "History", ElementType.text));
        },
        LayoutType.timeline => {},
    }
}

pub fn render(self: *Layout, parent_x: i32, parent_y: i32) void {
    var i: usize = 0;
    while (i != self.ui_elements.items.len) {
        self.ui_elements.items[i].render(parent_x, parent_y);
        i += 1;
    }
}
