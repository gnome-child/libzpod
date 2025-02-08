const std = @import("std");

const itdb = @import("index.zig");

const AlbumItem = @import("album-item.zig").AlbumItem;

pub const AlbumList = struct {
    header: itdb.Header,
    album_items: std.ArrayList(AlbumItem),
};

pub const MHLA = struct {
    prefix: itdb.Prefix,
    padding: []const u8,
};
