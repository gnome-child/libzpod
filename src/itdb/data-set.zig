const std = @import("std");

const itdb = @import("index.zig");

pub const MHSD = struct {
    prefix: itdb.Prefix,
    body: MhsdBody,
    padding: []const u8,
};

pub const MhsdBody = packed struct {
    type: u32,
};
