const std = @import("std");
const Allocator = std.mem.Allocator;

const raylib = @cImport({
    @cInclude("raylib.h");
});

const App = @import("App.zig");
const Layer = @import("Layer.zig");
const UserAction = @import("Gui.zig").UserAction;

pub const CanvasState = struct {
    is_dragged: bool = false,
    mouse_offset_x: i32 = 0,
    mouse_offset_y: i32 = 0,
    saved_camera_x: f32 = 0,
    saved_camera_y: f32 = 0,
};

const Canvas = @This();
width: i32,
height: i32,
rect: raylib.Rectangle,
layers: std.ArrayList(Layer),
selected_layer_id: usize,
canvas_state: CanvasState,

pub fn init(alloc: Allocator) !Canvas {
    return .{
        .width = 800,
        .height = 600,
        .rect = .{
            .x = 0,
            .y = 0,
            .width = @as(f32, @floatFromInt(800)),
            .height = @as(f32, @floatFromInt(600)),
        },
        .layers = std.ArrayList(Layer).init(alloc),
        .selected_layer_id = 0,
        .canvas_state = CanvasState{},
    };
}

pub fn deinit(self: *Canvas) void {
    self.layers.deinit();
}

pub fn update(self: *Canvas, refs: App.AppRefs) void {
    if (refs.gui.get_action() == UserAction.canvas_move) {
        if (!self.canvas_state.is_dragged) {
            self.canvas_state.is_dragged = true;
            self.canvas_state.mouse_offset_x = raylib.GetMouseX();
            self.canvas_state.mouse_offset_y = raylib.GetMouseY();
            self.canvas_state.saved_camera_x = refs.camera.target.x;
            self.canvas_state.saved_camera_y = refs.camera.target.y;
        }
    }
}

pub fn render(self: *Canvas) void {
    raylib.DrawRectangle(@intFromFloat(self.rect.x), @intFromFloat(self.rect.y), @intFromFloat(self.rect.width), @intFromFloat(-self.rect.height), raylib.WHITE);
    var i = self.layers.items.len;
    while (i != 0) {
        i -= 1;
        raylib.DrawTextureRec(self.layers.items[i].target.texture, self.rect, raylib.Vector2{}, raylib.WHITE);
    }
}
