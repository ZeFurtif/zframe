const std = @import("std");
const math = std.math;
const Allocator = std.mem.Allocator;

const raylib = @import("raylib");
const raymath = @import("raymath");

const App = @import("App.zig");
const Layer = @import("Layer.zig");
const UserAction = @import("Gui.zig").UserAction;

const utilty = @import("Utility.zig");

pub const CanvasState = struct {
    is_playing: bool = false,
    looping_enabled: bool = true,
    elapsed: f32 = 0,
    is_dragged: bool = false,
    mouse_offset_x: i32 = 0,
    mouse_offset_y: i32 = 0,
    saved_camera_x: f32 = 0,
    saved_camera_y: f32 = 0,
    draw_pos: raylib.Vector2 = .{ .x = 0, .y = 0 },
};

pub const SequenceSettings = struct {
    start: usize = 0,
    end: usize = 128,
    framerate: f32 = 24.0,
};

const Canvas = @This();
width: i32,
height: i32,
rect: raylib.Rectangle,
layers: std.ArrayList(Layer),
selected_layer_id: usize,
current_frame: usize,
canvas_state: CanvasState,
sequenceSettings: SequenceSettings,

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
        .current_frame = 0,
        .canvas_state = CanvasState{},
        .sequenceSettings = SequenceSettings{},
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
        .x = @floatFromInt(@divTrunc(raylib.getScreenWidth(), 2)),
        .y = @floatFromInt(@divTrunc(raylib.getScreenHeight(), 2)),
    };
    refs.camera.rotation = 0;
    refs.camera.zoom = 0.5;
}

pub fn new_layer(self: *Canvas, refs: App.AppRefs) void {
    var layer = Layer.init(refs.alloc);
    layer.new_frame(refs);

    if (self.layers.append(layer)) |stmt| {
        _ = stmt;
    } else |e| {
        std.log.debug("{any}", .{e});
    }
}

pub fn play(refs: App.AppRefs) void {
    refs.canvas.canvas_state.is_playing = !refs.canvas.canvas_state.is_playing;
}

pub fn go_to_prev_frame(refs: App.AppRefs) void {
    if (refs.canvas.current_frame > refs.canvas.sequenceSettings.start) {
        refs.canvas.current_frame -= 1;
    }
}

pub fn go_to_next_frame(refs: App.AppRefs) void {
    if (refs.canvas.current_frame < refs.canvas.sequenceSettings.end) {
        refs.canvas.current_frame += 1;
    }
}

pub fn get_full_len(refs: App.AppRefs) usize {
    var ret: usize = 0;
    for (refs.canvas.layers.items[refs.canvas.selected_layer_id].frames.items) |frame| {
        ret += frame.exposure;
    }
    return ret;
}

pub fn extend_exposure(refs: App.AppRefs) void {
    const frame_id = refs.canvas.layers.items[refs.canvas.selected_layer_id].get_current_frame_index(refs.canvas.current_frame) orelse return;
    refs.canvas.layers.items[refs.canvas.selected_layer_id].frames.items[frame_id].exposure += 1;
}

pub fn reduce_exposure(refs: App.AppRefs) void {
    const frame_id = refs.canvas.layers.items[refs.canvas.selected_layer_id].get_current_frame_index(refs.canvas.current_frame) orelse return;
    if (refs.canvas.layers.items[refs.canvas.selected_layer_id].frames.items[frame_id].exposure > 1) {
        refs.canvas.layers.items[refs.canvas.selected_layer_id].frames.items[frame_id].exposure -= 1;
    }
}

pub fn check_frame_overflow(refs: App.AppRefs) bool {
    return (refs.canvas.current_frame > refs.canvas.sequenceSettings.start and refs.canvas.current_frame < refs.canvas.sequenceSettings.end);
}

pub fn get_current_frame_string(refs: App.AppRefs) ?[128]u8 {
    var ret_str = [_]u8{0} ** 128;
    var cnt: usize = 0;
    for ("frame: ") |char| {
        ret_str[cnt] = char;
        cnt += 1;
    }
    var buf: [20]u8 = undefined;
    const str = utilty.intToString(refs.canvas.current_frame, &buf) catch unreachable;
    for (str) |char| {
        ret_str[cnt] = char;
        cnt += 1;
    }
    return ret_str;
}

