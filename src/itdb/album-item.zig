const std = @import("std");

const itdb = @import("index.zig");

const DataObject = @import("data-object.zig").DataObject;

pub const AlbumItem = struct {
    header: itdb.Header,
    data_objects: std.ArrayList(DataObject),

    pub fn read(reader: *itdb.serialization.itdb_reader) !AlbumItem {
        const prefix = try reader.read_prefix();
        const header = try reader.read_header(prefix);
        const data_object_count = header.album_item.body.number_of_strings;

        var data_objects = std.ArrayList(DataObject).init(reader.allocator);
        defer data_objects.deinit();

        for (data_object_count) |_| {
            try data_objects.append(try DataObject.read(reader));
        }

        return AlbumItem{
            .header = header,
            .data_objects = data_objects,
        };
    }
};

pub const MHIA = struct {
    prefix: itdb.Prefix,
    body: MhiaBody,
    padding: []const u8,
};

pub const MhiaBody = packed struct {
    number_of_strings: u32,
    unk0: u16,
    album_id: u16,

    // Some kind of timestamp?
    unk1: u64,

    // Always 2?
    unk2: u32,
};
