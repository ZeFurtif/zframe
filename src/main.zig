const std = @import("std");
const expect = std.testing.expect;
const Allocator = std.mem.Allocator;

const raylib = @cImport({
    @cInclude("raylib.h");
});

const App = @import("App.zig");
const Canvas = @import("Canvas.zig");
const Gui = @import("Gui.zig");
const UserAction = Gui.UserAction;

pub fn main() !void {
    //MEMORY
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) expect(false) catch @panic("MEMORY LEAK");
    }

    //INITS
    var canvas = try Canvas.init(alloc);
    defer canvas.deinit();

    var gui = try Gui.init(alloc);
    defer gui.deinit();

    var camera: raylib.Camera2D = raylib.Camera2D{};

    const app_refs: App.AppRefs = .{
        .alloc = alloc,
        .canvas = &canvas,
        .gui = &gui,
        .camera = &camera,
    };

    //try main_loop(app_refs);
    const main_loop_thread = try std.Thread.spawn(.{}, main_loop, .{app_refs});
    main_loop_thread.join();
}

pub fn main_loop(refs: App.AppRefs) !void {
    raylib.SetConfigFlags(raylib.FLAG_WINDOW_RESIZABLE);
    raylib.InitWindow(800, 500, "zframe");
    raylib.MaximizeWindow();

    refs.canvas.reset_camera(refs);
    refs.canvas.new_layer(refs);

    //raylib.SetTargetFPS(raylib.GetMonitorRefreshRate(0));

    while (!raylib.WindowShouldClose()) {
        {
            refs.gui.update(refs);
            refs.canvas.update(refs);
        }
        {
            raylib.BeginDrawing();
            raylib.ClearBackground(raylib.DARKGRAY);

            raylib.BeginMode2D(refs.camera.*);
            refs.canvas.render(refs);
            raylib.EndMode2D();

            refs.gui.render(refs);

            raylib.DrawFPS(10, 10);

            raylib.EndDrawing();
        }
    }
    raylib.CloseWindow();
}
