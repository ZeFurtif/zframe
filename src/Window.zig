const std = @import("std");
const math = std.math;
const Allocator = std.mem.Allocator;

const raylib = @import("raylib");
const raygui = @import("raygui");

const App = @import("App.zig");
const Layout = @import("Layout.zig");
const UserAction = @import("Gui.zig").UserAction;

pub const WindowState = struct {
    is_moving: bool = false,
    is_scaling: bool = false,
    is_pinned: bool = false,
    mouse_offset_x: i32 = 0,
    mouse_offset_y: i32 = 0,
};

const Window = @This();
title: [32]u8,
x: i32,
y: i32,
width: i32,
height: i32,
window_state: WindowState,
layout: Layout,
scroll: raylib.Vector2,

pub fn init(refs: App.AppRefs) !Window {
    return .{
        .title = "Window",
        .x = 0,
        .y = 0,
        .width = 100,
        .height = 100,
        .window_state = WindowState{},
        .layout = Layout.init(refs),
        .scroll = raylib.Vector2{ .x = 0, .y = 0 },
    };
}

pub fn deinit(self: *Window) void {
    self.layout.deinit();
}

pub fn args_init(refs: App.AppRefs, title: []const u8, x: i32, y: i32, width: i32, height: i32) !Window {
    var to_return: Window = .{
        .title = [_]u8{undefined} ** 32,
        .x = x,
        .y = y,
        .width = width,
        .height = height,
        .window_state = WindowState{},
        .layout = Layout.init(refs),
        .scroll = raylib.Vector2{ .x = 0, .y = 0 },
    };
    for (title, 0..) |byte, i| {
        to_return.title[i] = byte;
    }
    return to_return;
}

pub fn is_mouse_inside(self: *Window) bool {
    const mouse_x = raylib.getMouseX();
    const mouse_y = raylib.getMouseY();
    return mouse_x >= self.x and mouse_x <= self.x + self.width and mouse_y >= self.y and mouse_y <= self.y + self.height;
}

pub fn is_mouse_on_move_area(self: *Window) bool {
    const mouse_x = raylib.getMouseX();
    const mouse_y = raylib.getMouseY();
    return mouse_x >= self.x and mouse_x <= self.x + self.width and mouse_y >= self.y and mouse_y <= self.y + 22;
}

pub fn is_mouse_on_resize_area(self: *Window) bool {
    const mouse_x = raylib.getMouseX();
    const mouse_y = raylib.getMouseY();
    return mouse_x - self.x > self.width - 15 and mouse_y - self.y > self.height - 15;
}

pub fn interact(self: *Window, refs: App.AppRefs) void {
    const cur_action = refs.gui.get_action();
    if (cur_action == UserAction.interact or cur_action == UserAction.canvas_scale) {
        if (self.is_mouse_inside()) {
            if (self.is_mouse_on_resize_area() and !self.window_state.is_moving) {
                self.window_state.is_scaling = true;
            }
            if (self.is_mouse_on_move_area() and !(self.window_state.is_scaling or self.window_state.is_moving)) {
                self.window_state.is_moving = true;
                self.window_state.mouse_offset_x = raylib.getMouseX() - self.x;
                self.window_state.mouse_offset_y = raylib.getMouseY() - self.y;
            }
        }
        if (self.is_mouse_inside() or self.window_state.is_scaling or self.window_state.is_moving) {
            refs.gui.current_user_action = UserAction.window_interact;
        }
    }

    if (cur_action == UserAction.none) {
        raylib.setMouseCursor(0);
        self.window_state.is_scaling = false;
        self.window_state.is_moving = false;
    }
}

pub fn update(self: *Window, refs: App.AppRefs) void {
    self.interact(refs);
    if (self.window_state.is_scaling) {
        self.width = raylib.getMouseX() - self.x;
        self.height = raylib.getMouseY() - self.y;
        self.width = math.clamp(self.width, 100, raylib.getScreenWidth() - self.x);
        self.height = math.clamp(self.height, 100, raylib.getScreenHeight() - self.y);
    }
    if (self.window_state.is_moving) {
        self.x = raylib.getMouseX() - self.window_state.mouse_offset_x;
        self.y = raylib.getMouseY() - self.window_state.mouse_offset_y;
        self.x = math.clamp(self.x, 0, raylib.getScreenWidth() - self.width);
        self.y = math.clamp(self.y, 0, raylib.getScreenHeight() - self.height);
    }
}

pub fn window_to_rectangle(self: *Window) raylib.Rectangle {
    return raylib.Rectangle{ .x = @floatFromInt(self.x), .y = @floatFromInt(self.y), .width = @floatFromInt(self.width), .height = @floatFromInt(self.height) };
}

pub fn kill_button_rectangle(self: *Window) raylib.Rectangle {
    return raylib.Rectangle{ .x = @floatFromInt(self.x + self.width - raygui.guiGetStyle(15, 12) - 20), .y = @floatFromInt(self.y + 12 - 9), .width = 18, .height = 18 };
}

pub fn render(self: *Window, refs: App.AppRefs) i32 {
    //    const result = raygui.guiWindowBox(raylib.Rectangle{ .x = @floatFromInt(self.x), .y = @floatFromInt(self.y), .width = @floatFromInt(self.width), .height = @floatFromInt(self.height) }, self.title[0 .. self.title.len - 1 :0]);

    _ = raygui.guiScrollPanel(self.window_to_rectangle(), self.title[0 .. self.title.len - 1 :0], self.layout.layout_estimated_rectangle(refs), @constCast(&self.scroll), @constCast(&self.window_to_rectangle()));

    const result = raygui.guiButton(self.kill_button_rectangle(), "x");

    if ((self.is_mouse_inside() and self.is_mouse_on_resize_area()) or self.window_state.is_scaling) {
        raylib.drawTriangle(raylib.Vector2{ .x = @floatFromInt(self.width + self.x - 10), .y = @floatFromInt(self.y + self.height) }, raylib.Vector2{ .x = @floatFromInt(self.width + self.x), .y = @floatFromInt(self.y + self.height) }, raylib.Vector2{ .x = @floatFromInt(self.width + self.x), .y = @floatFromInt(self.y + self.height - 10) }, raylib.Color.white);
    }

    raylib.beginScissorMode(self.x + 1, self.y + 24, self.width - 2, self.height - 28);
    self.layout.render(self.x + @as(i32, @intFromFloat(self.scroll.x)), self.y + @as(i32, @intFromFloat(self.scroll.y)), self.width, self.height, refs);
    raylib.endScissorMode();
    return result;
}
