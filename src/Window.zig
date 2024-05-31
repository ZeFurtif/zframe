const std = @import("std");
const math = std.math;
const Allocator = std.mem.Allocator;

const raylib = @cImport({
    @cInclude("raylib.h");
});

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
title: [20]u8,
x: i32,
y: i32,
width: i32,
height: i32,
window_state: WindowState,
layout: Layout,

pub fn init(refs: App.AppRefs) !Window {
    return .{
        .title = [_]u8{" "},
        .x = 0,
        .y = 0,
        .width = 100,
        .height = 100,
        .window_state = WindowState{},
        .layout = Layout.init(refs),
    };
}

pub fn deinit(self: *Window) void {
    self.layout.deinit();
}

pub fn args_init(refs: App.AppRefs, title: []const u8, x: i32, y: i32, width: i32, height: i32) !Window {
    var ret_title = [_]u8{0} ** 20;
    const title_len = if (title.len < ret_title.len - 1) title.len else ret_title.len - 1;
    @memcpy(ret_title[0..title_len], title);
    ret_title[title_len] = 0;
    return .{
        .title = ret_title,
        .x = x,
        .y = y,
        .width = width,
        .height = height,
        .window_state = WindowState{},
        .layout = Layout.init(refs),
    };
}

pub fn is_mouse_inside(self: *Window) bool {
    const mouse_x = raylib.GetMouseX();
    const mouse_y = raylib.GetMouseY();
    return mouse_x >= self.x and mouse_x <= self.x + self.width and mouse_y >= self.y and mouse_y <= self.y + self.height;
}

pub fn is_mouse_on_resize_area(self: *Window) bool {
    const mouse_x = raylib.GetMouseX();
    const mouse_y = raylib.GetMouseY();
    return mouse_x - self.x > self.width - 15 and mouse_y - self.y > self.height - 15;
}

pub fn interact(self: *Window, refs: App.AppRefs) void {
    const cur_action = refs.gui.get_action();
    if (cur_action == UserAction.interact) {
        if (self.window_state.is_scaling or self.window_state.is_moving) {
            refs.gui.current_user_action = UserAction.window_interact;
        }
        if (self.is_mouse_inside()) {
            if (self.is_mouse_on_resize_area() and !self.window_state.is_moving) {
                self.window_state.is_scaling = true;
                return;
            }
            if (!(self.window_state.is_scaling or self.window_state.is_moving)) {
                self.window_state.is_moving = true;
                self.window_state.mouse_offset_x = raylib.GetMouseX() - self.x;
                self.window_state.mouse_offset_y = raylib.GetMouseY() - self.y;
            }
        }
    }

    if (cur_action == UserAction.none) {
        raylib.SetMouseCursor(raylib.MOUSE_CURSOR_DEFAULT);
        self.window_state.is_scaling = false;
        self.window_state.is_moving = false;
    }
}

pub fn update(self: *Window, refs: App.AppRefs) void {
    self.interact(refs);
    if (self.window_state.is_scaling) {
        self.width = raylib.GetMouseX() - self.x;
        self.height = raylib.GetMouseY() - self.y;
        self.width = math.clamp(self.width, 100, raylib.GetScreenWidth() - self.x);
        self.height = math.clamp(self.height, 100, raylib.GetScreenHeight() - self.y);
    }
    if (self.window_state.is_moving) {
        self.x = raylib.GetMouseX() - self.window_state.mouse_offset_x;
        self.y = raylib.GetMouseY() - self.window_state.mouse_offset_y;
        self.x = math.clamp(self.x, 0, raylib.GetScreenWidth() - self.width);
        self.y = math.clamp(self.y, 0, raylib.GetScreenHeight() - self.height);
    }
}

pub fn render(self: *Window) void {
    raylib.DrawRectangleLines(self.x - 1, self.y - 1, self.width + 2, self.height + 2, raylib.WHITE);
    raylib.DrawRectangle(self.x, self.y, self.width + 3, self.height + 3, raylib.BLACK);
    raylib.DrawRectangle(self.x, self.y, self.width, self.height, raylib.GRAY);
    raylib.DrawText(&self.title, self.x + 10, self.y + 10, 10, raylib.WHITE);

    self.layout.render(self.x, self.y);
}
