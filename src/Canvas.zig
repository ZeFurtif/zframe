const std = @import("std");
const math = std.math;
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
    draw_x: f32 = 0,
    draw_y: f32 = 0,
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
        .width = 1920,
        .height = 1080,
        .rect = .{
            .x = 0,
            .y = 0,
            .width = @as(f32, @floatFromInt(1920)),
            .height = @as(f32, @floatFromInt(-1080)),
        },
        .layers = std.ArrayList(Layer).init(alloc),
        .selected_layer_id = 0,
        .canvas_state = CanvasState{},
    };
}

pub fn deinit(self: *Canvas) void {
    for (0..self.layers.items.len) |i| {
        self.layers.items[i].deinit();
    }
    self.layers.deinit();
}

pub fn is_mouse_inside(self: *Canvas, world_mouse_pos: raylib.Vector2) bool {
    return world_mouse_pos.x >= 0 and world_mouse_pos.x <= 0 + @as(f32, @floatFromInt(self.width)) and world_mouse_pos.y >= 0 and world_mouse_pos.y <= 0 + @as(f32, @floatFromInt(self.height));
}

pub fn reset_camera(self: *Canvas, refs: App.AppRefs) void {
    refs.camera.target = raylib.Vector2{
        .x = @floatFromInt((@divTrunc(self.width, 2))),
        .y = @floatFromInt((@divTrunc(self.height, 2))),
    };
    refs.camera.offset = raylib.Vector2{
        .x = @floatFromInt(@divTrunc(raylib.GetScreenWidth(), 2)),
        .y = @floatFromInt(@divTrunc(raylib.GetScreenHeight(), 2)),
    };
    refs.camera.rotation = 0;
    refs.camera.zoom = 0.5;
}

pub fn new_layer(self: *Canvas, refs: App.AppRefs) void {
    var layer = Layer.init(refs.alloc);
    layer.new_target(self.width, self.height);

    if (self.layers.append(layer)) |stmt| {
        _ = stmt;
    } else |e| {
        std.log.debug("{any}", .{e});
    }
}

pub fn update(self: *Canvas, refs: App.AppRefs) void {
    self.interact(refs);
    if (self.canvas_state.is_dragged) {
        const cam_offset_x = @as(f32, @floatFromInt(raylib.GetMouseX() - self.canvas_state.mouse_offset_x));
        const cam_offset_y = @as(f32, @floatFromInt(raylib.GetMouseY() - self.canvas_state.mouse_offset_y));
        refs.camera.target.x = self.canvas_state.saved_camera_x - (cam_offset_x / refs.camera.zoom);
        refs.camera.target.y = self.canvas_state.saved_camera_y - (cam_offset_y / refs.camera.zoom);
    }
}

pub fn interact(self: *Canvas, refs: App.AppRefs) void {
    const cur_action = refs.gui.get_action();

    const world_mouse_pos = raylib.GetScreenToWorld2D(raylib.GetMousePosition(), refs.camera.*);
    // MOVEMENT
    if (cur_action == UserAction.canvas_reset_transform) {
        self.reset_camera(refs);
        return;
    }
    if (cur_action == UserAction.canvas_undo) {
        self.layers.items[self.selected_layer_id].undo();
        return;
    }
    if (cur_action == UserAction.canvas_move) {
        raylib.SetMouseCursor(raylib.MOUSE_CURSOR_RESIZE_ALL);
        if (!self.canvas_state.is_dragged) {
            self.canvas_state.is_dragged = true;
            self.canvas_state.mouse_offset_x = raylib.GetMouseX();
            self.canvas_state.mouse_offset_y = raylib.GetMouseY();
            self.canvas_state.saved_camera_x = refs.camera.target.x;
            self.canvas_state.saved_camera_y = refs.camera.target.y;
        }
        return;
    }
    if (cur_action == UserAction.canvas_scale) {
        refs.camera.zoom += (raylib.GetMouseWheelMove() * 0.1 * refs.camera.zoom);
        refs.camera.zoom = math.clamp(refs.camera.zoom, 0.05, 5);
        return;
    }
    if (cur_action == UserAction.interact and self.is_mouse_inside(world_mouse_pos) and self.layers.items.len > 0) {
        self.canvas_state.draw_x = @divTrunc((self.canvas_state.draw_x * 3 + world_mouse_pos.x), 4);
        self.canvas_state.draw_y = @divTrunc((self.canvas_state.draw_y * 3 + world_mouse_pos.y), 4);
        self.layers.items[self.selected_layer_id].saved = false;
        raylib.BeginTextureMode(self.layers.items[self.selected_layer_id].target);
        raylib.DrawCircle(@intFromFloat(self.canvas_state.draw_x), @intFromFloat(self.canvas_state.draw_y), 5, raylib.BLACK);
        raylib.EndTextureMode();
        return;
    }
    if (cur_action == UserAction.none) {
        if (self.layers.items[self.selected_layer_id].saved == false) {
            self.layers.items[self.selected_layer_id].save_history();
        }
        self.canvas_state.draw_x = world_mouse_pos.x;
        self.canvas_state.draw_y = world_mouse_pos.y;
    }
    self.canvas_state.is_dragged = false;
    raylib.SetMouseCursor(raylib.MOUSE_CURSOR_DEFAULT);
}

pub fn render(self: *Canvas) void {
    raylib.DrawRectangle(@intFromFloat(self.rect.x), @intFromFloat(self.rect.y), @intFromFloat(self.rect.width), @intFromFloat(-self.rect.height), raylib.WHITE);
    var i = self.layers.items.len;
    while (i != 0) {
        i -= 1;
        raylib.DrawTextureRec(self.layers.items[i].target.texture, self.rect, raylib.Vector2{}, raylib.WHITE);
    }
}
