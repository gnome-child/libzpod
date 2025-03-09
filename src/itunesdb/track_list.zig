const std = @import("std");

pub const MAGIC_VALUE: [4]u8 = [4]u8{ 'm', 'h', 'l', 't' };

pub const TrackListHeader = extern struct {
    magic: [4]u8 align(1) = MAGIC_VALUE,
    header_len: u32 align(1) = @sizeOf(TrackListHeader),
    track_item_count: u32 align(1) = 0,
    padding: [80]u8 align(1) = std.mem.zeroes([80]u8),
};
