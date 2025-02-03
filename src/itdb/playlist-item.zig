const prefix = @import("index.zig")._Prefix;

pub const MHIP = packed struct {
    prefix: prefix,
    number_of_data_objects: u32,
    podcast_grouping: u16,
    unk_1: u8,
    unk_2: u8,
    group_id: u32,
    track_id: u32,
    timestamp: u32,
    podcast_grouping_ref: u32,
};
