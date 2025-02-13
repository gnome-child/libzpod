const std = @import("std");

const itdb = @import("index.zig");

pub const id: u32 = 0x6D687970;

pub const Playlist = struct {
    header: MHYP,
    padding: []const u8,
    data: std.ArrayList(itdb.DataObject),
    playlist_items: std.ArrayList(itdb.PlaylistItem),
};

pub const MHYP = packed struct {
    id: u32 = id,
    header_len: u32,
    len: u32,
    number_of_data_objects: u32,
    number_of_playlist_items: u32,
    is_master: u8,
    unk0: u8,
    unk1: u8,
    unk2: u8,
    timestamp: u32,
    persistent_id: u64,
    unk3: u32,
    number_of_strings: u16,
    is_podcast_playlist: u16,
    sort_order: u32,
};
