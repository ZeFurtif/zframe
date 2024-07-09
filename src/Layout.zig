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

pub const LayoutDirection = enum {
    vertical,
    horizontal,
    custom,
};

const Layout = @This();
ui_elements: std.ArrayList(UIElement),
layout_direction: LayoutDirection,

pub fn init(refs: App.AppRefs) Layout {
    return .{
        .ui_elements = std.ArrayList(UIElement).init(refs.alloc),
        .layout_direction = LayoutDirection.custom,
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
            self.addElement(15, 10, 55, 25, UIElement.Anchor.fill, "Color", ElementType.color_picker);
        },
        LayoutType.timeline => {
            self.addElement(0, 5, 60, 50, UIElement.Anchor.top_left, "frame: 0", ElementType.text);
            self.addElement(15, 30, 50, 50, UIElement.Anchor.top_left, "Prev", ElementType.button);
            self.addElement(75, 30, 50, 50, UIElement.Anchor.top_left, "Next", ElementType.button);

            self.ui_elements.items[0].get_content = &Canvas.get_current_frame_string;
            self.ui_elements.items[1].on_interact = &Canvas.go_to_prev_frame;
            self.ui_elements.items[2].on_interact = &Canvas.go_to_next_frame;

            self.addElement(135, 30, 50, 50, UIElement.Anchor.top_left, "Play", ElementType.button);
            self.ui_elements.items[3].on_interact = &Canvas.play;

            self.addElement(195, 30, 50, 50, UIElement.Anchor.top_left, "Exp+", ElementType.button);
            self.ui_elements.items[4].on_interact = &Canvas.extend_exposure;
            self.addElement(255, 30, 50, 50, UIElement.Anchor.top_left, "Exp-", ElementType.button);
            self.ui_elements.items[5].on_interact = &Canvas.reduce_exposure;

            self.addElement(5, 60, 10, 5, UIElement.Anchor.fill, "", ElementType.timeline);
        },
        LayoutType.onion_skin => {
            self.addElement(5, 10, 500, 100, UIElement.Anchor.top_left, "Onion Skin", ElementType.button);
        },
    }
}

pub fn layout_estimated_rectangle(self: *Layout, refs: App.AppRefs) raylib.Rectangle {
    var rect: raylib.Rectangle = raylib.Rectangle{ .x = 0, .y = 0, .height = 0, .width = 0 };
    switch (self.layout_direction) {
        LayoutDirection.custom => {
            for (self.ui_elements.items) |element| {
                rect.x = @min(@as(f32, @floatFromInt(element.x)), rect.x);
                rect.y = @min(@as(f32, @floatFromInt(element.y)), rect.y);
                rect.width = @max(@as(f32, @floatFromInt(element.width + element.x)), rect.width);
                rect.height = @max(@as(f32, @floatFromInt(element.height + element.y)), rect.height);

                if (element.element_type == ElementType.text) {
                    rect.height *= @floatFromInt(1 + std.mem.count(u8, &element.content, "\n\n"));
                    rect.height /= 1.5;
                }
                if (element.element_type == ElementType.timeline) {
                    rect.width = @floatFromInt(@as(i16, @intCast(refs.canvas.sequenceSettings.end * 20)) + element.x + 65);
                }
            }
        },
        LayoutDirection.horizontal => {
            for (self.ui_elements.items) |element| {
                rect.width = @max(@as(f32, @floatFromInt(element.width + element.x)), rect.width);
            }
        },
        LayoutDirection.vertical => {
            for (self.ui_elements.items) |element| {
                rect.height = @max(@as(f32, @floatFromInt(element.height + element.y)), rect.height);
            }
        },
    }
    return rect;
}

pub fn render(self: *Layout, parent_x: i32, parent_y: i32, parent_width: i32, parent_height: i32, refs: App.AppRefs) void {
    var i: usize = 0;
    //const content_rect = self.layout_estimated_rectangle();
    while (i != self.ui_elements.items.len) {
        self.ui_elements.items[i].render(parent_x, parent_y, parent_width, parent_height, refs);
        i += 1;
    }
}
