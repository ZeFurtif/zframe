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
            refs.canvas.render();
            raylib.EndMode2D();

            refs.gui.render();

            raylib.DrawFPS(10, 10);

            var actual_i: usize = 0;
            for (0..refs.gui.history.items.len) |i| {
                if (refs.gui.history.items[i] != UserAction.none) {
                    const new_pad = @as(i32, @intCast(actual_i)) * 25;
                    const alpha = [_]u8{ 255, 220, 180, 130, 100, 70, 50, 30, 10, 5 };
                    const new_color = raylib.Color{ .r = 255, .g = 255, .b = 255, .a = alpha[actual_i] };
                    raylib.BeginBlendMode(raylib.BLEND_ALPHA);
                    raylib.DrawText(@tagName(refs.gui.history.items[i]), 10, raylib.GetScreenHeight() - 25 - new_pad, 20, new_color);
                    raylib.EndBlendMode();
                    actual_i += 1;
                }
            }
            raylib.EndDrawing();
        }
    }
    raylib.CloseWindow();
}
