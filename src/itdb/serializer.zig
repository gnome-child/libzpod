const std = @import("std");

const itdb = @import("index.zig");
const mhbd = @import("mhbd.zig");
const mhsd = @import("mhsd.zig");
const mhlt = @import("mhlt.zig");
const mhlp = @import("mhlp.zig");
const mhla = @import("mhla.zig");
const mhit = @import("mhit.zig");
const mhyp = @import("mhyp.zig");
const mhip = @import("mhip.zig");
const mhia = @import("mhia.zig");
const mhod = @import("mhod.zig");

pub const ItdbReader = struct {
    allocator: std.mem.Allocator,
    bytes: []const u8,
    index: usize = 0,

    pub fn init(allocator: std.mem.Allocator, bytes: []const u8) ItdbReader {
        return ItdbReader{
            .allocator = allocator,
            .bytes = bytes,
        };
    }

    pub fn bytes_available(self: *ItdbReader, required_size: usize) !void {
        if (self.index + required_size > self.bytes.len) {
            return error.NotEnoughBytes;
        }
    }

    pub fn peek_field_relative_le(self: *ItdbReader, comptime T: type, offset: usize) !T {
        const required_size = @sizeOf(T);
        try self.bytes_available(offset + required_size);

        const end_index = self.index + offset + required_size;
        return std.mem.readInt(T, self.bytes[self.index + offset .. end_index][0..required_size], .little);
    }

    pub fn peek_field_relative_be(self: *ItdbReader, comptime T: type, offset: usize) !T {
        const required_size = @sizeOf(T);
        try self.bytes_available(offset + required_size);

        const end_index = self.index + offset + required_size;
        return std.mem.readInt(T, self.bytes[self.index + offset .. end_index][0..required_size], .big);
    }

    pub fn peek_field_le(self: *ItdbReader, comptime T: type) !T {
        const required_size = @sizeOf(T);
        try self.bytes_available(required_size);

        const end_index = self.index + required_size;
        return std.mem.readInt(T, self.bytes[self.index..end_index][0..required_size], .little);
    }

    pub fn peek_field_be(self: *ItdbReader, comptime T: type) !T {
        const required_size = @sizeOf(T);
        try self.bytes_available(required_size);

        const end_index = self.index + required_size;
        return std.mem.readInt(T, self.bytes[self.index..end_index][0..required_size], .big);
    }

    pub fn read_field_le(self: *ItdbReader, comptime T: type) !T {
        const required_size = @sizeOf(T);
        try self.bytes_available(required_size);

        const next_index = self.index + required_size;
        const value = std.mem.readInt(T, self.bytes[self.index..next_index][0..required_size], .little);

        self.index = next_index;
        return value;
    }

    pub fn read_field_be(self: *ItdbReader, comptime T: type) !T {
        const required_size = @sizeOf(T);
        try self.bytes_available(required_size);

        const next_index = self.index + required_size;
        const value = std.mem.readInt(T, self.bytes[self.index..next_index][0..required_size], .big);

        self.index = next_index;
        return value;
    }

    pub fn read_header_as(self: *ItdbReader, comptime T: type) !T {
        const required_size = @sizeOf(T);
        try self.bytes_available(required_size);

        const next_index = self.index + required_size;
        const header = std.mem.bytesToValue(T, self.bytes[self.index..next_index][0..required_size]);

        self.index = next_index;
        return header;
    }

    pub fn read_header_as_padded(self: *ItdbReader, comptime T: type) !struct { T, []const u8 } {
        const header_len = try self.peek_field_relative_le(u32, 4);
        const header = try self.read_header_as(T);
        const padding_size = header_len - @sizeOf(T);
        const next_index = self.index + padding_size;
        const padding = try self.allocator.alloc(u8, padding_size);
        @memset(padding, 0);

        self.index = next_index;

        return .{
            header,
            padding,
        };
    }

    pub fn read_data_object(self: *ItdbReader) !itdb.DataObject {
        const header_id = try self.read_field_le(u32);
        const header_len = try self.read_field_le(u32);
        const len = try self.read_field_le(u32);
        const type_id = try self.read_field_le(u32);

        const type_enum = @as(mhod.DataObjectType, @enumFromInt(type_id));
        const next_index = (self.index - 16) + len;

        const data_obj = switch (type_enum) {
            .title, .location, .album, .artist, .genre, .filetype, .eq_setting, .comment, .category, .composer, .grouping, .description, .album_list_album => mhod.DataObject{
                .string = .{
                    .id = header_id,
                    .header_len = header_len,
                    .len = len,
                    .type = type_id,
                    .unk0 = try self.read_field_le(u32),
                    .unk1 = try self.read_field_le(u32),
                    .position = try self.read_field_le(u32),
                    .string_len = try self.read_field_le(u32),
                    .unk2 = try self.read_field_le(u32),
                    .unk3 = try self.read_field_le(u32),
                    .string_data = self.bytes[self.index..next_index],
                },
            },

            .podcast_enclosure_url, .podcast_rss_url => mhod.DataObject{
                .podcast_url = .{
                    .id = header_id,
                    .len = len,
                    .header_len = header_len,
                    .type = type_id,
                    .unk0 = try self.read_field_le(u32),
                    .unk1 = try self.read_field_le(u32),
                    .url_data = self.bytes[self.index..next_index],
                },
            },

            else => mhod.DataObject{
                .unimplemented = .{
                    .id = header_id,
                    .header_len = header_len,
                    .len = len,
                    .type = type_id,
                    .data = self.bytes[self.index..next_index],
                },
            },
        };

        self.index = next_index;
        return data_obj;
    }

    pub fn read_header(self: *ItdbReader) !itdb.Header {
        const header_id = @as(itdb.HeaderId, @enumFromInt(self.peek_field_be(u32)));

        return switch (header_id) {
            .mhbd => itdb.Header{ .mhbd = try self.read_header_as(mhbd.Fields) },
            .mhsd => itdb.Header{ .mhsd = try self.read_header_as(mhsd.Fields) },
            .mhlt => itdb.Header{ .mhlt = try self.read_header_as(mhlt.Fields) },
            .mhlp => itdb.Header{ .mhlp = try self.read_header_as(mhlp.Fields) },
            .mhla => itdb.Header{ .mhla = try self.read_header_as(mhla.Fields) },
            .mhit => itdb.Header{ .mhit = try self.read_header_as(mhit.Fields) },
            .mhyp => itdb.Header{ .mhyp = try self.read_header_as(mhyp.Fields) },
            .mhip => itdb.Header{ .mhip = try self.read_header_as(mhip.Fields) },
            .mhia => itdb.Header{ .mhia = try self.read_header_as(mhia.Fields) },
            .mhod => itdb.Header{ .mhod = try self.read_data_object() },
        };
    }

    pub fn parse(self: *ItdbReader, comptime T: type) !T {
        const header_id = @as(itdb.HeaderId, @enumFromInt(try self.peek_field_be(u32)));

        switch (header_id) {
            .mhbd => {
                if (T != mhbd.Root) return error.MismatchedHeader;

                const header = try self.read_header_as_padded(mhbd.Fields);
                const data_set_count = header[0].data_set_count;

                var data_sets = std.ArrayList(mhsd.DataSet).init(self.allocator);

                for (0..data_set_count) |_| {
                    try data_sets.append(try self.parse(mhsd.DataSet));
                }

                return mhbd.Root{
                    .header = header[0],
                    .padding = header[1],
                    .data_sets = data_sets,
                };
            },

            .mhsd => {
                if (T != mhsd.DataSet) return error.MismatchedHeader;

                const header = try self.read_header_as_padded(mhsd.Fields);
                const data_type = @as(mhsd.DataType, @enumFromInt(header[0].data_type));

                const data = switch (data_type) {
                    .track_list => mhsd.DataSetData{
                        .track_list = try self.parse(mhlt.TrackList),
                    },
                    .playlist_list => mhsd.DataSetData{
                        .playlist_list = try self.parse(mhlp.PlaylistList),
                    },
                    .podcast_list => mhsd.DataSetData{
                        .podcast_list = try self.parse(mhlp.PlaylistList),
                    },
                    .album_list => mhsd.DataSetData{
                        .album_list = try self.parse(mhla.AlbumList),
                    },
                    .smart_playlist_list => mhsd.DataSetData{
                        .smart_playlist_list = try self.parse(mhlp.PlaylistList),
                    },
                };

                return mhsd.DataSet{
                    .header = header[0],
                    .padding = header[1],
                    .data = data,
                };
            },

            .mhlt => {
                if (T != mhlt.TrackList) return error.MismatchedHeader;

                const header = try self.read_header_as_padded(mhlt.Fields);
                const entries = header[0].entries;
                var track_items = std.ArrayList(mhit.TrackItem).init(self.allocator);

                for (0..entries) |_| {
                    try track_items.append(try self.parse(mhit.TrackItem));
                }

                return mhlt.TrackList{
                    .header = header[0],
                    .padding = header[1],
                    .track_items = track_items,
                };
            },

            .mhlp => {
                if (T != mhlp.PlaylistList) return error.MismatchedHeader;

                const header = try self.read_header_as_padded(mhlp.Fields);
                const entries = header[0].entries;
                var playlists = std.ArrayList(mhyp.Playlist).init(self.allocator);

                for (0..entries) |_| {
                    try playlists.append(try self.parse(mhyp.Playlist));
                }

                return mhlp.PlaylistList{
                    .header = header[0],
                    .padding = header[1],
                    .playlists = playlists,
                };
            },

            .mhla => {
                if (T != mhla.AlbumList) return error.MismatchedHeader;

                const header = try self.read_header_as_padded(mhla.Fields);
                const entries = header[0].entries;
                var album_items = std.ArrayList(mhia.AlbumItem).init(self.allocator);

                for (0..entries) |_| {
                    try album_items.append(try self.parse(mhia.AlbumItem));
                }

                return mhla.AlbumList{
                    .header = header[0],
                    .padding = header[1],
                    .album_items = album_items,
                };
            },

            .mhit => {
                if (T != mhit.TrackItem) return error.MismatchedHeader;

                const header = try self.read_header_as_padded(mhit.Fields);
                const data_object_count = header[0].data_object_count;
                var data = std.ArrayList(mhod.DataObject).init(self.allocator);

                for (0..data_object_count) |_| {
                    try data.append(try self.parse(mhod.DataObject));
                }

                return mhit.TrackItem{
                    .header = header[0],
                    .padding = header[1],
                    .data = data,
                };
            },

            .mhyp => {
                if (T != mhyp.Playlist) return error.MismatchedHeader;

                const header = try self.read_header_as_padded(mhyp.Fields);
                const data_object_count = header[0].data_object_count;
                const playlist_item_count = header[0].playlist_item_count;
                var data = std.ArrayList(mhod.DataObject).init(self.allocator);
                var playlist_items = std.ArrayList(mhip.PlaylistItem).init(self.allocator);

                for (0..data_object_count) |_| {
                    try data.append(try self.parse(mhod.DataObject));
                }

                for (0..playlist_item_count) |_| {
                    try playlist_items.append(try self.parse(mhip.PlaylistItem));
                }

                return mhyp.Playlist{
                    .header = header[0],
                    .padding = header[1],
                    .data = data,
                    .playlist_items = playlist_items,
                };
            },

            .mhip => {
                if (T != mhip.PlaylistItem) return error.MismatchedHeader;

                const header = try self.read_header_as_padded(mhip.Fields);
                const data_object_count = header[0].data_object_count;
                var data = std.ArrayList(mhod.DataObject).init(self.allocator);

                for (0..data_object_count) |_| {
                    try data.append(try self.parse(mhod.DataObject));
                }

                return mhip.PlaylistItem{
                    .header = header[0],
                    .padding = header[1],
                    .data = data,
                };
            },

            .mhia => {
                if (T != mhia.AlbumItem) return error.MismatchedHeader;

                const header = try self.read_header_as_padded(mhia.Fields);
                const number_of_strings = header[0].number_of_strings;
                var data = std.ArrayList(mhod.DataObject).init(self.allocator);

                for (0..number_of_strings) |_| {
                    try data.append(try self.parse(mhod.DataObject));
                }

                return mhia.AlbumItem{
                    .header = header[0],
                    .padding = header[1],
                    .data = data,
                };
            },

            .mhod => {
                if (T != mhod.DataObject) return error.MismatchedHeader;

                const data_obj = try self.read_data_object();

                if (data_obj == .podcast_url) {
                    std.debug.print("{s}\n", .{data_obj.podcast_url.url_data});
                }

                return data_obj;
            },
        }
    }
};

