const std = @import("std");
const expect = std.testing.expect;
const Allocator = std.mem.Allocator;

const raylib = @import("raylib");
const raygui = @import("raygui");

const App = @import("App.zig");
const Canvas = @import("Canvas.zig");
const Gui = @import("Gui.zig");
const Toolbox = @import("Toolbox.zig");
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

    var toolbox = Toolbox.init();
    defer toolbox.deinit();

    var camera = raylib.Camera2D{ .offset = undefined, .rotation = undefined, .target = undefined, .zoom = undefined };

    const app_refs: App.AppRefs = .{
        .alloc = alloc,
        .canvas = &canvas,
        .gui = &gui,
        .camera = &camera,
        .toolbox = &toolbox,
    };

    //try main_loop(app_refs);
    const main_loop_thread = try std.Thread.spawn(.{}, main_loop, .{app_refs});
    main_loop_thread.join();
}

pub fn main_loop(refs: App.AppRefs) !void {
    const flags = raylib.ConfigFlags{ .window_resizable = true };
    raylib.setConfigFlags(flags);
    raylib.initWindow(800, 500, "zframe");
    raylib.maximizeWindow();

    refs.canvas.reset_camera(refs);
    refs.canvas.new_layer(refs);

    while (!raylib.windowShouldClose()) {
        {
            refs.gui.update(refs);
            refs.canvas.update(refs);
        }
        {
            raylib.beginDrawing();
            raylib.clearBackground(raylib.Color.dark_gray);

            raylib.beginMode2D(refs.camera.*);
            refs.canvas.render(refs);
            raylib.endMode2D();

            refs.gui.render(refs);

            raylib.drawFPS(10, 10);

            raylib.endDrawing();
        }
    }
    raylib.closeWindow();
}
