const std = @import("std");

const itdb = @import("index.zig");

pub const id: u32 = 0x6D686961;

pub const AlbumItem = struct {
    header: MHIA,
    padding: []const u8,
    data: std.ArrayList(itdb.DataObject),
};

pub const MHIA = packed struct {
    id: u32 = id,
    header_len: u32,
    len: u32,
    number_of_strings: u32,
    unk0: u16,
    album_id: u16,

    // Some kind of timestamp?
    unk1: u64,

    // Always 2?
    unk2: u32,
};
