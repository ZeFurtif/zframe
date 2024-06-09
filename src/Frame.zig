const std = @import("std");
const Allocator = std.mem.Allocator;

const raylib = @import("raylib");

const App = @import("App.zig");

const Frame = @This();
target: raylib.RenderTexture2D,
exposure: u8,

pub fn init() Frame {
    return .{
        .target = raylib.RenderTexture2D{ .id = 0, .texture = undefined, .depth = undefined },
        .exposure = 1,
    };
}
pub fn new_target(self: *Frame, width: i32, height: i32) void {
    self.target = raylib.loadRenderTexture(width, height);
}

pub fn draw(self: *Frame, pos_x: i32, pos_y: i32, refs: App.AppRefs) void {
    raylib.beginTextureMode(self.target);
    raylib.drawCircle(pos_x, pos_y, 5, refs.toolbox.current_color);
    raylib.endTextureMode();
}

pub fn render(self: *Frame, refs: App.AppRefs) void {
    raylib.drawTextureRec(self.target.texture, refs.canvas.rect, raylib.Vector2{ .x = 0, .y = 0 }, raylib.Color.white);
}
