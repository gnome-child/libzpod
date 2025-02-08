const std = @import("std");

const itdb = @import("index.zig");

pub const MHLT = struct {
    prefix: itdb.Prefix,
    padding: []const u8,
};
