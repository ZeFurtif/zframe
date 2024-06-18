const std = @import("std");
//const math = std.math;
const Allocator = std.mem.Allocator;

const raylib = @import("raylib");

const App = @import("App.zig");
const Gui = @import("Gui.zig");
const Canvas = @import("Canvas.zig");
const UIElement = @import("UIElements.zig");
const ElementType = UIElement.ElementType;

pub const LayoutType = enum {
    default,
    history,
    color,
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
            self.addElement(20, 20, 20, 20, UIElement.Anchor.fill, "", ElementType.text);
            self.ui_elements.items[0].get_content = &Gui.get_action_history_string;
        },
        LayoutType.color => {
            self.addElement(15, 15, 55, 25, UIElement.Anchor.fill, "Color", ElementType.color_picker);
        },
        LayoutType.timeline => {
            self.addElement(0, 5, 60, 50, UIElement.Anchor.top_center, "frame: 0", ElementType.text);
            self.addElement(15, 30, 50, 50, UIElement.Anchor.top_left, "Prev", ElementType.button);
            self.addElement(15, 30, 50, 50, UIElement.Anchor.top_right, "Next", ElementType.button);

            self.ui_elements.items[0].get_content = &Canvas.get_current_frame_string;
            self.ui_elements.items[1].on_interact = &Canvas.go_to_prev_frame;
            self.ui_elements.items[2].on_interact = &Canvas.go_to_next_frame;

            self.addElement(0, 30, 50, 50, UIElement.Anchor.top_center, "Play", ElementType.button);
            self.ui_elements.items[3].on_interact = &Canvas.play;
        },
        LayoutType.onion_skin => {},
    }
}

pub fn render(self: *Layout, parent_x: i32, parent_y: i32, parent_width: i32, parent_height: i32, refs: App.AppRefs) void {
    var i: usize = 0;
    while (i != self.ui_elements.items.len) {
        self.ui_elements.items[i].render(parent_x, parent_y, parent_width, parent_height, refs);
        i += 1;
    }
}