pub const ItdbWriter = struct {
    allocator: std.mem.Allocator,
    root: itdb.Root,
    buffer: std.ArrayList(u8),
    index: usize = 0,

    pub fn init(allocator: std.mem.Allocator, root: itdb.Root, size: ?usize) !ItdbWriter {
        var buffer = std.ArrayList(u8).init(allocator);
        if (size != null) try buffer.ensureTotalCapacity(size.?);

        return ItdbWriter{
            .allocator = allocator,
            .root = root,
            .buffer = buffer,
        };
    }

    pub fn write_root_header(self: *ItdbWriter) !void {
        const header = self.root.header;
        const padding = self.root.padding;

        try self.buffer.appendSlice(std.mem.asBytes(&header));
        try self.buffer.appendSlice(padding[0..]);
    }

    pub fn write_data_set_header(self: *ItdbWriter, data_set: itdb.DataSet) !void {
        const header = data_set.header;
        const padding = data_set.padding;

        try self.buffer.appendSlice(std.mem.asBytes(&header));
        try self.buffer.appendSlice(padding[0..]);
    }

    pub fn write_track_list_header(self: *ItdbWriter, track_list: itdb.TrackList) !void {
        const header = track_list.header;
        const padding = track_list.padding;

        try self.buffer.appendSlice(std.mem.asBytes(&header));
        try self.buffer.appendSlice(padding[0..]);
    }

    pub fn write_playlist_list_header(self: *ItdbWriter, playlist_list: itdb.PlaylistList) !void {
        const header = playlist_list.header;
        const padding = playlist_list.padding;

        try self.buffer.appendSlice(std.mem.asBytes(&header));
        try self.buffer.appendSlice(padding[0..]);
    }

    pub fn write_album_list_header(self: *ItdbWriter, album_list: itdb.AlbumList) !void {
        const header = album_list.header;
        const padding = album_list.padding;

        try self.buffer.appendSlice(std.mem.asBytes(&header));
        try self.buffer.appendSlice(padding[0..]);
    }

    pub fn write_track_item_header(self: *ItdbWriter, track_item: itdb.TrackItem) !void {
        const header = track_item.header;
        const padding = track_item.padding;

        try self.buffer.appendSlice(std.mem.asBytes(&header));
        try self.buffer.appendSlice(padding[0..]);
    }

    pub fn write_playlist_header(self: *ItdbWriter, playlist: itdb.Playlist) !void {
        const header = playlist.header;
        const padding = playlist.padding;

        try self.buffer.appendSlice(std.mem.asBytes(&header));
        try self.buffer.appendSlice(padding[0..]);
    }

    pub fn write_playlist_item_header(self: *ItdbWriter, playlist_item: itdb.PlaylistItem) !void {
        const header = playlist_item.header;
        const padding = playlist_item.padding;

        try self.buffer.appendSlice(std.mem.asBytes(&header));
        try self.buffer.appendSlice(padding[0..]);
    }

    pub fn write_album_item_header(self: *ItdbWriter, album_item: itdb.AlbumItem) !void {
        const header = album_item.header;
        const padding = album_item.padding;

        try self.buffer.appendSlice(std.mem.asBytes(&header));
        try self.buffer.appendSlice(padding[0..]);
    }

    pub fn write_field_le(self: *ItdbWriter, comptime T: type) !void {
        try self.buffer.appendSlice(&T);
    }
};
