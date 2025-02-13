const std = @import("std");

const itdb = @import("index.zig");

pub const id: u32 = 0x6D686C74;

pub const TrackList = struct {
    header: MHLT,
    padding: []const u8,
    track_items: std.ArrayList(itdb.TrackItem),
};

pub const MHLT = packed struct {
    id: u32 = id,
    header_len: u32,
    entries: u32,
};
