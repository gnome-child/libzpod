const std = @import("std");
const util = @import("../../util.zig");
const string = @import("string.zig");
const generic = @import("generic.zig");

pub const MAGIC_VALUE: [4]u8 = [4]u8{ 'm', 'h', 'o', 'd' };

pub const DataTagType = enum(u32) {
    Title = 1,
    Location = 2,
    Album = 3,
    Artist = 4,
    Genre = 5,
    Filetype = 6,
    EqSetting = 7,
    Comment = 8,
    Category = 9,
    Composer = 12,
    Grouping = 13,
    Description = 14,
    PodcastEnclosureUrl = 15,
    PodcastRssUrl = 16,
    ChapterData = 17,
    Subtitle = 18,
    Show = 19,
    EpisodeNumber = 20,
    TvNetwork = 21,
    AlbumArtist = 22,
    ArtistSort = 23,
    Keywords = 24,
    TvShowLocale = 25,
    TitleSort = 27,
    AlbumSort = 28,
    AlbumArtistSort = 29,
    ComposerSort = 30,
    TvShowSort = 31,
    UnknownVideoBinary = 32,
    Copyright = 39,
    SmartPlaylistData = 50,
    SmartPlaylistRules = 51,
    LibraryPlaylistIndex = 52,
    JumpTable = 53,
    ColumnSizingAndOrder = 100,
    AlbumInAlbumList = 200,
    ArtistInAlbumList = 201,
    ArtistSortInAlbumList = 202,
    PodcastUrlInAlbumList = 203,
    TvShowInAlbumList = 204,
    Unknown = 0,

    pub fn isStringType(self: DataTagType) bool {
        inline for (string.string_types) |value| {
            if (self == value) return true;
        }
        return false;
    }
    // add more type checks here
};

pub const DataTagSet = struct {
    hash_map: std.AutoHashMap(DataTagType, DataTag),

    pub fn init(allocator: std.mem.Allocator) DataTagSet {
        return .{
            .hash_map = std.AutoHashMap(DataTagType, DataTag).init(allocator),
        };
    }

    pub fn deinit(self: *DataTagSet) void {
        var iterator = self.hash_map.valueIterator();

        while (iterator.next()) |value| {
            value.deinit();
        }
        self.hash_map.deinit();
    }

    pub fn get(self: *DataTagSet, key: DataTagType) !DataTag {
        if (self.contains(key)) return self.hash_map.get(key).? else return error.NoEntry;
    }

    pub fn contains(self: *DataTagSet, key: DataTagType) bool {
        return self.hash_map.contains(key);
    }

    pub fn set(self: *DataTagSet, value: DataTag) !void {
        try self.hash_map.put(@as(DataTagType, @enumFromInt(value.header.data_type)), value);
    }

    pub fn remove(self: *DataTagSet, key: DataTagType) void {
        self.hash_map.remove(key);
    }
};

pub const DataTag = struct {
    allocator: std.mem.Allocator,
    header: DataTagHeader,
    body: DataTagBody,

    pub fn init(allocator: std.mem.Allocator, data_obj_type: DataTagType) !DataTag {
        return .{
            .allocator = allocator,
            .header = DataTagHeader.init(data_obj_type),
            .body = try DataTagBody.init(allocator, data_obj_type),
        };
    }

    pub fn deinit(self: *@This()) void {
        self.body.deinit();
    }

    pub fn fromBytes(allocator: std.mem.Allocator, bytes: []const u8) !DataTag {
        if (bytes.len < @sizeOf(DataTagHeader)) return error.BufferTooSmall;

        const header = try DataTagHeader.fromBytes(bytes[0..@sizeOf(DataTagHeader)]);

        const body_bytes = bytes[@sizeOf(DataTagHeader)..header.len];

        const tag_type: DataTagType = @enumFromInt(header.data_type);
        const body = try DataTagBody.fromBytes(allocator, tag_type, body_bytes);

        return .{
            .allocator = allocator,
            .header = header,
            .body = body,
        };
    }

    pub fn toBytes(self: *const DataTag, allocator: std.mem.Allocator) ![]u8 {
        const body_bytes = try self.body.toBytes(allocator);

        const total_size = @sizeOf(DataTagHeader) + body_bytes.len;
        var buffer = try allocator.alloc(u8, total_size);

        var header_copy = self.header;
        header_copy.len = @as(u32, @intCast(total_size));

        @memcpy(buffer[0..@sizeOf(DataTagHeader)], std.mem.asBytes(&header_copy));
        @memcpy(buffer[@sizeOf(DataTagHeader)..], body_bytes);

        allocator.free(body_bytes);
        return buffer;
    }
};

pub const DataTagHeader = extern struct {
    magic: [4]u8 align(1) = MAGIC_VALUE,
    header_len: u32 align(1) = @sizeOf(DataTagHeader),
    len: u32 align(1) = @sizeOf(DataTagHeader),
    data_type: u32 align(1) = 0,
    padding: [8]u8 align(1) = std.mem.zeroes([8]u8),

    fn init(data_obj_type: DataTagType) DataTagHeader {
        return .{
            .data_type = @as(u32, @intFromEnum(data_obj_type)),
        };
    }

    pub fn fromBytes(bytes: []const u8) !DataTagHeader {
        if (bytes.len < @sizeOf(DataTagHeader)) return error.BufferTooSmall;
        const header = @as(*const DataTagHeader, @ptrCast(bytes.ptr)).*;
        if (!std.mem.eql(u8, &header.magic, &MAGIC_VALUE)) return error.InvalidHeader;
        if (header.header_len != @sizeOf(DataTagHeader)) return error.CorruptedHeader;
        return header;
    }

    pub fn toBytes(self: *const DataTagHeader, allocator: std.mem.Allocator) ![]u8 {
        const bytes = try allocator.alloc(u8, @sizeOf(DataTagHeader));
        @memcpy(bytes, std.mem.asBytes(self));
        return bytes;
    }
};

pub const DataTagBody = union(enum) {
    string: string,
    generic: generic,

    // More type checks should be added here
    pub fn init(allocator: std.mem.Allocator, obj_type: DataTagType) !DataTagBody {
        return if (obj_type.isStringType())
            .{ .string = try string.init(allocator) }
        else
            .{ .generic = try generic.init(allocator) };
    }

    pub fn deinit(self: *DataTagBody) void {
        switch (self.*) {
            .string => |*s| s.deinit(),
            .generic => |*g| g.deinit(),
        }
    }

    // ...And here
    pub fn fromBytes(allocator: std.mem.Allocator, tag_type: DataTagType, bytes: []const u8) !DataTagBody {
        if (tag_type.isStringType()) {
            return .{ .string = try string.fromBytes(allocator, bytes) };
        } else {
            return .{ .generic = try generic.fromBytes(allocator, bytes) };
        }
    }

    pub fn toBytes(self: *const DataTagBody, allocator: std.mem.Allocator) ![]u8 {
        switch (self.*) {
            .string => |*s| return s.toBytes(allocator),
            .generic => |*g| return g.toBytes(allocator),
        }
    }
};
