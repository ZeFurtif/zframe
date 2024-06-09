const std = @import("std");
const Allocator = std.mem.Allocator;

const raylib = @import("raylib");

const Canvas = @import("Canvas.zig");
const Toolbox = @import("Toolbox.zig");
const Gui = @import("Gui.zig");

pub const AppRefs = struct {
    alloc: Allocator,
    canvas: *Canvas,
    gui: *Gui,
    camera: *raylib.Camera2D,
    toolbox: *Toolbox,
};

const App = @This();
refs: AppRefs,

pub fn init(refs: AppRefs) !App {
    return .{ .refs = refs };
}
