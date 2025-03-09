const std = @import("std");

pub const MAGIC_VALUE: [4]u8 = [4]u8{ 'm', 'h', 'y', 'p' };

pub const PlaylistHeader = extern struct {
    magic: [4]u8 align(1) = MAGIC_VALUE,
    header_len: u32 align(1) = @sizeOf(PlaylistHeader),
    len: u32 align(1) = @sizeOf(PlaylistHeader),
    data_obj_count: u32 align(1) = 0,
    playlist_item_count: u32 align(1) = 0,
    is_master_flag: u8 align(1) = 0,
    flag_0x15: u8 align(1) = 0,
    flag_0x16: u8 align(1) = 0,
    flag_0x17: u8 align(1) = 0,
    hfs_timestamp_0x18: u32 align(1) = 0, // TODO: HFS time conversion
    persistent_id: u64 align(1) = 0, // TODO: generate
    unk_0x24: u32 align(1) = 0, // always 0
    string_obj_count: u16 align(1) = 0,
    is_podcast_playlist_flag: u16 align(1) = 0,
    sort_order: u32 align(1) = 0,
    padding_0x30: [40]u8 align(1) = std.mem.zeroes([40]u8),
    hfs_timestamp_0x58: u32 align(1) = 0, // TODO: HFS time conversion
    padding_0x5C: [92]u8 align(1) = std.mem.zeroes([92]u8),
};
