const std = @import("std");

const itdb = @import("index.zig");

const Playlist = @import("playlist.zig").Playlist;

pub const PlaylistList = struct {
    header: itdb.Header,
    playlists: std.ArrayList(Playlist),

    pub fn read(reader: *itdb.serialization.itdb_reader) !PlaylistList {
        const prefix = try reader.read_prefix();
        const header = try reader.read_header(prefix);
        const playlist_count = header.playlist_list.prefix.element_size;

        var playlists = std.ArrayList(Playlist).init(reader.allocator);
        defer playlists.deinit();

        std.debug.print("    playlists: {}\n", .{playlist_count});

        for (playlist_count) |_| {
            try playlists.append(try Playlist.read(reader));
        }

        return PlaylistList{
            .header = header,
            .playlists = playlists,
        };
    }
};

pub const MHLP = struct {
    prefix: itdb.Prefix,
    padding: []const u8,
};
