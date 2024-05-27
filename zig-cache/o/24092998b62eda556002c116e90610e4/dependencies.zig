pub const packages = struct {
    pub const @"1220c28847ca8e8756734ae84355802b764c9d9cf4de057dbc6fc2b15c56e726f27b" = struct {
        pub const build_root = "D:\\Users\\e.vallot\\AppData\\Local\\zig\\p\\1220c28847ca8e8756734ae84355802b764c9d9cf4de057dbc6fc2b15c56e726f27b";
        pub const build_zig = @import("1220c28847ca8e8756734ae84355802b764c9d9cf4de057dbc6fc2b15c56e726f27b");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
};

pub const root_deps: []const struct { []const u8, []const u8 } = &.{
    .{ "raylib", "1220c28847ca8e8756734ae84355802b764c9d9cf4de057dbc6fc2b15c56e726f27b" },
};
