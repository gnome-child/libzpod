const std = @import("std");

const itdb = @import("index.zig");

pub const type_id_u32: u32 = 0x6D686F64;

pub const Fields = union(enum) {
    string: *align(1) const String,
    podcast_url: *align(1) const PodcastUrl,
    unimplemented: *align(1) const Unimplemented,
};

pub const String = extern struct {
    type_id_u32: u32 = type_id_u32,
    header_len: u32 = 24,
    len: u32,
    type: u32,
    unk0: u32,
    unk1: u32,
    position: u32,
    string_len: u32,
    unk2: u32,
    unk3: u32,
};

pub const PodcastUrl = extern struct {
    type_id_u32: u32 = type_id_u32,
    header_len: u32,
    len: u32,
    type: u32,
    unk0: u32,
    unk1: u32,
};

pub const Unimplemented = extern struct {
    type_id_u32: u32 = type_id_u32,
    header_len: u32,
    len: u32,
    type: u32,
};
