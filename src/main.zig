const std = @import("std");
const expect = std.testing.expect;
const Allocator = std.mem.Allocator;

const raylib = @cImport({
    @cInclude("raylib.h");
});

const App = @import("App.zig");
const Canvas = @import("Canvas.zig");
const Gui = @import("Gui.zig");

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

    var gui = try Gui.init(alloc);
    defer gui.deinit();

    var camera: raylib.Camera2D = raylib.Camera2D{};
    camera.target = raylib.Vector2{
        .x = @floatFromInt(@divTrunc(canvas.width, 2)),
        .y = @floatFromInt(@divTrunc(canvas.height, 2)),
    };
    camera.offset = raylib.Vector2{
        .x = @floatFromInt(@divTrunc(raylib.GetScreenWidth(), 2)),
        .y = @floatFromInt(@divTrunc(raylib.GetScreenHeight(), 2)),
    };
    camera.rotation = 0;
    camera.zoom = 1;

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
            refs.canvas.render();
            raylib.EndMode2D();

            refs.gui.render();

            raylib.DrawFPS(10, 10);
            raylib.DrawText(@tagName(refs.gui.get_action()), 10, 50, 20, raylib.WHITE);
            raylib.EndDrawing();
        }
    }
    raylib.CloseWindow();
}
