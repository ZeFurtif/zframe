const std = @import("std");
const Allocator = std.mem.Allocator;

const raylib = @cImport({
    @cInclude("raylib.h");
});

const App = @import("App.zig");

const Frame = @This();
target: raylib.RenderTexture2D,
exposure: u8,

pub fn init() Frame {
    return .{
        .target = raylib.RenderTexture2D{},
        .exposure = 1,
    };
}
pub fn new_target(self: *Frame, width: i32, height: i32) void {
    self.target = raylib.LoadRenderTexture(width, height);
}

pub fn draw(self: *Frame, pos_x: i32, pos_y: i32) void {
    raylib.BeginTextureMode(self.target);
    raylib.DrawCircle(pos_x, pos_y, 5, raylib.BLACK);
    raylib.EndTextureMode();
}

pub fn render(self: *Frame, refs: App.AppRefs) void {
    raylib.DrawTextureRec(self.target.texture, refs.canvas.rect, raylib.Vector2{}, raylib.WHITE);
}
