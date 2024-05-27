const std = @import("std");
const Allocator = std.mem.Allocator;

const raylib = @cImport({
    @cInclude("raylib.h");
});

const Layer = @import("layer.zig");

const Canvas = @This();
width: i32,
height: i32,

rect: raylib.Rectangle,

layers: std.ArrayList(Layer),
selected_layer_id: usize,

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
    };
}

pub fn deinit(self: *Canvas) void {
    self.layers.deinit();
}
