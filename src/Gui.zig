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
    canvas_save,
    window_interact,
    window_kill,
    window_spawn,
    window_spawn_history,
    window_spawn_timeline,
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
        if (raylib.IsKeyPressed(raylib.KEY_H)) {
            self.current_user_action = UserAction.window_spawn_history;
            return;
        }
        if (raylib.IsKeyPressed(raylib.KEY_T)) {
            self.current_user_action = UserAction.window_spawn_timeline;
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
        if (raylib.IsKeyPressed(raylib.KEY_S)) {
            self.current_user_action = UserAction.canvas_save;
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

pub fn get_cur_action_string(refs: App.AppRefs) ?[128]u8 {
    var ret_str = [_]u8{0} ** 128;
    const str_len = if (@tagName(refs.gui.current_user_action).len < ret_str.len - 1) @tagName(refs.gui.current_user_action).len else ret_str.len - 1;
    @memcpy(ret_str[0..str_len], @tagName(refs.gui.current_user_action));
    return ret_str;
}

pub fn get_action_history_string(refs: App.AppRefs) ?[128]u8 {
    var ret_str = [_]u8{0} ** 128;
    var last_actions_len: usize = 0;
    var actions_len: usize = 0;
    for (refs.gui.history.items) |action| {
        if (action != UserAction.none) {
            actions_len += if (@tagName(action).len + actions_len + 2 < 128) @tagName(action).len else return ret_str;
            @memcpy(ret_str[last_actions_len..actions_len], @tagName(action));
            const backslash = "\n\n";
            @memcpy(ret_str[actions_len .. actions_len + backslash.len], backslash);
            actions_len += backslash.len;
            last_actions_len = actions_len;
        }
    }
    return ret_str;
}
pub fn render(self: *Gui, refs: App.AppRefs) void {
    self.window_manager.render(refs);
}
