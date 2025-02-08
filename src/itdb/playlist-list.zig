const std = @import("std");

const itdb = @import("index.zig");

const Playlist = @import("playlist.zig").Playlist;

pub const PlaylistList = struct {
    header: itdb.Header,
    playlists: std.ArrayList(Playlist),
};

pub const MHLP = struct {
    prefix: itdb.Prefix,
    padding: []const u8,
};
