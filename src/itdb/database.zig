const std = @import("std");

const prefix = @import("index.zig")._Prefix;
const data_set = @import("data-set.zig").DataSet;

pub const Root = struct {
    header: MHBD,
    data_sets: []*data_set,
};

/// The entry point of an iTunesDB.
pub const MHBD = packed struct {
    prefix: prefix,
    blob_0: u32,

    /// The version of the iTunesDB. Determines which fields/features are available.
    db_version: u32,

    /// The number of data_set children.
    data_set_count: u32,

    /// Database ID. Not used by the iPod?
    db_id: u64,

    /// Windows or Unix?
    platform: u16,

    blob_1: u112,

    /// Some kind of hashing scheme?
    hash_scheme: u16,

    blob_2: u160,

    /// Language id
    language_id: u16,

    /// Some kind of persistent id
    db_persistent_id: u64,

    blob_3: u64,
    hash58: u160,

    /// Offset for accurately reflecting timezone
    timezone_offset: u32,

    blob_4: u16,
    hash72: u368,

    /// Language of audio
    audio_language: u16,

    /// Language of subtitles
    subtitle_language: u16,

    blob_5: u48,
    alignment_byte: u8,
    hashAB: u456,
};
