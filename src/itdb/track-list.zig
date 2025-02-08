const std = @import("std");

const itdb = @import("index.zig");

const TrackItem = @import("track-item.zig").TrackItem;

pub const TrackList = struct {
    header: itdb.Header,
    track_items: std.ArrayList(TrackItem),
};

pub const MHLT = struct {
    prefix: itdb.Prefix,
    padding: []const u8,
};
