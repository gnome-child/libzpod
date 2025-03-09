const std = @import("std");

pub const MAGIC_VALUE: [4]u8 = [4]u8{ 'm', 'h', 'i', 'a' };

pub const AlbumItemHeader = extern struct {
    magic: [4]u8 align(1) = MAGIC_VALUE,
    header_len: u32 align(1) = @sizeOf(AlbumItemHeader),
    len: u32 align(1) = @sizeOf(AlbumItemHeader),
    data_obj_count: u32 align(1) = 0,
    unk_0x10: u32 align(1) = 0, // track ID related
    unk_0x14: u64 align(1) = 0, // possible ID
    unk_0x1C: u32 align(1) = 2, // always 2
    unk_0x20: u64 align(1) = 0, // another ID
    padding_0x28: [48]u8 align(1) = std.mem.zeroes([48]u8),
};
