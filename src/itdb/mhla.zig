const std = @import("std");

const itdb = @import("index.zig");

pub const id: u32 = 0x6D686C61;

pub const AlbumList = struct {
    header: Fields,
    padding: []const u8,
    album_items: std.ArrayList(itdb.AlbumItem),
};

pub const Fields = packed struct {
    id: u32 = id,
    header_len: u32,
    entries: u32,
};
