const std = @import("std");

const Utility = @This();

pub fn intToString(int: usize, buf: []u8) ![]const u8 {
    return try std.fmt.bufPrint(buf, "{}", .{int});
}
