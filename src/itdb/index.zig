const std = @import("std");

pub const MHBD = @import("database.zig").MHBD;
pub const MHSD = @import("data-set.zig").MHSD;
pub const MHIT = @import("track-item.zig").MHIT;
pub const MHYP = @import("playlist.zig").MHYP;
pub const MHIP = @import("playlist-item.zig").MHIP;
const serial = @import("serialization.zig");

/// The type identifier for the database element expressed as u32.
///
/// Determines the Element subtype that will be populated when parsing.
///
/// u32 values as ASCII:
///     database: mhbd
///     data_set: mhsd
///     track_list: mhlt
///     track_item: mhit
///     playlist_list: mhlp
///     playlist: mhyp
///     playlist_item: mhip
///     data_object: mhod
///     album_list: mhla
///     album_item: mhia
pub const ElementType = enum(u32) {
    database = 0x6D686264, // "mhbd"
    data_set = 0x6D687364, // "mhsd"
    track_list = 0x6D686C74, // "mhlt"
    track_item = 0x6D686974, // "mhit"
    playlist_list = 0x6D686C70, // "mhlp"
    playlist = 0x6D687970, // "mhyp"
    playlist_item = 0x6D686970, // "mhip"
    data_object = 0x6D686F64, // "mhod"
    album_list = 0x6D686C61, // "mhla"
    album_item = 0x6D686961, // "mhia"
};

/// Element prefix containing type and size information.
pub const _Prefix = packed struct {
    /// Element type identifier as u32.
    element_type: u32,

    /// Length of the header in bytes.
    header_len: u32,

    /// Size of the element. For container elements, denotes the size of the element plus the size of all child elements.
    /// For list elements, denotes the number of child elements.
    element_size: u32,
};

pub fn load_test_file() ![]u8 {
    const allocator = std.testing.allocator;
    const path = "C:\\Users\\Shea\\Projects\\zig\\libzpod\\test_data\\itunesdb";

    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    const file_size = try file.getEndPos();

    const buffer = try allocator.alloc(u8, file_size);

    const bytes_read = try file.readAll(buffer);
    if (bytes_read != file_size) {
        allocator.free(buffer);
        return error.ShortRead;
    }

    return buffer;
}

test "parse itdb header" {
    const allocator = std.testing.allocator;
    const bytes = try load_test_file();
    defer allocator.free(bytes);
    var offset: usize = 244;
    const mhbd = try serial.parse_header(MHSD, bytes, &offset);
    const htype = @as(ElementType, @enumFromInt(@byteSwap(mhbd.header.prefix.element_type)));

    std.debug.print("parsed {}\n", .{htype});
}
