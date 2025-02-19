pub const std = @import("std");

pub const header = @import("header.zig");
pub const reader = @import("reader.zig");
pub const serializer = @import("serializer.zig");

pub const DataSetType = enum(u32) {
    track_list = 1,
    playlist_list = 2,
    podcast_list = 3,
    album_list = 4,
    smart_playlist_list = 5,
};

pub const DataObjectType = enum(u32) {
    title = 1,
    location = 2,
    album = 3,
    artist = 4,
    genre = 5,
    filetype = 6,
    eq_setting = 7,
    comment = 8,
    category = 9,
    composer = 12,
    grouping = 13,
    description = 14,
    podcast_enclosure_url = 15,
    podcast_rss_url = 16,
    chapter_data = 17,
    subtitle = 18,
    show = 19,
    episode_number = 20,
    tv_network = 21,
    album_artist = 22,
    artist_sort = 23,
    keywords = 24,
    tv_locale = 25,
    title_sort = 27,
    album_sort = 28,
    album_artist_sort = 29,
    composer_sort = 30,
    tv_show_sort = 31,
    video_binary = 32,
    smart_playlist_data = 50,
    smart_playlist_rules = 51,
    library_playlist_index = 52,
    jump_table = 53,
    column_info = 100,
    album_list_album = 200,
    album_list_artist = 201,
    album_list_artist_sort = 202,
    album_list_podcast_url = 203,
    album_list_tv_show = 204,
    _,
};

pub const Element = union(enum) {
    root: Root,
    data_set: DataSet,
    track_list: TrackList,
    playlist_list: PlaylistList,
    album_list: AlbumList,
    track_item: TrackItem,
    playlist: Playlist,
    playlist_item: PlaylistItem,
    album_item: AlbumItem,
    data_obj: DataObject,
};

pub const Root = struct {
    header: *align(1) const header.mhbd.Fields,
    track_list: ?DataSet,
    playlist_list: ?DataSet,
    podcast_list: ?DataSet,
    album_list: ?DataSet,
    smart_playlist_list: ?DataSet,
};

pub const DataSet = struct {
    header: *align(1) const header.mhsd.Fields,
    set: union(DataSetType) {
        track_list: TrackList,
        playlist_list: PlaylistList,
        podcast_list: PlaylistList,
        album_list: AlbumList,
        smart_playlist_list: PlaylistList,
    },
};

pub const TrackList = struct {
    header: *align(1) const header.mhlt.Fields,
    track_items: std.ArrayList(TrackItem),
};

pub const PlaylistList = struct {
    header: *align(1) const header.mhlp.Fields,
    playlists: std.ArrayList(Playlist),
};

pub const AlbumList = struct {
    header: *align(1) const header.mhla.Fields,
    album_items: std.ArrayList(AlbumItem),
};

pub const TrackItem = struct {
    header: *align(1) const header.mhit.Fields,
    data_objects: std.ArrayList(DataObject),
};

pub const Playlist = struct {
    header: *align(1) const header.mhyp.Fields,
    data_objects: std.ArrayList(DataObject),
    playlist_items: std.ArrayList(PlaylistItem),
};

pub const PlaylistItem = struct {
    header: *align(1) const header.mhip.Fields,
    data_objects: std.ArrayList(DataObject),
};

pub const AlbumItem = struct {
    header: *align(1) const header.mhia.Fields,
    data_objects: std.ArrayList(DataObject),
};

pub const DataObject = struct {
    header: header.mhod.Fields,
    data: []const u8,
};

pub fn load_test_file(index: u32) ![]u8 {
    const allocator = std.testing.allocator;
    const path = switch (index) {
        1 => "test_data/itunesdb1",
        2 => "test_data/itunesdb2",
        else => "test_data/itunesdb1",
    };
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    const file_size = try file.getEndPos();

    const buffer = try allocator.alloc(u8, file_size);

    const bytes_read = try file.readAll(buffer);
    if (bytes_read != file_size) {
        allocator.free(buffer);
        return error.ShortRead;
    }

    return buffer;
}

test "parse a header" {
    const alloc = std.testing.allocator;
    const bytes = try load_test_file(2);
    defer alloc.free(bytes);

    var arena = std.heap.ArenaAllocator.init(alloc);

    var itdb_reader = try serializer.Reader.init(arena.allocator(), bytes);
    const rootdb = try itdb_reader.parse_element(Root);
    std.debug.print("{}\n", .{rootdb});

    arena.deinit();
}
