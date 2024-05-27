const std = @import("std");
const expect = std.testing.expect;
const Allocator = std.mem.Allocator;

const raylib = @cImport({
    @cInclude("raylib.h");
});

const App = @import("App.zig");
const Canvas = @import("canvas/Canvas.zig");
const Gui = @import("gui/Gui.zig");

pub fn main() !void {
    //MEMORY
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) expect(false) catch @panic("TEST FAIL");
    }

    //INITS
    var canvas = try Canvas.init(alloc);
    defer canvas.deinit();

    //var window_manager = try WindowManager.init(alloc);
    //defer window_manager.deinit();

    var gui = try Gui.init(alloc);
    defer gui.deinit();

    const app_refs: App.AppRefs = .{
        .alloc = alloc,
        .canvas = &canvas,
        .gui = &gui,
    };

    const main_loop_thread = try std.Thread.spawn(.{}, main_loop, .{app_refs});
    main_loop_thread.join();
}

pub fn main_loop(refs: App.AppRefs) !void {
    _ = refs;
    while (!raylib.WindowShouldClose()) {
        {
            //refs.canvas.update();
            //refs.window_manager.update();
        }
    }
}
