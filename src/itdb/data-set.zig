const std = @import("std");

const itdb = @import("index.zig");

const TrackList = @import("track-list.zig").TrackList;
const PlaylistList = @import("playlist-list.zig").PlaylistList;
const AlbumList = @import("album-list.zig").AlbumList;

pub const DataSet = struct { header: itdb.Header, list: union(enum) {
    track_list: TrackList,
    playlist_list: PlaylistList,
    album_list: AlbumList,
} };

pub const MHSD = struct {
    prefix: itdb.Prefix,
    body: MhsdBody,
    padding: []const u8,
};

pub const MhsdBody = packed struct {
    type: u32,
};
