const prefix = @import("index.zig")._Prefix;

pub const MHYP = packed struct {
    prefix: prefix,
    number_of_data_objects: u32,
    number_of_playlists: u32,
    is_master: u8,
    unk_1: u8,
    unk_2: u8,
    unk_3: u8,
    timestamp: u32,
    persistent_id: u64,
    unk_4: u32,
    number_of_strings: u16,
    is_podcast_playlist: u16,
    sort_order: u32,
};
