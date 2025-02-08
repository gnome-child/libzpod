const itdb = @import("index.zig");

pub const MHYP = struct {
    prefix: itdb.Prefix,
    body: MhypBody,
    padding: []const u8,
};

pub const MhypBody = packed struct {
    number_of_data_objects: u32,
    number_of_playlists: u32,
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
