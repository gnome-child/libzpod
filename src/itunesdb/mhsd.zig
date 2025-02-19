const std = @import("std");

const itdb = @import("index.zig");

pub const type_id_u32: u32 = 0x6D687364;

pub const Fields = packed struct {
    type_id_u32: u32 = type_id_u32,
    header_len: u32,
    len: u32,
    data_type: u32,
};
