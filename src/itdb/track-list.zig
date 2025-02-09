const std = @import("std");

const itdb = @import("index.zig");

const TrackItem = @import("track-item.zig").TrackItem;

pub const TrackList = struct {
    header: itdb.Header,
    track_items: std.ArrayList(TrackItem),

    pub fn read(reader: *itdb.serialization.itdb_reader) !TrackList {
        const prefix = try reader.read_prefix();
        const header = try reader.read_header(prefix);
        const track_count = header.track_list.prefix.element_size;

        var track_items = std.ArrayList(TrackItem).init(reader.allocator);
        defer track_items.deinit();

        std.debug.print("    tracks: {}\n", .{track_count});

        for (track_count) |_| {
            try track_items.append(try TrackItem.read(reader));
        }

        return TrackList{
            .header = header,
            .track_items = track_items,
        };
    }
};

pub const MHLT = struct {
    prefix: itdb.Prefix,
    padding: []const u8,
};
