const std = @import("std");
//const math = std.math;
const Allocator = std.mem.Allocator;

const raylib = @import("raylib");
const raygui = @import("raygui");

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
    fill,
};

pub const ElementType = enum {
    text,
    button,
    color_picker,
    timeline,
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
on_interact: *const fn (App.AppRefs) void,

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
        .on_interact = &base_interact,
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
        .on_interact = &base_interact,
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

pub fn base_interact(refs: App.AppRefs) void {
    _ = refs;
    return;
}

pub fn buildRec(self: *UIElement, parent_x: i32, parent_y: i32, parent_width: i32, parent_height: i32) raylib.Rectangle {
    const navbar_height = 24;
    switch (self.anchor) {
        Anchor.top_left => {
            return raylib.Rectangle{ .x = @floatFromInt(parent_x + self.x), .y = @floatFromInt(parent_y + self.y + navbar_height), .width = @floatFromInt(self.width), .height = @floatFromInt(self.height - navbar_height) };
        },
        Anchor.top_center => {
            return raylib.Rectangle{ .x = @floatFromInt(parent_x + self.x + @divFloor(parent_width, 2) - @divFloor(self.width, 2)), .y = @floatFromInt(parent_y + self.y + navbar_height), .width = @floatFromInt(self.width), .height = @floatFromInt(self.height - navbar_height) };
        },
        Anchor.top_right => {
            return raylib.Rectangle{ .x = @floatFromInt(parent_x - self.x + parent_width - self.width), .y = @floatFromInt(parent_y + self.y + navbar_height), .width = @floatFromInt(self.width), .height = @floatFromInt(self.height - navbar_height) };
        },
        Anchor.middle_left => {
            return raylib.Rectangle{ .x = @floatFromInt(parent_x + self.x), .y = @floatFromInt(parent_y + self.y + @divTrunc(parent_height, 2) + navbar_height), .width = @floatFromInt(self.width), .height = @floatFromInt(self.height - navbar_height) };
        },
        Anchor.middle_center => {
            return raylib.Rectangle{ .x = @floatFromInt(parent_x + self.x + @divFloor(parent_width, 2) - @divFloor(self.width, 2)), .y = @floatFromInt(parent_y + self.y + @divTrunc(parent_height, 2) + navbar_height), .width = @floatFromInt(self.width), .height = @floatFromInt(self.height - navbar_height) };
        },
        Anchor.middle_right => {
            return raylib.Rectangle{ .x = @floatFromInt(parent_x - self.x + parent_width - self.width), .y = @floatFromInt(parent_y + self.y + @divTrunc(parent_height, 2) + navbar_height), .width = @floatFromInt(self.width), .height = @floatFromInt(self.height - navbar_height) };
        },
        Anchor.bottom_left => {
            return raylib.Rectangle{ .x = @floatFromInt(parent_x + self.x), .y = @floatFromInt(parent_y + self.y + parent_height + navbar_height), .width = @floatFromInt(self.width), .height = @floatFromInt(self.height - navbar_height) };
        },
        Anchor.bottom_center => {
            return raylib.Rectangle{ .x = @floatFromInt(parent_x + self.x + @divFloor(parent_width, 2) - @divFloor(self.width, 2)), .y = @floatFromInt(parent_y + self.y + parent_height + navbar_height), .width = @floatFromInt(self.width), .height = @floatFromInt(self.height - navbar_height) };
        },
        Anchor.bottom_right => {
            return raylib.Rectangle{ .x = @floatFromInt(parent_x - self.x + parent_width - self.width), .y = @floatFromInt(parent_y + self.y + parent_height + navbar_height), .width = @floatFromInt(self.width), .height = @floatFromInt(self.height - navbar_height) };
        },
        Anchor.fill => {
            return raylib.Rectangle{ .x = @floatFromInt(parent_x + self.x), .y = @floatFromInt(parent_y + self.y + navbar_height), .width = @floatFromInt(parent_width - self.width), .height = @floatFromInt(parent_height - self.height - 2 * navbar_height) };
        },
    }
}

pub fn render(self: *UIElement, parent_x: i32, parent_y: i32, parent_width: i32, parent_height: i32, refs: App.AppRefs) void {
    const rec = self.buildRec(parent_x, parent_y, parent_width, parent_height);

    self.content = self.get_content(refs) orelse self.content;
    const content = self.content[0 .. self.content.len - 1 :0];

    switch (self.element_type) {
        ElementType.button => {
            if (raygui.guiButton(rec, content) != 0) {
                self.on_interact(refs);
            }
        },
        ElementType.text => {
            _ = raygui.guiLabel(rec, content);
        },
        ElementType.color_picker => {
            _ = raygui.guiColorPicker(rec, content, &refs.toolbox.current_color);
        },
        ElementType.timeline => {
            const frame_size: i16 = 20;
            const layer_height: i16 = 30;
            const layer_name_width: i16 = 60;

            for (refs.canvas.layers.items, 0..) |layer, i| {
                const layer_title_rect = raylib.Rectangle{ .x = rec.x, .y = rec.y + @as(f32, @floatFromInt(@as(i32, @intCast(i * layer_height)))), .width = layer_name_width, .height = @as(f32, @floatFromInt(@as(i32, @intCast((i + 1) * layer_height)))) };
                _ = raygui.guiDummyRec(layer_title_rect, "Layer");
                for (0..refs.canvas.sequenceSettings.end) |frame| {
                    const frame_rect = raylib.Rectangle{ .x = rec.x + layer_name_width + @as(f32, @floatFromInt(@as(i32, @intCast(frame * frame_size)))), .y = rec.y + @as(f32, @floatFromInt(@as(i32, @intCast(i * layer_height)))), .width = @floatFromInt(frame_size), .height = @floatFromInt(layer_height) };
                    _ = raygui.guiPanel(frame_rect, undefined);
                }
                var cur_frame: usize = 0;
                for (layer.frames.items) |frame| {
                    const frame_rect = raylib.Rectangle{ .x = rec.x + layer_name_width + @as(f32, @floatFromInt(@as(i32, @intCast(cur_frame * frame_size)))), .y = rec.y + @as(f32, @floatFromInt(@as(i32, @intCast(i * layer_height)))), .width = @floatFromInt(frame_size * frame.exposure), .height = @floatFromInt(layer_height) };
                    //_ = raygui.guiButton(frame_rect, undefined);
                    _ = raylib.drawRectangleRec(frame_rect, raylib.Color.light_gray);
                    _ = raylib.drawRectangleLinesEx(frame_rect, 1, raylib.Color.gray);
                    cur_frame += frame.exposure;
                }
            }

            raylib.beginBlendMode(raylib.BlendMode.blend_alpha);
            raylib.drawRectangle(@as(i32, @intCast(refs.canvas.current_frame * frame_size + 60)) + @as(i32, @intFromFloat(rec.x)), @intFromFloat(rec.y), frame_size, @intFromFloat(rec.height - 50), raylib.colorAlpha(raylib.Color.blue, 0.2));
            raylib.drawRectangle(@as(i32, @intCast(refs.canvas.current_frame * frame_size + 60)) + @as(i32, @intFromFloat(rec.x)), @as(i32, @intCast(refs.canvas.selected_layer_id * layer_height)) + @as(i32, @intFromFloat(rec.y)), frame_size, layer_height, raylib.colorAlpha(raylib.Color.blue, 0.25));
            raylib.endBlendMode();
        },
    }
}
