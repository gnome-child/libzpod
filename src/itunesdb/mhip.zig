const std = @import("std");

const itdb = @import("index.zig");

pub const type_id_u32: u32 = 0x6D686970;

pub const Fields = packed struct {
    type_id_u32: u32 = type_id_u32,
    header_len: u32,
    len: u32,
    data_object_count: u32,
    podcast_grouping: u16,
    unk0: u8,
    unk1: u8,
    group_id: u32,
    track_id: u32,
    timestamp: u32,
    podcast_grouping_ref: u32,
};
