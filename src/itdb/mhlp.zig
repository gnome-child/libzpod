const std = @import("std");

const itdb = @import("index.zig");

pub const id: u32 = 0x6D686C70;

pub const PlaylistList = struct {
    header: MHLP,
    padding: []const u8,
    playlist_items: std.ArrayList(itdb.Playlist),
};

pub const MHLP = packed struct {
    id: u32 = id,
    header_len: u32,
    entries: u32,
};
