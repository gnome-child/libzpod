const std = @import("std");

const itdb = @import("index.zig");

pub const id: u32 = 0x6D686974;

pub const TrackItem = struct {
    header: MHIT,
    padding: []const u8,
    data: std.ArrayList(itdb.DataObject),
};

pub const MHIT = packed struct {
    id: u32 = id,
    header_len: u32,
    len: u32,
    data_object_count: u32,
    track_id: u32,
    visible: u32,
    filetype: u32,
    type: u16,
    compilation: u8,
    rating: u8,
    last_modified: u32,
    track_size_b: u32,
    track_duration_ms: u32,
    track_index: u32,
    total_tracks: u32,
    track_year: u32,
    track_bitrate: u32,
    track_sample_rate: u32,
    track_volume: u32,
    track_start_time_ms: u32,
    track_stop_time_ms: u32,
    soundcheck: u32,
    play_count: u32,
    play_count_2: u32,
    last_played: u32,
    disc_number: u32,
    total_discs: u32,
    userid: u32,
    date_added: u32,
    bookmark_time: u32,
    database_id: u64,
    checked_in_itunes: u8,
    itunes_last_rating: u8,
    bpm: u16,
    artwork_count: u16,
    unk0: u16,
    artwork_size: u32,
    unk1: u32,
    sample_rate_IEEE_32: u32,
    release_date: u32,
    unk2: u16,
    unk3: u16,
    unk4: u32,
    unk5: u32,
    skip_count: u32,
    last_skipped: u32,
    has_artwork: u8,
    skip_when_shuffling: u8,
    remember_playback_position: u8,
    podcast_info_flag: u8,
    database_id_2: u64,
    lyrics_flag: u8,
    movie_flag: u8,
    played_marker: u8,
    unk6: u8,
    unk7: u32,
    pre_silence: u32,
    sample_count: u64,
    unk8: u32,
    post_silence: u32,
    unk9: u32,
    media_kind: u32,
    season_number: u32,
    episode_number: u32,
    unk10: u32,
    unk11: u32,
    unk12: u32,
    unk13: u32,
    unk14: u32,
    unk15: u32,
    unk16: u32,
    gapless_data: u32,
    unk17: u32,
    gapless_track: u16,
    gapless_album: u16,
    unk18: u160,
    unk19: u32,
    unk20: u32,
    unk21: u32,
    unk22: u32,
    unk23: u16,
    album_id: u16,
    mhii_link: u32,
};
