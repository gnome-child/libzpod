const std = @import("std");

const itdb = @import("index.zig");

const TrackList = @import("track-list.zig").TrackList;
const PlaylistList = @import("playlist-list.zig").PlaylistList;
const AlbumList = @import("album-list.zig").AlbumList;

pub const DataSetType = enum(u32) {
    tracks = 1,
    playlists = 2,
    podcasts = 3,
    albums = 4,
    smart_playlists = 5,
};

pub const ListType = union(DataSetType) {
    tracks: TrackList,
    playlists: PlaylistList,
    podcasts: PlaylistList,
    albums: AlbumList,
    smart_playlists: PlaylistList,
};

pub const DataSet = struct {
    header: itdb.Header,
    list: ListType,

    pub fn read(reader: *itdb.serialization.itdb_reader) !DataSet {
        const prefix = try reader.read_prefix();
        const header = try reader.read_header(prefix);
        const data_set_type = @as(DataSetType, @enumFromInt(header.data_set.body.type));

        std.debug.print("  data set ({})\n", .{data_set_type});

        const list = switch (data_set_type) {
            .tracks => ListType{ .tracks = try TrackList.read(reader) },
            .playlists => ListType{ .playlists = try PlaylistList.read(reader) },
            .podcasts => ListType{ .podcasts = try PlaylistList.read(reader) },
            .albums => ListType{ .albums = try AlbumList.read(reader) },
            .smart_playlists => ListType{ .smart_playlists = try PlaylistList.read(reader) },
        };

        return DataSet{
            .header = header,
            .list = list,
        };
    }
};

pub const MHSD = struct {
    prefix: itdb.Prefix,
    body: MhsdBody,
    padding: []const u8,
};

pub const MhsdBody = packed struct {
    type: u32,
};
