const std = @import("std");
//const math = std.math;
const Allocator = std.mem.Allocator;

const raylib = @import("raylib");

const App = @import("App.zig");
const Gui = @import("Gui.zig");
const UIElement = @import("UIElements.zig");
const ElementType = UIElement.ElementType;

pub const LayoutType = enum {
    default,
    history,
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

pub fn addElement(self: *Layout, x: i16, y: i16, width: i16, height: i16, anchoring: UIElement.Anchor, content: []const u8, element_type: ElementType) void {
    if (self.ui_elements.append(UIElement.args_init(x, y, width, height, anchoring, content, element_type))) |stmt| {
        _ = stmt;
    } else |e| {
        std.log.debug("ERROR {any}", .{e});
    }
}

pub fn fillLayout(self: *Layout, window_type: LayoutType) void {
    switch (window_type) {
        LayoutType.default => {},
        LayoutType.history => {
            self.addElement(10, 5, 100, 30, UIElement.Anchor.top_left, "History", ElementType.text);
            self.addElement(20, 40, 100, 20, UIElement.Anchor.top_left, "", ElementType.text);
            self.ui_elements.items[1].get_content = &Gui.get_action_history_string;
        },
        LayoutType.timeline => {},
        LayoutType.onion_skin => {},
    }
}

pub fn render(self: *Layout, parent_x: i32, parent_y: i32, refs: App.AppRefs) void {
    var i: usize = 0;
    while (i != self.ui_elements.items.len) {
        self.ui_elements.items[i].render(parent_x, parent_y, refs);
        i += 1;
    }
}
