const std = @import("std");
const Allocator = std.mem.Allocator;

const raylib = @cImport({
    @cInclude("raylib.h");
});

const WindowManager = @import("WindowManager.zig");

const UserAction = enum {
    none,
    canvas_draw,
    canvas_erase,
    canvas_move,
    canvas_scale,
    canvas_rotate,
    window_move,
    window_scale,
    window_pin,
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

pub fn get_action(self: *Gui) UserAction {
    return self.current_user_action;
}
