const std = @import("std");

const itdb = @import("index.zig");

const DataObject = @import("data-object.zig").DataObject;

pub const PlaylistItem = struct {
    header: itdb.Header,
    data_objects: std.ArrayList(DataObject),

    pub fn read(reader: *itdb.serialization.itdb_reader) !PlaylistItem {
        const prefix = try reader.read_prefix();
        const header = try reader.read_header(prefix);
        const data_object_count = header.playlist_item.body.number_of_data_objects;

        var data_objects = std.ArrayList(DataObject).init(reader.allocator);
        defer data_objects.deinit();

        for (data_object_count) |_| {
            try data_objects.append(try DataObject.read(reader));
        }

        return PlaylistItem{
            .header = header,
            .data_objects = data_objects,
        };
    }
};

pub const MHIP = struct {
    prefix: itdb.Prefix,
    body: MhipBody,
    padding: []const u8,
};

pub const MhipBody = packed struct {
    number_of_data_objects: u32,
    podcast_grouping: u16,
    unk0: u8,
    unk1: u8,
    group_id: u32,
    track_id: u32,
    timestamp: u32,
    podcast_grouping_ref: u32,
};
