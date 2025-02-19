const std = @import("std");

const itdb = @import("index.zig");

pub const type_id_u32: u32 = 0x6D686264;

pub const Fields = packed struct {
    type_id_u32: u32 = type_id_u32,
    header_len: u32,
    len: u32,
    unk0: u32,
    db_version: u32,
    data_set_count: u32,
    db_id: u32,
    platform: u32,
    unk1: u16,
    id_0x24: u64,
    unk2: u32,
    hash_scheme: u16,
    unk3: u160,
    language_id: u16,
    db_persistent_id: u64,
    unk4: u32,
    unk5: u32,
    hash58: u160,
    timezone_offset: u32,
    unk6: u16,
    hash72: u368,
    audio_lang: u16,
    subtitle_lang: u16,
    unk7: u16,
    unk8: u16,
    unk9: u16,
    alignment_byte: u8,
    hashAB: u456,
};
