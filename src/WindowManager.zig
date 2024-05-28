const std = @import("std");
const Allocator = std.mem.Allocator;

const raylib = @cImport({
    @cInclude("raylib.h");
});

const App = @import("App.zig");
const Window = @import("Window.zig");
const UserAction = @import("Gui.zig").UserAction;

const WindowManager = @This();
windows: std.ArrayList(Window),
selected_window_id: usize,

pub fn init(alloc: Allocator) !WindowManager {
    return .{
        .windows = std.ArrayList(Window).init(alloc),
        .selected_window_id = 0,
    };
}

pub fn deinit(self: *WindowManager) void {
    self.windows.deinit();
}

pub fn bring_to_top(self: *WindowManager, id: usize) void {
    if (self.windows.insert(0, self.windows.orderedRemove(id))) |stmt| {
        return stmt;
    } else |e| {
        std.log.debug("ERROR {any}", .{e});
        return;
    }
}

pub fn update(self: *WindowManager, refs: App.AppRefs) void {
    const cur_action = refs.gui.get_action();
    //std.log.debug("{any}", .{cur_action});

    if (cur_action == UserAction.window_kill) {
        //std.log.debug("KILL WINDOW", .{});
        if (self.windows.items.len <= 0) {
            return;
        }
        _ = self.windows.orderedRemove(self.selected_window_id);
        return;
    }
    if (cur_action == UserAction.window_spawn) {
        //std.log.debug("NEW WINDOW", .{});
        const new_window = try Window.init("Window", 1500, 100, 200, 150);
        if (@TypeOf(new_window) != Window) {
            return;
        }
        if (self.windows.append(new_window)) |stmt| {
            return stmt;
        } else |e| {
            std.log.debug("ERROR {any}", .{e});
        }
        return;
    }

    var i = self.windows.items.len;
    while (i != 0) {
        i -= 1;
        if (self.windows.items[i].is_mouse_inside() or (self.windows.items[i].window_state.is_moving or self.windows.items[i].window_state.is_scaling)) {
            if (self.selected_window_id != i and (self.windows.items[i].window_state.is_moving or self.windows.items[i].window_state.is_scaling)) {
                self.selected_window_id = i;
                self.bring_to_top(self.selected_window_id);
            }
            self.windows.items[i].update(refs);
            return;
        }
    }
}

pub fn render(self: *WindowManager) void {
    var i = self.windows.items.len;
    while (i != 0) {
        i -= 1;
        self.windows.items[i].render();
    }
}
