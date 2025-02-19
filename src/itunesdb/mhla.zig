const std = @import("std");

const itdb = @import("index.zig");

pub const type_id_u32: u32 = 0x6D686C61;

pub const Fields = packed struct {
    type_id_u32: u32 = type_id_u32,
    header_len: u32,
    album_item_count: u32,
};
