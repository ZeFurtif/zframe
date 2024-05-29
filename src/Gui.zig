const std = @import("std");
const Allocator = std.mem.Allocator;

const raylib = @cImport({
    @cInclude("raylib.h");
});

const WindowManager = @import("WindowManager.zig");
const App = @import("App.zig");

pub const UserAction = enum {
    none,
    interact,
    canvas_move,
    canvas_scale,
    canvas_rotate,
    canvas_reset_transform,
    canvas_undo,
    window_interact,
    window_spawn,
    window_kill,
};

const Gui = @This();
current_user_action: UserAction,
history: std.ArrayList(UserAction),
window_manager: WindowManager,

pub fn init(alloc: Allocator) !Gui {
    return .{
        .current_user_action = UserAction.none,
        .history = std.ArrayList(UserAction).init(alloc),
        .window_manager = try WindowManager.init(alloc),
    };
}

pub fn deinit(self: *Gui) void {
    self.history.deinit();
    self.window_manager.deinit();
}

pub fn update(self: *Gui, refs: App.AppRefs) void {
    self.update_action();
    self.window_manager.update(refs);
    self.update_history();
}

pub fn update_action(self: *Gui) void {
    if (raylib.IsKeyDown(raylib.KEY_LEFT_CONTROL)) {
        if (raylib.IsKeyPressed(raylib.KEY_N)) {
            self.current_user_action = UserAction.window_spawn;
            return;
        }
        if (raylib.IsKeyPressed(raylib.KEY_R)) {
            self.current_user_action = UserAction.canvas_reset_transform;
            return;
        }
        if (raylib.IsKeyPressed(raylib.KEY_Z)) {
            self.current_user_action = UserAction.window_kill;
            return;
        }
        if (raylib.IsKeyPressed(raylib.KEY_W)) {
            self.current_user_action = UserAction.canvas_undo;
            return;
        }
    }
    if (raylib.IsKeyDown(raylib.KEY_SPACE)) {
        if (raylib.IsMouseButtonDown(raylib.MOUSE_BUTTON_LEFT)) {
            self.current_user_action = UserAction.canvas_move;
            return;
        }
    }
    if (raylib.GetMouseWheelMove() != 0) {
        self.current_user_action = UserAction.canvas_scale;
        return;
    }

    if (raylib.IsMouseButtonDown(raylib.MOUSE_BUTTON_LEFT)) {
        self.current_user_action = UserAction.interact;
        return;
    }
    self.current_user_action = UserAction.none;
    return;
}

pub fn update_history(self: *Gui) void {
    if (self.history.items.len == 0) {
        if (self.history.append(self.current_user_action)) |stmt| {
            _ = stmt;
        } else |e| {
            std.log.debug("{any}", .{e});
        }
    }
    if (self.history.items[0] != self.current_user_action) {
        if (self.history.insert(0, self.current_user_action)) |stmt| {
            _ = stmt;
        } else |e| {
            std.log.debug("{any}", .{e});
        }
    }

    if (self.history.items.len > 10) {
        _ = self.history.pop();
    }
}

pub fn get_action(self: *Gui) UserAction {
    return self.current_user_action;
}

pub fn render(self: *Gui) void {
    self.window_manager.render();
}
