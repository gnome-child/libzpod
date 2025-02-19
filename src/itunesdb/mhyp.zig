const std = @import("std");

const itdb = @import("index.zig");

pub const type_id_u32: u32 = 0x6D687970;

pub const Fields = packed struct {
    type_id_u32: u32 = type_id_u32,
    header_len: u32,
    len: u32,
    data_object_count: u32,
    playlist_item_count: u32,
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
