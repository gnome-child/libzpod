const std = @import("std");

const itdb = @import("index.zig");

pub const id: u32 = 0x6D687364;

pub const DataType = enum(u32) {
    track_list = 1,
    playlist_list = 2,
    podcast_list = 3,
    album_list = 4,
    smart_playlist_list = 5,
};

pub const DataSetData = union(DataType) {
    track_list: itdb.TrackList,
    playlist_list: itdb.PlaylistList,
    podcast_list: itdb.PlaylistList,
    album_list: itdb.AlbumList,
    smart_playlist_list: itdb.PlaylistList,
};

pub const DataSet = struct {
    header: MHSD,
    padding: []const u8,
    data: DataSetData,
};

pub const MHSD = packed struct {
    id: u32 = id,
    header_len: u32,
    len: u32,
    data_type: u32,
};
