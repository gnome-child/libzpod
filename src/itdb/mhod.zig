const std = @import("std");

const itdb = @import("index.zig");

pub const id: u32 = 0x6D686F64;

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

pub const DataObject = union(enum) {
    string: StringObject,
    podcast_url: PodcastUrlObject,
    unimplemented: UnimplementedObject,
};

pub const StringObject = struct {
    id: u32 = id,
    header_len: u32,
    len: u32,
    type: u32,
    unk0: u32,
    unk1: u32,
    position: u32,
    string_len: u32,
    unk2: u32,
    unk3: u32,
    string_data: []const u8,
};

pub const PodcastUrlObject = struct {
    id: u32 = id,
    header_len: u32,
    len: u32,
    type: u32,
    unk0: u32,
    unk1: u32,
    url_data: []const u8,
};

pub const UnimplementedObject = struct {
    id: u32 = id,
    header_len: u32,
    len: u32,
    type: u32,
    data: []const u8,
};
