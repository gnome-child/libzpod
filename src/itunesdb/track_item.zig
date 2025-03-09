const std = @import("std");

const data_tag = @import("data_tag/data_tag.zig");

pub const MAGIC_VALUE: [4]u8 = [4]u8{ 'm', 'h', 'i', 't' };

pub const TrackItem = struct {
    allocator: std.mem.Allocator,
    header: TrackItemHeader,
    body: data_tag.DataTagSet,

    pub fn init(allocator: std.mem.Allocator) TrackItem {
        return .{
            .allocator = allocator,
            .header = TrackItemHeader.init(),
            .body = data_tag.DataTagSet.init(allocator),
        };
    }

    pub fn deinit(self: *TrackItem) void {
        self.body.deinit();
    }

    // TODO: from and to bytes

    pub fn getTag(self: *TrackItem, tag_type: data_tag.DataTagType) !data_tag.DataTag {
        return try self.body.get(tag_type);
    }

    pub fn setTag(self: *TrackItem, tag: data_tag.DataTag) !void {
        try self.body.set(tag);
    }
};

pub const TrackItemHeader = extern struct {
    magic: [4]u8 align(1) = MAGIC_VALUE,
    header_len: u32 align(1) = @sizeOf(TrackItemHeader),
    len: u32 align(1) = @sizeOf(TrackItemHeader),
    data_obj_count: u32 align(1) = 0,
    unique_id: u32 align(1) = 0, // TODO: generate this
    visible: u32 align(1) = 1,
    file_type: [4]u8 align(1) = [4]u8{ ' ', ' ', ' ', ' ' },
    vbr_flag: u8 align(1) = 0,
    mp3_flag: u8 align(1) = 0,
    compilation_flag: u8 align(1) = 0,
    rating: u8 align(1) = 0,
    hfs_time_last_modified: u32 align(1) = 0, // TODO: implement HFS time conversion
    file_size_bytes_u32: u32 align(1) = 0,
    duration_ms: u32 align(1) = 0,
    album_index: u32 align(1) = 1,
    album_track_count: u32 align(1) = 1,
    release_year: u32 align(1) = 1517,
    bitrate: u32 align(1) = 0,
    sample_rate: u32 align(1) = 0,
    playback_volume_adj: u32 align(1) = 0,
    start_offset_ms: u32 align(1) = 0,
    stop_offset_ms: u32 align(1) = 0,
    soundcheck: u32 align(1) = 0,
    play_count_1: u32 align(1) = 0,
    play_count_2: u32 align(1) = 0,
    hfs_time_last_played: u32 align(1) = 0, // TODO: implement HFS time conversion
    album_disc_index: u32 align(1) = 1,
    album_disc_count: u32 align(1) = 1,
    drm_user_id: u32 align(1) = 0,
    hfs_time_date_added: u32 align(1) = 0, // TODO: implement HFS time conversion
    bookmark_ms: u32 align(1) = 0,
    persistent_id: u64 align(1) = 0, // TODO: generate this
    unchecked_flag: u8 align(1) = 0,
    last_rating: u8 align(1) = 0,
    bpm: u16 align(1) = 0,
    artwork_count: u16 align(1) = 0,
    audio_format_tag: u16 align(1) = 0,
    artwork_size_bytes: u32 align(1) = 0,
    unk_0x84: u32 align(1) = 0,
    IEEE_f32_sample_rate: u32 align(1) = 0,
    hfs_time_release_date: u32 align(1) = 0, // TODO: implement HFS time conversion
    unk_0x90: u16 align(1) = 0,
    unk_0x92: u16 align(1) = 0,
    unk_0x94: u32 align(1) = 0,
    unk_0x98: u32 align(1) = 0,
    skip_count: u32 align(1) = 0,
    hfs_time_last_skipped: u32 align(1) = 0, // TODO: implement HFS time conversion
    has_artwork: u8 align(1) = 0,
    skip_on_shuffle_flag: u8 align(1) = 0,
    remember_playback_position_flag: u8 align(1) = 0,
    podcast_flag: u8 align(1) = 0,
    unk_0xA8: u64 align(1) = 0,
    has_lyrics_flag: u8 align(1) = 0,
    is_movie_flag: u8 align(1) = 0,
    podcast_unplayed: u8 align(1) = 1,
    unk_0xB3: u8 align(1) = 0,
    unk_0xB4: u32 align(1) = 0,
    samples_before_start_gapless: u32 align(1) = 0,
    samples_count_gapless: u64 align(1) = 0,
    unk_0xC4: u32 align(1) = 0,
    samples_before_end_gapless: u32 align(1) = 0,
    mp3_encoded: u32 align(1) = 0,
    media_type: u32 align(1) = 1,
    season_number: u32 align(1) = 0,
    episode_number: u32 align(1) = 0,
    unk_0xDC: u32 align(1) = 0,
    padding_0xE0: [24]u8 align(1) = std.mem.zeroes([24]u8),
    gapless_data: u32 align(1) = 0,
    unk_0xFC: u32 align(1) = 0,
    is_gapless_track_flag: u16 align(1) = 0,
    is_gapless_album_flag: u16 align(1) = 0,
    padding_0x0104: [28]u8 align(1) = std.mem.zeroes([28]u8),
    unk_0x0120: u32 align(1) = 0x8DDA0000,
    unk_0x0124: u64 align(1) = 0,
    file_size_bytes_u64: u64 align(1) = 0,
    unk_0x0134: [6]u8 align(1) = [6]u8{ 0x80, 0x80, 0x80, 0x80, 0x80, 0x80 },
    album_id: u16 align(1) = 0,
    padding_0x013A: [36]u8 align(1) = std.mem.zeroes([36]u8),
    mhii_link: u64 align(1) = 0,
    unk_0x0168: u64 align(1) = 0,
    padding_0x0170: [112]u8 align(1) = std.mem.zeroes([112]u8),
    unk_0x01E0: u32 align(1) = 0,
    padding_0x01E4: [16]u8 align(1) = std.mem.zeroes([16]u8),
    unk_0x01F4: u32 align(1) = 0,
    padding_0x01F8: [20]u8 align(1) = std.mem.zeroes([20]u8),
    unk_0x020C: u32 align(1) = 0,
    padding_0x0210: [96]u8 align(1) = std.mem.zeroes([96]u8),

    pub fn init() TrackItemHeader {
        return TrackItemHeader{
            .unique_id = 0, // generate!
        };
    }
};
