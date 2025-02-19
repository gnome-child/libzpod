const std = @import("std");

const itunesdb = @import("index.zig");

const ReaderError = error{
    NotEnoughBytes,
    MismatchedHeader,
    UnimplementedHeader,
    OutOfMemory,
};

pub const Reader = struct {
    allocator: std.mem.Allocator,
    buffer: []const u8,
    index: usize,

    pub fn init(allocator: std.mem.Allocator, buffer: []const u8) ReaderError!Reader {
        return Reader{
            .allocator = allocator,
            .buffer = buffer,
            .index = 0,
        };
    }

    pub fn parse_element(self: *Reader, comptime T: type) ReaderError!T {
        const header_type_id = try self.peek_header_type_id();

        std.debug.print("{} at {}\n", .{ header_type_id, self.index });

        switch (header_type_id) {
            .mhbd => {
                if (T != itunesdb.Root) return error.MismatchedHeader;

                const header = try self.read_header_as(itunesdb.header.mhbd.Fields);

                return try self.parse_root(header);
            },
            .mhsd => {
                if (T != itunesdb.DataSet) return error.MismatchedHeader;

                const header = try self.read_header_as(itunesdb.header.mhsd.Fields);

                return self.parse_data_set(header);
            },
            .mhlt => {
                if (T != itunesdb.TrackList) return error.MismatchedHeader;

                const header = try self.read_header_as(itunesdb.header.mhlt.Fields);

                return try self.parse_track_list(header);
            },
            .mhlp => {
                if (T != itunesdb.PlaylistList) return error.MismatchedHeader;

                const header = try self.read_header_as(itunesdb.header.mhlp.Fields);

                return try self.parse_playlist_list(header);
            },
            .mhla => {
                if (T != itunesdb.AlbumList) return error.MismatchedHeader;

                const header = try self.read_header_as(itunesdb.header.mhla.Fields);

                return try self.parse_album_list(header);
            },
            .mhit => {
                if (T != itunesdb.TrackItem) return error.MismatchedHeader;

                const header = try self.read_header_as(itunesdb.header.mhit.Fields);

                return try self.parse_track_item(header);
            },
            .mhyp => {
                if (T != itunesdb.Playlist) return error.MismatchedHeader;

                const header = try self.read_header_as(itunesdb.header.mhyp.Fields);

                return try self.parse_playlist(header);
            },
            .mhip => {
                if (T != itunesdb.PlaylistItem) return error.MismatchedHeader;

                const header = try self.read_header_as(itunesdb.header.mhip.Fields);

                return try self.parse_playlist_item(header);
            },
            .mhia => {
                if (T != itunesdb.AlbumItem) return error.MismatchedHeader;

                const header = try self.read_header_as(itunesdb.header.mhia.Fields);

                return try self.parse_album_item(header);
            },
            .mhod => {
                if (T != itunesdb.DataObject) return error.MismatchedHeader;

                const data_obj_type = try self.peek_data_obj_type();

                std.debug.print("{}\n", .{data_obj_type});

                switch (data_obj_type) {
                    .title, .location, .album, .artist, .genre, .filetype, .eq_setting, .comment, .category, .composer, .grouping, .description, .album_list_album => {
                        const header = try self.read_header_as(itunesdb.header.mhod.String);
                        return try self.parse_data_obj(itunesdb.header.mhod.Fields{ .string = header });
                    },
                    .podcast_enclosure_url, .podcast_rss_url => {
                        const header = try self.read_header_as(itunesdb.header.mhod.PodcastUrl);
                        return try self.parse_data_obj(itunesdb.header.mhod.Fields{ .podcast_url = header });
                    },
                    else => {
                        const header = try self.read_header_as(itunesdb.header.mhod.Unimplemented);
                        return try self.parse_data_obj(itunesdb.header.mhod.Fields{ .unimplemented = header });
                    },
                }
            },
        }
    }

    pub fn parse_root(self: *Reader, header: *align(1) const itunesdb.header.mhbd.Fields) ReaderError!itunesdb.Root {
        const data_set_count = header.data_set_count;

        var database_root = itunesdb.Root{
            .header = header,
            .track_list = null,
            .playlist_list = null,
            .podcast_list = null,
            .album_list = null,
            .smart_playlist_list = null,
        };

        //TODO: Do something smart with padding?
        try self.skip_bytes(header.header_len - @sizeOf(itunesdb.header.mhbd.Fields));

        for (0..data_set_count) |_| {
            const data_set_type = try self.peek_data_set_type();

            switch (data_set_type) {
                .track_list => {
                    database_root.track_list = try self.parse_element(itunesdb.DataSet);
                },
                .playlist_list => {
                    database_root.playlist_list = try self.parse_element(itunesdb.DataSet);
                },
                .podcast_list => {
                    database_root.podcast_list = try self.parse_element(itunesdb.DataSet);
                },
                .album_list => {
                    database_root.album_list = try self.parse_element(itunesdb.DataSet);
                },
                .smart_playlist_list => {
                    database_root.smart_playlist_list = try self.parse_element(itunesdb.DataSet);
                },
            }
        }
        return database_root;
    }

    pub fn parse_data_set(self: *Reader, header: *align(1) const itunesdb.header.mhsd.Fields) ReaderError!itunesdb.DataSet {
        const data_set_type = @as(itunesdb.DataSetType, @enumFromInt(header.data_type));

        //TODO: Do something smart with padding?
        try self.skip_bytes(header.header_len - @sizeOf(itunesdb.header.mhsd.Fields));

        return switch (data_set_type) {
            .track_list => itunesdb.DataSet{
                .header = header,
                .set = .{
                    .track_list = try self.parse_element(itunesdb.TrackList),
                },
            },
            .playlist_list => itunesdb.DataSet{
                .header = header,
                .set = .{
                    .playlist_list = try self.parse_element(itunesdb.PlaylistList),
                },
            },
            .podcast_list => itunesdb.DataSet{
                .header = header,
                .set = .{
                    .podcast_list = try self.parse_element(itunesdb.PlaylistList),
                },
            },
            .album_list => itunesdb.DataSet{
                .header = header,
                .set = .{
                    .album_list = try self.parse_element(itunesdb.AlbumList),
                },
            },
            .smart_playlist_list => itunesdb.DataSet{
                .header = header,
                .set = .{
                    .smart_playlist_list = try self.parse_element(itunesdb.PlaylistList),
                },
            },
        };
    }

    pub fn parse_track_list(self: *Reader, header: *align(1) const itunesdb.header.mhlt.Fields) ReaderError!itunesdb.TrackList {
        const track_item_count = header.track_item_count;

        //TODO: Do something smart with padding?
        try self.skip_bytes(header.header_len - @sizeOf(itunesdb.header.mhlt.Fields));

        var track_items = std.ArrayList(itunesdb.TrackItem).init(self.allocator);

        for (0..track_item_count) |_| {
            try track_items.append(try self.parse_element(itunesdb.TrackItem));
        }

        return itunesdb.TrackList{
            .header = header,
            .track_items = track_items,
        };
    }

    pub fn parse_playlist_list(self: *Reader, header: *align(1) const itunesdb.header.mhlp.Fields) ReaderError!itunesdb.PlaylistList {
        const playlist_count = header.playlist_count;

        //TODO: Do something smart with padding?
        try self.skip_bytes(header.header_len - @sizeOf(itunesdb.header.mhlp.Fields));

        var playlists = std.ArrayList(itunesdb.Playlist).init(self.allocator);

        for (0..playlist_count) |_| {
            try playlists.append(try self.parse_element(itunesdb.Playlist));
        }

        return itunesdb.PlaylistList{
            .header = header,
            .playlists = playlists,
        };
    }

    pub fn parse_album_list(self: *Reader, header: *align(1) const itunesdb.header.mhla.Fields) ReaderError!itunesdb.AlbumList {
        const album_item_count = header.album_item_count;

        //TODO: Do something smart with padding?
        try self.skip_bytes(header.header_len - @sizeOf(itunesdb.header.mhla.Fields));

        var album_items = std.ArrayList(itunesdb.AlbumItem).init(self.allocator);

        for (0..album_item_count) |_| {
            try album_items.append(try self.parse_element(itunesdb.AlbumItem));
        }

        return itunesdb.AlbumList{
            .header = header,
            .album_items = album_items,
        };
    }

    pub fn parse_track_item(self: *Reader, header: *align(1) const itunesdb.header.mhit.Fields) ReaderError!itunesdb.TrackItem {
        const data_object_count = header.data_object_count;

        //TODO: Do something smart with padding?
        try self.skip_bytes(header.header_len - @sizeOf(itunesdb.header.mhit.Fields));

        var data_objects = std.ArrayList(itunesdb.DataObject).init(self.allocator);

        for (0..data_object_count) |_| {
            try data_objects.append(try self.parse_element(itunesdb.DataObject));
        }

        return itunesdb.TrackItem{
            .header = header,
            .data_objects = data_objects,
        };
    }

    pub fn parse_playlist(self: *Reader, header: *align(1) const itunesdb.header.mhyp.Fields) ReaderError!itunesdb.Playlist {
        const data_object_count = header.data_object_count;
        const playlist_item_count = header.playlist_item_count;

        //TODO: Do something smart with padding?
        try self.skip_bytes(header.header_len - @sizeOf(itunesdb.header.mhyp.Fields));

        var data_objects = std.ArrayList(itunesdb.DataObject).init(self.allocator);
        var playlist_items = std.ArrayList(itunesdb.PlaylistItem).init(self.allocator);

        for (0..data_object_count) |_| {
            try data_objects.append(try self.parse_element(itunesdb.DataObject));
        }

        for (0..playlist_item_count) |_| {
            try playlist_items.append(try self.parse_element(itunesdb.PlaylistItem));
        }

        return itunesdb.Playlist{
            .header = header,
            .data_objects = data_objects,
            .playlist_items = playlist_items,
        };
    }

    pub fn parse_playlist_item(self: *Reader, header: *align(1) const itunesdb.header.mhip.Fields) ReaderError!itunesdb.PlaylistItem {
        const data_object_count = header.data_object_count;

        //TODO: Do something smart with padding?
        try self.skip_bytes(header.header_len - @sizeOf(itunesdb.header.mhip.Fields));

        var data_objects = std.ArrayList(itunesdb.DataObject).init(self.allocator);

        for (0..data_object_count) |_| {
            try data_objects.append(try self.parse_element(itunesdb.DataObject));
        }

        return itunesdb.PlaylistItem{
            .header = header,
            .data_objects = data_objects,
        };
    }

    pub fn parse_album_item(self: *Reader, header: *align(1) const itunesdb.header.mhia.Fields) ReaderError!itunesdb.AlbumItem {
        const data_object_count = header.data_object_count;

        //TODO: Do something smart with padding?
        try self.skip_bytes(header.header_len - @sizeOf(itunesdb.header.mhia.Fields));

        var data_objects = std.ArrayList(itunesdb.DataObject).init(self.allocator);

        for (0..data_object_count) |_| {
            try data_objects.append(try self.parse_element(itunesdb.DataObject));
        }

        return itunesdb.AlbumItem{
            .header = header,
            .data_objects = data_objects,
        };
    }

    pub fn parse_data_obj(self: *Reader, header: itunesdb.header.mhod.Fields) !itunesdb.DataObject {
        const data = switch (header) {
            .string => try self.read_bytes(header.string.len - @sizeOf(itunesdb.header.mhod.String)),
            .podcast_url => try self.read_bytes(header.podcast_url.len - @sizeOf(itunesdb.header.mhod.PodcastUrl)),
            .unimplemented => try self.read_bytes(header.unimplemented.len - @sizeOf(itunesdb.header.mhod.Unimplemented)),
        };

        return itunesdb.DataObject{
            .header = header,
            .data = data,
        };
    }

    pub fn read_header_as(self: *Reader, comptime T: type) ReaderError!*align(1) const T {
        const required_size = @sizeOf(T);
        const start_of_header = self.index;
        const end_of_header = start_of_header + required_size;

        std.debug.print("{}\n", .{required_size});

        if (self.bytes_available(required_size)) {
            const header = std.mem.bytesAsValue(T, self.buffer[start_of_header..end_of_header]);
            self.index = end_of_header;
            return header;
        }
        return error.NotEnoughBytes;
    }

    pub fn peek_header_as(self: *Reader, comptime T: type) ReaderError!*align(1) const T {
        const required_size = @sizeOf(T);
        const start_of_header = self.index;
        const end_of_header = start_of_header + required_size;

        if (self.bytes_available(required_size)) {
            const header = std.mem.bytesAsValue(T, self.buffer[start_of_header..end_of_header]);
            return header;
        }
        return error.NotEnoughBytes;
    }

    pub fn peek_field_at(self: *Reader, offset: usize, comptime T: type, endian: std.builtin.Endian) ReaderError!T {
        const required_size = @sizeOf(T);
        const start_of_field = self.index + offset;
        const end_of_field = start_of_field + required_size;

        if (self.bytes_available(end_of_field - self.index)) {
            return std.mem.readInt(T, self.buffer[start_of_field..end_of_field][0..required_size], endian);
        }
        return error.NotEnoughBytes;
    }

    pub fn peek_header_type_id(self: *Reader) ReaderError!itunesdb.header.TypeId {
        const type_id_u32 = try self.peek_field_at(0, u32, .big);
        std.debug.print("{}\n", .{self.index});
        return @as(itunesdb.header.TypeId, @enumFromInt(type_id_u32));
    }

    pub fn peek_data_set_type(self: *Reader) ReaderError!itunesdb.DataSetType {
        return @as(itunesdb.DataSetType, @enumFromInt(try self.peek_field_at(12, u32, .little)));
    }

    pub fn peek_data_obj_type(self: *Reader) ReaderError!itunesdb.DataObjectType {
        return @as(itunesdb.DataObjectType, @enumFromInt(try self.peek_field_at(12, u32, .little)));
    }

    fn read_bytes(self: *Reader, size: usize) ReaderError![]const u8 {
        const start_of_bytes = self.index;
        const end_of_bytes = self.index + size;

        if (self.bytes_available(size)) {
            const bytes = self.buffer[start_of_bytes..end_of_bytes];
            self.index = end_of_bytes;
            return bytes;
        }
        return error.NotEnoughBytes;
    }

    fn skip_bytes(self: *Reader, size: usize) ReaderError!void {
        if (!self.bytes_available(size)) {
            return error.NotEnoughBytes;
        }
        self.index += size;
    }

    fn bytes_available(self: *Reader, size: usize) bool {
        return self.index + size <= self.buffer.len;
    }
};
