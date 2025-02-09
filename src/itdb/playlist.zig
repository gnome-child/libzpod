const std = @import("std");

const itdb = @import("index.zig");

const PlaylistItem = @import("playlist-item.zig").PlaylistItem;
const DataObject = @import("data-object.zig").DataObject;

pub const Playlist = struct {
    header: itdb.Header,
    data_objects: std.ArrayList(DataObject),
    playlist_items: std.ArrayList(PlaylistItem),

    pub fn read(reader: *itdb.serialization.itdb_reader) !Playlist {
        const prefix = try reader.read_prefix();
        const header = try reader.read_header(prefix);
        const playlist_item_count = header.playlist.body.number_of_playlists;
        const data_object_count = header.playlist.body.number_of_data_objects;

        var data_objects = std.ArrayList(DataObject).init(reader.allocator);
        var playlist_items = std.ArrayList(PlaylistItem).init(reader.allocator);
        defer data_objects.deinit();
        defer playlist_items.deinit();

        std.debug.print("      entries: {}\n", .{playlist_item_count});

        for (data_object_count) |_| {
            try data_objects.append(try DataObject.read(reader));
        }

        for (playlist_item_count) |_| {
            try playlist_items.append(try PlaylistItem.read(reader));
        }

        return Playlist{
            .header = header,
            .data_objects = data_objects,
            .playlist_items = playlist_items,
        };
    }
};

pub const MHYP = struct {
    prefix: itdb.Prefix,
    body: MhypBody,
    padding: []const u8,
};

pub const MhypBody = packed struct {
    number_of_data_objects: u32,
    number_of_playlists: u32,
    is_master: u8,
    unk0: u8,
    unk1: u8,
    unk2: u8,
    timestamp: u32,
    persistent_id: u64,
    unk3: u32,
    number_of_strings: u16,
    is_podcast_playlist: u16,
    sort_order: u32,
};
