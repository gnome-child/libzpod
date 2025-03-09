const std = @import("std");

pub const MAGIC_VALUE: [4]u8 = [4]u8{ 'm', 'h', 'i', 'p' };

pub const PlaylistItemHeader = extern struct {
    magic: [4]u8 align(1) = MAGIC_VALUE,
    header_len: u32 align(1) = @sizeOf(PlaylistItemHeader),
    len: u32 align(1) = @sizeOf(PlaylistItemHeader),
    data_obj_count: u32 align(1) = 0,
    podcast_group_flag: u16 align(1) = 0,
    unk_0x18: u16 align(1) = 0,
    group_id: u32 align(1) = 0,
    track_id: u32 align(1) = 0,
    hfs_timestamp_0x28: u32 align(1) = 0, // TODO: HFS time conversion
    padding_0x32: [12]u8 align(1) = std.mem.zeroes([12]u8),
    podcast_group_id: u32 align(1) = 0,
    unk_0x48: u32 align(1) = 0,
    padding_0x52: [8]u8 align(1) = std.mem.zeroes([8]u8),
    unk_0x60: u64 align(1) = 0,
    padding_0x68: [8]u8 align(1) = std.mem.zeroes([8]u8),
};
