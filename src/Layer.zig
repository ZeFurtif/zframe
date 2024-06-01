const std = @import("std");
const Allocator = std.mem.Allocator;

const raylib = @cImport({
    @cInclude("raylib.h");
});

const App = @import("App.zig");
const Frame = @import("Frame.zig");

const Layer = @This();
frames: std.ArrayList(Frame),
active: bool,

pub fn init(alloc: Allocator) Layer {
    return .{
        .frames = std.ArrayList(Frame).init(alloc),
        .active = true,
    };
}

pub fn deinit(self: *Layer) void {
    self.frames.deinit();
}

pub fn new_frame(self: *Layer, refs: App.AppRefs) void {
    var frame = Frame.init();
    frame.new_target(refs.canvas.width, refs.canvas.height);
    if (self.frames.append(frame)) |stmt| {
        _ = stmt;
    } else |e| {
        std.log.debug("ERROR : {any}", .{e});
    }
}

pub fn get_current_frame_index(self: *Layer, pos: usize) ?usize {
    var i: usize = 0;
    var cur_pos: usize = 0;
    while (i < self.frames.items.len) {
        cur_pos += self.frames.items[i].exposure;
        if (cur_pos >= pos) {
            return i;
        }
        i += 1;
    }
    return null;
}

pub fn render(self: *Layer, refs: App.AppRefs) void {
    const i = self.get_current_frame_index(refs.canvas.current_frame) orelse return;

    self.frames.items[i].render(refs);
}
