const itdb = @import("index.zig");

pub const MHIP = struct {
    prefix: itdb.Prefix,
    body: MhipBody,
    padding: []const u8,
};

pub const MhipBody = packed struct {
    number_of_data_objects: u32,
    podcast_grouping: u16,
    unk0: u8,
    unk1: u8,
    group_id: u32,
    track_id: u32,
    timestamp: u32,
    podcast_grouping_ref: u32,
};
