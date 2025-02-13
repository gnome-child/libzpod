const std = @import("std");

const itdb = @import("index.zig");

pub const id: u32 = 0x6D686264;

pub const Root = struct {
    header: MHBD,
    padding: []const u8,
    data_sets: std.ArrayList(itdb.DataSet),
};

pub const MHBD = packed struct {
    id: u32 = id,
    header_len: u32,
    len: u32,
    unk0: u32,

    /// The version of the iTunesDB. Determines which fields/features are available.
    db_version: u32,

    /// The number of data_set children.
    data_set_count: u32,

    /// Database ID. Not used by the iPod?
    db_id: u64,

    /// Windows or Unix?
    platform: u16,

    unk1: u16,

    /// Some kind of id
    id_0x24: u64,

    unk2: u32,

    /// Some kind of hashing scheme?
    hash_scheme: u16,

    unk3: u160,

    /// Language id
    language_id: u16,

    /// Some kind of persistent id
    db_persistent_id: u64,

    unk4: u32,
    unk5: u32,
    hash58: u160,

    /// Offset for accurately reflecting timezone
    timezone_offset: u32,

    unk6: u16,
    hash72: u368,

    /// Language of audio
    audio_language: u16,

    /// Language of subtitles
    subtitle_language: u16,

    unk7: u16,
    unk8: u16,
    unk9: u16,
    alignment_byte: u8,
    hashAB: u456,
};
