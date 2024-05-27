const std = @import("std");
const Allocator = std.mem.Allocator;

const raylib = @cImport({
    @cInclude("raylib.h");
});

const WindowManager = @import("WindowManager.zig");
const App = @import("App.zig");

pub const UserAction = enum {
    none,
    canvas_draw,
    canvas_erase,
    canvas_move,
    canvas_scale,
    canvas_rotate,
    canvas_reset_transform,
    window_interact,
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
    std.log.debug("UPDATE", .{});
    self.window_manager.update(refs);
}

pub fn get_action(self: *Gui) UserAction {
    if (raylib.IsKeyDown(raylib.KEY_LEFT_CONTROL)) {
        if (raylib.IsKeyPressed(raylib.KEY_R)) {
            self.current_user_action = UserAction.canvas_reset_transform;
        }
        if (raylib.IsKeyPressed(raylib.KEY_Z)) {
            self.current_user_action = UserAction.window_kill;
        }
    }
    if (raylib.IsKeyDown(raylib.KEY_SPACE)) {
        if (raylib.IsMouseButtonDown(raylib.MOUSE_BUTTON_LEFT)) {
            self.current_user_action = UserAction.canvas_move;
        }
    } else {
        self.current_user_action = UserAction.none;
    }
    return self.current_user_action;
}

pub fn render(self: *Gui) void {
    self.window_manager.render();
}
