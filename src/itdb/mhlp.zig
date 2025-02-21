const std = @import("std");

const itdb = @import("index.zig");

pub const id: u32 = 0x6D686C70;

pub const PlaylistList = struct {
    header: Fields,
    padding: []const u8,
    playlists: std.ArrayList(itdb.Playlist),
};

pub const Fields = packed struct {
    id: u32 = id,
    header_len: u32,
    entries: u32,
};
