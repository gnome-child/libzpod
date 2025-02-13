const std = @import("std");

const itdb = @import("index.zig");

pub const id: u32 = 0x6D686970;

pub const PlaylistItem = struct {
    header: MHIP,
    padding: []const u8,
    data: std.ArrayList(itdb.DataObject),
};

pub const MHIP = packed struct {
    id: u32 = id,
    header_len: u32,
    len: u32,
    number_of_data_objects: u32,
    podcast_grouping: u16,
    unk0: u8,
    unk1: u8,
    group_id: u32,
    track_id: u32,
    timestamp: u32,
    podcast_grouping_ref: u32,
};
