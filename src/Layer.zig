const std = @import("std");
const Allocator = std.mem.Allocator;

const raylib = @cImport({
    @cInclude("raylib.h");
});

const Layer = @This();
target: raylib.RenderTexture2D,
target_history: std.ArrayList(raylib.RenderTexture2D),

pub fn init(alloc: Allocator) !Layer {
    return .{
        .target = raylib.RenderTexture2D{},
        .target_history = std.ArrayList(raylib.RenderTexture2D).init(alloc),
    };
}

pub fn deinit(self: *Layer) void {
    self.target_history.deinit();
}

pub fn new_target(self: *Layer, width: i32, height: i32) void {
    self.target = raylib.LoadRenderTexture(width, height);
}