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

pub fn init(alloc: Allocator) !WindowManager {
    return .{
        .windows = std.ArrayList(Window).init(alloc),
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
        self.windows.items[0].layout.deinit();
        _ = self.windows.orderedRemove(0);
        return;
    }
    if (cur_action == UserAction.window_spawn) {
        //std.log.debug("NEW WINDOW", .{});
        var new_window = try Window.args_init(refs, "Window", 1500, 100, 200, 150);
        new_window.layout.addElement(refs);
        if (@TypeOf(new_window) != Window) {
            return;
        }
        if (self.windows.append(new_window)) |stmt| {
            self.bring_to_top(self.windows.items.len - 1);
            return stmt;
        } else |e| {
            std.log.debug("ERROR {any}", .{e});
        }
        return;
    }

    var i: usize = 0;
    while (i != self.windows.items.len) {
        if (self.windows.items[i].is_mouse_inside() or (self.windows.items[i].window_state.is_moving or self.windows.items[i].window_state.is_scaling)) {
            if (i != 0 and (self.windows.items[i].window_state.is_moving or self.windows.items[i].window_state.is_scaling)) {
                self.bring_to_top(i);
            }
            self.windows.items[i].update(refs);
            return;
        }
        i += 1;
    }
}

pub fn render(self: *WindowManager) void {
    var i = self.windows.items.len;
    while (i != 0) {
        i -= 1;
        self.windows.items[i].render();
    }
}
