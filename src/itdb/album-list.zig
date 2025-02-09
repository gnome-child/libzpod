const std = @import("std");

const itdb = @import("index.zig");

const AlbumItem = @import("album-item.zig").AlbumItem;

pub const AlbumList = struct {
    header: itdb.Header,
    album_items: std.ArrayList(AlbumItem),

    pub fn read(reader: *itdb.serialization.itdb_reader) !AlbumList {
        const prefix = try reader.read_prefix();
        const header = try reader.read_header(prefix);
        const album_count = header.album_list.prefix.element_size;

        var album_items = std.ArrayList(AlbumItem).init(reader.allocator);
        defer album_items.deinit();

        std.debug.print("    albums: {}\n", .{album_count});

        for (album_count) |_| {
            try album_items.append(try AlbumItem.read(reader));
        }

        return AlbumList{
            .header = header,
            .album_items = album_items,
        };
    }
};

pub const MHLA = struct {
    prefix: itdb.Prefix,
    padding: []const u8,
};
