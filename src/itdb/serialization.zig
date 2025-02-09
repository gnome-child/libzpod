const std = @import("std");

const itdb = @import("index.zig");

const MhbdBody = @import("database.zig").MhbdBody;
const MhsdBody = @import("data-set.zig").MhsdBody;
const MhitBody = @import("track-item.zig").MhitBody;
const MhypBody = @import("playlist.zig").MhypBody;
const MhipBody = @import("playlist-item.zig").MhipBody;
const MhiaBody = @import("album-item.zig").MhiaBody;
const MhodBody = @import("data-object.zig").MhodBody;

const Root = @import("database.zig").Root;
const DataSet = @import("data-set.zig").DataSet;

/// TODO: Docs
pub const itdb_reader = struct {
    allocator: std.mem.Allocator,
    bytes: []const u8,
    index: usize = 0,

    pub fn init(allocator: std.mem.Allocator, bytes: []const u8) itdb_reader {
        return .{ .allocator = allocator, .bytes = bytes };
    }

    pub fn read_root(self: *itdb_reader) !Root {
        return Root.read(self);
    }

    // Note: bitSizeOf divided by 8 is required to get the ACTUAL size of the packed type in bytes, as sizeOf contains padding even on packed structs.
    pub fn read_prefix(self: *itdb_reader) !itdb.Prefix {
        const prefix_size: usize = @bitSizeOf(itdb.Prefix) / 8;
        const next_index: usize = self.index + prefix_size;
        const prefix = std.mem.bytesToValue(itdb.Prefix, self.bytes[self.index..next_index][0..prefix_size]);
        std.debug.print("in prefix next o/s: {}\n", .{next_index});

        self.index = next_index;
        return prefix;
    }

    pub fn read_header(self: *itdb_reader, prefix: itdb.Prefix) !itdb.Header {
        const header_type = @as(itdb.TypeId, @enumFromInt(@byteSwap(prefix.element_type)));

        std.debug.print("entered read header: {}\n", .{header_type});

        return switch (header_type) {
            .database => self.read_mhbd(prefix),
            .data_set => self.read_mhsd(prefix),
            .track_list => self.read_mhlt(prefix),
            .track_item => self.read_mhit(prefix),
            .playlist_list => self.read_mhlp(prefix),
            .playlist => self.read_mhyp(prefix),
            .playlist_item => self.read_mhip(prefix),
            .album_list => self.read_mhla(prefix),
            .album_item => self.read_mhia(prefix),
            .data_object => self.read_mhod(prefix),
        };
    }

    fn read_mhbd(self: *itdb_reader, prefix: itdb.Prefix) !itdb.Header {
        const expected_size: usize = @bitSizeOf(MhbdBody) / 8;
        try self.ensure_bytes_available(expected_size);

        const next_index: usize = self.index + expected_size;
        const padding_size: usize = prefix.header_len - ((@bitSizeOf(itdb.Prefix) / 8) + expected_size);
        const body = std.mem.bytesToValue(MhbdBody, self.bytes[self.index..next_index][0..expected_size]);

        self.index = next_index;

        std.debug.print("in mhbd next o/s: {}\n", .{self.index});

        const padding = try self.read_padding(padding_size);

        return itdb.Header{ .database = .{
            .prefix = prefix,
            .body = body,
            .padding = padding,
        } };
    }

    fn read_mhsd(self: *itdb_reader, prefix: itdb.Prefix) !itdb.Header {
        const expected_size: usize = @bitSizeOf(MhsdBody) / 8;
        try self.ensure_bytes_available(expected_size);

        const next_index: usize = self.index + expected_size;
        const padding_size: usize = prefix.header_len - ((@bitSizeOf(itdb.Prefix) / 8) + expected_size);
        const body = std.mem.bytesToValue(MhsdBody, self.bytes[self.index..next_index][0..expected_size]);

        self.index = next_index;

        std.debug.print("in mhsd next o/s: {}\n", .{self.index});

        const padding = try self.read_padding(padding_size);

        return itdb.Header{ .data_set = .{
            .prefix = prefix,
            .body = body,
            .padding = padding,
        } };
    }

    fn read_mhlt(self: *itdb_reader, prefix: itdb.Prefix) !itdb.Header {
        const expected_size: usize = @bitSizeOf(itdb.Prefix) / 8;
        try self.ensure_bytes_available(expected_size);

        const padding_size: usize = prefix.header_len - expected_size;

        std.debug.print("in mhlt next o/s: {}\n", .{self.index});

        const padding = try self.read_padding(padding_size);

        return itdb.Header{ .track_list = .{
            .prefix = prefix,
            .padding = padding,
        } };
    }

    fn read_mhit(self: *itdb_reader, prefix: itdb.Prefix) !itdb.Header {
        const expected_size: usize = @bitSizeOf(MhitBody) / 8;
        try self.ensure_bytes_available(expected_size);

        const next_index: usize = self.index + expected_size;
        const padding_size: usize = prefix.header_len - ((@bitSizeOf(itdb.Prefix) / 8) + expected_size);
        const body = std.mem.bytesToValue(MhitBody, self.bytes[self.index..next_index][0..expected_size]);

        self.index = next_index;

        std.debug.print("in mhit next o/s: {}\n", .{self.index});

        const padding = try self.read_padding(padding_size);

        return itdb.Header{ .track_item = .{
            .prefix = prefix,
            .body = body,
            .padding = padding,
        } };
    }

    fn read_mhlp(self: *itdb_reader, prefix: itdb.Prefix) !itdb.Header {
        const expected_size: usize = @bitSizeOf(itdb.Prefix) / 8;
        try self.ensure_bytes_available(expected_size);

        const padding_size: usize = prefix.header_len - expected_size;

        std.debug.print("in mhlp next o/s: {}\n", .{self.index});

        const padding = try self.read_padding(padding_size);

        return itdb.Header{ .playlist_list = .{
            .prefix = prefix,
            .padding = padding,
        } };
    }

    fn read_mhyp(self: *itdb_reader, prefix: itdb.Prefix) !itdb.Header {
        const expected_size: usize = @bitSizeOf(MhypBody) / 8;
        try self.ensure_bytes_available(expected_size);

        const next_index: usize = self.index + expected_size;
        const padding_size: usize = prefix.header_len - ((@bitSizeOf(itdb.Prefix) / 8) + expected_size);
        const body = std.mem.bytesToValue(MhypBody, self.bytes[self.index..next_index][0..expected_size]);

        self.index = next_index;

        std.debug.print("in mhyp next o/s: {}\n", .{self.index});

        const padding = try self.read_padding(padding_size);

        return itdb.Header{ .playlist = .{
            .prefix = prefix,
            .body = body,
            .padding = padding,
        } };
    }

    fn read_mhip(self: *itdb_reader, prefix: itdb.Prefix) !itdb.Header {
        const expected_size: usize = @bitSizeOf(MhipBody) / 8;
        try self.ensure_bytes_available(expected_size);

        const next_index: usize = self.index + expected_size;
        const padding_size: usize = prefix.header_len - ((@bitSizeOf(itdb.Prefix) / 8) + expected_size);
        const body = std.mem.bytesToValue(MhipBody, self.bytes[self.index..next_index][0..expected_size]);

        self.index = next_index;

        std.debug.print("in mhip next o/s: {}\n", .{self.index});

        const padding = try self.read_padding(padding_size);

        return itdb.Header{ .playlist_item = .{
            .prefix = prefix,
            .body = body,
            .padding = padding,
        } };
    }

    fn read_mhla(self: *itdb_reader, prefix: itdb.Prefix) !itdb.Header {
        const expected_size: usize = @bitSizeOf(itdb.Prefix) / 8;
        try self.ensure_bytes_available(expected_size);

        const padding_size: usize = prefix.header_len - expected_size;
        std.debug.print("in mhla next o/s: {}\n", .{self.index});
        std.debug.print("   expected data size: {}\n", .{expected_size});

        const padding = try self.read_padding(padding_size);

        return itdb.Header{ .album_list = .{
            .prefix = prefix,
            .padding = padding,
        } };
    }

    fn read_mhia(self: *itdb_reader, prefix: itdb.Prefix) !itdb.Header {
        const expected_size: usize = @bitSizeOf(MhiaBody) / 8;
        try self.ensure_bytes_available(expected_size);

        const next_index: usize = self.index + expected_size;
        const padding_size: usize = prefix.header_len - ((@bitSizeOf(itdb.Prefix) / 8) + expected_size);
        const body = std.mem.bytesToValue(MhiaBody, self.bytes[self.index..next_index][0..expected_size]);

        self.index = next_index;

        std.debug.print("in mhia next o/s: {}\n", .{self.index});
        std.debug.print("   expected data size: {}\n", .{expected_size});

        const padding = try self.read_padding(padding_size);

        return itdb.Header{ .album_item = .{
            .prefix = prefix,
            .body = body,
            .padding = padding,
        } };
    }

    fn read_mhod(self: *itdb_reader, prefix: itdb.Prefix) !itdb.Header {
        std.debug.print("entered mhod: {}\n", .{self.index});

        const expected_size: usize = prefix.element_size - 12;
        try self.ensure_bytes_available(expected_size);

        const next_index: usize = self.index + expected_size;

        self.index = next_index;

        std.debug.print("leaving mhod: {}\n", .{self.index});

        return itdb.Header{
            .data_object = .{
                .prefix = prefix,
            },
        };
    }

    pub fn read_padding(self: *itdb_reader, size: usize) ![]const u8 {
        try self.ensure_bytes_available(size);

        const next_index = self.index + size;
        const padding = self.bytes[self.index..next_index][0..size];

        self.index = next_index;

        std.debug.print("in padding next o/s: {}\n", .{self.index});
        std.debug.print("   padding: {}\n", .{padding.len});

        return padding;
    }

    fn ensure_bytes_available(self: *itdb_reader, required: usize) !void {
        if (self.index + required > self.bytes.len) {
            return error.UnexpectedEndOfData;
        }
    }
};

pub const itdb_writer = struct {};
