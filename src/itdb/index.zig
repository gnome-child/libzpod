const std = @import("std");

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

pub const serializer = @import("serializer.zig");

pub const Root = mhbd.Root;
pub const DataSet = mhsd.DataSet;
pub const TrackList = mhlt.TrackList;
pub const PlaylistList = mhlp.PlaylistList;
pub const AlbumList = mhla.AlbumList;
pub const TrackItem = mhit.TrackItem;
pub const Playlist = mhyp.Playlist;
pub const PlaylistItem = mhip.PlaylistItem;
pub const AlbumItem = mhia.AlbumItem;
pub const DataObject = mhod.DataObject;

pub const HeaderId = enum(u32) {
    mhbd = mhbd.id,
    mhsd = mhsd.id,
    mhlt = mhlt.id,
    mhlp = mhlp.id,
    mhla = mhla.id,
    mhit = mhit.id,
    mhyp = mhyp.id,
    mhip = mhip.id,
    mhia = mhia.id,
    mhod = mhod.id,
};

pub const Header = union(HeaderId) {
    mhbd: mhbd.MHBD,
    mhsd: mhsd.MHSD,
    mhlt: mhlt.MHLT,
    mhlp: mhlp.MHLP,
    mhla: mhla.MHLA,
    mhit: mhit.MHIT,
    mhyp: mhyp.MHYP,
    mhip: mhip.MHIP,
    mhia: mhia.MHIA,
    mhod: mhod.DataObject,
};

pub const Element = union(HeaderId) {
    mhbd: mhbd.Root,
    mhsd: mhsd.DataSet,
    mhlt: mhlt.TrackList,
    mhlp: mhlp.PlaylistList,
    mhla: mhla.AlbumList,
    mhit: mhit.TrackItem,
    mhyp: mhyp.Playlist,
    mhip: mhip.PlaylistItem,
    mhia: mhia.AlbumItem,
    mhod: mhod.DataObject,
};

pub fn load_test_file(index: u32) ![]u8 {
    const allocator = std.testing.allocator;
    const path = switch (index) {
        1 => "test_data/itunesdb1",
        2 => "test_data/itunesdb2",
        else => "test_data/itunesdb1",
    };
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

test "test load test file" {
    const allocator = std.testing.allocator;
    const bytes = try load_test_file(2);
    defer allocator.free(bytes);
    std.debug.assert(bytes.len > 0);
}

test "read data set at 244" {
    const allocator = std.testing.allocator;
    const bytes = try load_test_file(2);
    defer allocator.free(bytes);

    var reader = serializer.ItdbReader.init(allocator, bytes);

    reader.index = 244;
    std.debug.assert(try reader.peek_field_be(u32) == mhsd.id);

    const mhsd_struct = try reader.read_header_as(mhsd.MHSD);

    std.debug.print("mhsd data:\n{}\n", .{mhsd_struct});
}

test "parse itdb" {
    const test_alloc = std.testing.allocator;
    const bytes = try load_test_file(2);
    defer test_alloc.free(bytes);

    var arena = std.heap.ArenaAllocator.init(test_alloc);
    const allocator = arena.allocator();
    var reader = serializer.ItdbReader.init(allocator, bytes);
    const root = try reader.parse(mhbd.Root);

    std.debug.print("root: {}", .{root.header});
    arena.deinit();
}
