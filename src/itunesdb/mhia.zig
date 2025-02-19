const std = @import("std");

const itdb = @import("index.zig");

pub const type_id_u32: u32 = 0x6D686961;

pub const Fields = packed struct {
    type_id_u32: u32 = type_id_u32,
    header_len: u32,
    len: u32,
    data_object_count: u32,
    unk0: u16,
    album_id: u16,
    unk1: u64,
    unk2: u32,
};