pub fn update(self: *Canvas, refs: App.AppRefs) void {
    self.interact(refs);
    if (self.canvas_state.is_dragged) {
        const cam_offset_x = @as(f32, @floatFromInt(raylib.getMouseX() - self.canvas_state.mouse_offset_x));
        const cam_offset_y = @as(f32, @floatFromInt(raylib.getMouseY() - self.canvas_state.mouse_offset_y));
        refs.camera.target.x = self.canvas_state.saved_camera_x - (cam_offset_x / refs.camera.zoom);
        refs.camera.target.y = self.canvas_state.saved_camera_y - (cam_offset_y / refs.camera.zoom);
    }

    if (self.canvas_state.is_playing) {
        self.canvas_state.elapsed += raylib.getFrameTime();
        if (self.canvas_state.elapsed > 1 / self.sequenceSettings.framerate) {
            self.canvas_state.elapsed -= 1 / self.sequenceSettings.framerate;
            self.current_frame += 1;
            if (!check_frame_overflow(refs)) {
                if (self.canvas_state.looping_enabled) {
                    self.current_frame = 0;
                    return;
                }
                self.current_frame -= 1;
                self.canvas_state.is_playing = false;
            }
        }
    }
}

pub fn interact(self: *Canvas, refs: App.AppRefs) void {
    const cur_action = refs.gui.get_action();

    const world_mouse_pos = raylib.getScreenToWorld2D(raylib.getMousePosition(), refs.camera.*);
    if (cur_action == UserAction.canvas_save) {
        const image = &raylib.loadImageFromTexture(self.layers.items[self.selected_layer_id].frames.items[self.current_frame].target.texture);
        std.log.debug("{any}", .{image});
        raylib.imageFlipVertical(@constCast(image));
        _ = raylib.exportImage(image.*, "my_amazing_painting.png");
        raylib.unloadImage(image.*);
        std.log.debug("{any}", .{@TypeOf(image.*)});
        std.log.debug("SAVED", .{});
    }

    if (cur_action == UserAction.canvas_reset_transform) {
        self.reset_camera(refs);
        return;
    }

    if (cur_action == UserAction.canvas_move) {
        raylib.setMouseCursor(9);
        if (!self.canvas_state.is_dragged) {
            self.canvas_state.is_dragged = true;
            self.canvas_state.mouse_offset_x = raylib.getMouseX();
            self.canvas_state.mouse_offset_y = raylib.getMouseY();
            self.canvas_state.saved_camera_x = refs.camera.target.x;
            self.canvas_state.saved_camera_y = refs.camera.target.y;
        }
        return;
    }
    if (cur_action == UserAction.canvas_scale) {
        refs.camera.zoom += (raylib.getMouseWheelMove() * 0.1 * refs.camera.zoom);
        refs.camera.zoom = math.clamp(refs.camera.zoom, 0.05, 5);
        return;
    }
    if (cur_action == UserAction.interact and self.is_mouse_inside(world_mouse_pos) and self.layers.items.len > 0) {
        const frame_id = refs.canvas.layers.items[refs.canvas.selected_layer_id].get_current_frame_index(refs.canvas.current_frame) orelse return;
        while (raymath.vector2Distance(self.canvas_state.draw_pos, world_mouse_pos) > refs.toolbox.current_brush_size / 2 and refs.toolbox.current_brush_size != 0) {
            self.canvas_state.draw_pos = raymath.vector2MoveTowards(self.canvas_state.draw_pos, world_mouse_pos, refs.toolbox.current_brush_size);
            self.layers.items[self.selected_layer_id].frames.items[frame_id].draw(self.canvas_state.draw_pos, refs);
        }
        return;
    }
    if (cur_action == UserAction.none) {
        self.canvas_state.draw_pos = world_mouse_pos;
    }
    self.canvas_state.is_dragged = false;
    raylib.setMouseCursor(0);
}

pub fn render(self: *Canvas, refs: App.AppRefs) void {
    raylib.drawRectangle(@intFromFloat(self.rect.x), @intFromFloat(self.rect.y), @intFromFloat(self.rect.width), @intFromFloat(-self.rect.height), raylib.Color.white);
    var i: usize = 0;
    while (i < self.layers.items.len) {
        if (self.layers.items[i].active) {
            self.layers.items[i].render(refs);
        }
        i += 1;
    }
}
