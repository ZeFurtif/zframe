const std = @import("std");
const Allocator = std.mem.Allocator;

const raylib = @cImport({
    @cInclude("raylib.h");
});

const Layer = @This();
target: raylib.RenderTexture2D,
target_history: std.ArrayList(raylib.Texture),
saved: bool,

pub fn init(alloc: Allocator) Layer {
    return .{
        .target = raylib.RenderTexture2D{},
        .target_history = std.ArrayList(raylib.Texture).init(alloc),
        .saved = false,
    };
}

pub fn deinit(self: *Layer) void {
    self.target_history.deinit();
}

pub fn new_target(self: *Layer, width: i32, height: i32) void {
    self.target = raylib.LoadRenderTexture(width, height);
}

pub fn save_history(self: *Layer) void {
    if (self.target_history.append(self.target.texture)) |stmt| {
        self.saved = true;
        _ = stmt;
    } else |e| {
        std.log.debug("{any}", .{e});
    }

    if (self.target_history.items.len > 5) {
        _ = self.target_history.pop();
    }
    std.log.debug("{any}", .{self.target_history.items.len});
}

pub fn undo(self: *Layer) void {
    if (self.target_history.items.len == 0) return;
    self.target.texture = self.target_history.items[0];
    _ = self.target_history.orderedRemove(0);
}
