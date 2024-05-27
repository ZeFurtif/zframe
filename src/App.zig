const std = @import("std");
const Allocator = std.mem.Allocator;

const Canvas = @import("canvas/Canvas.zig");
const Gui = @import("gui/Gui.zig");

pub const AppRefs = struct {
    alloc: Allocator,
    canvas: *Canvas,
    gui: *Gui,
};

const App = @This();
refs: AppRefs,

pub fn init(refs: AppRefs) !App {
    return .{ .refs = refs };
}
