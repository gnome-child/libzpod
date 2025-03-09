const std = @import("std");

const util = @import("../../util.zig");
const DataTagType = @import("data_tag.zig").DataTagType;

pub const string_types = &[_]DataTagType{
    .Title,
    .Location,
    .Album,
    .Artist,
    .Genre,
    .Filetype,
    .EqSetting,
    .Comment,
    .Category,
    .Composer,
    .Grouping,
    .Description,
};

position: u32 = 1,
string_len: u32 = 0,
unk_0x20: u32 = 0,
unk_0x24: u32 = 0,
chars: std.ArrayList(u16),

pub fn init(allocator: std.mem.Allocator) !@This() {
    return .{
        .chars = std.ArrayList(u16).init(allocator),
    };
}

pub fn deinit(self: *@This()) void {
    self.chars.deinit();
}

pub fn getString(self: *const @This()) []const u16 {
    return self.chars.items;
}

pub fn setString(self: *@This(), string: []const u16) !void {
    self.chars.clearRetainingCapacity();
    try self.chars.ensureTotalCapacity(string.len);
    try self.chars.appendSlice(string);
    self.string_len = @as(u32, @intCast(string.len * 2));
}

pub fn fromBytes(allocator: std.mem.Allocator, bytes: []const u8) !@This() {
    var offset: usize = 0;

    const position = util.readInt(bytes, &offset, u32, .little);
    const string_len = util.readInt(bytes, &offset, u32, .little);
    const unk_0x20 = util.readInt(bytes, &offset, u32, .little);
    const unk_0x24 = util.readInt(bytes, &offset, u32, .little);

    if (bytes.len - offset != string_len) {
        return error.IncorrectByteLen;
    }

    const utf16_len = (bytes.len - offset) / 2;
    var chars = try std.ArrayList(u16).initCapacity(allocator, utf16_len);

    const utf16_bytes = bytes[offset..];

    for (0..utf16_len) |i| {
        const byte_index = i * 2;
        const char = @as(u16, utf16_bytes[byte_index]) | (@as(u16, utf16_bytes[byte_index + 1]) << 8);
        chars.appendAssumeCapacity(char);
    }

    return .{
        .position = position,
        .string_len = string_len,
        .unk_0x20 = unk_0x20,
        .unk_0x24 = unk_0x24,
        .chars = chars,
    };
}

pub fn toBytes(self: *const @This(), allocator: std.mem.Allocator) ![]u8 {
    const total_size = 16 + (self.chars.items.len * 2);
    const bytes = try allocator.alloc(u8, total_size);
    errdefer allocator.free(bytes);

    var stream = std.io.fixedBufferStream(bytes);
    const writer = stream.writer();

    try writer.writeInt(u32, self.position, .little);
    try writer.writeInt(u32, self.string_len, .little);
    try writer.writeInt(u32, self.unk_0x20, .little);
    try writer.writeInt(u32, self.unk_0x24, .little);

    for (self.chars.items) |item| {
        try writer.writeInt(u16, item, .little);
    }

    return bytes;
}
