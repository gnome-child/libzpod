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
            .mhbd => itdb.Header{ .mhbd = try self.read_header_as(mhbd.MHBD) },
            .mhsd => itdb.Header{ .mhsd = try self.read_header_as(mhsd.MHSD) },
            .mhlt => itdb.Header{ .mhlt = try self.read_header_as(mhlt.MHLT) },
            .mhlp => itdb.Header{ .mhlp = try self.read_header_as(mhlp.MHLP) },
            .mhla => itdb.Header{ .mhla = try self.read_header_as(mhla.MHLA) },
            .mhit => itdb.Header{ .mhit = try self.read_header_as(mhit.MHIT) },
            .mhyp => itdb.Header{ .mhyp = try self.read_header_as(mhyp.MHYP) },
            .mhip => itdb.Header{ .mhip = try self.read_header_as(mhip.MHIP) },
            .mhia => itdb.Header{ .mhia = try self.read_header_as(mhia.MHIA) },
            .mhod => itdb.Header{ .mhod = try self.read_data_object() },
        };
    }
};
