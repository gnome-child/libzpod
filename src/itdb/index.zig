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
    mhbd: mhbd.Fields,
    mhsd: mhsd.Fields,
    mhlt: mhlt.Fields,
    mhlp: mhlp.Fields,
    mhla: mhla.Fields,
    mhit: mhit.Fields,
    mhyp: mhyp.Fields,
    mhip: mhip.Fields,
    mhia: mhia.Fields,
    mhod: mhod.DataObject,
};

pub const ItunesDB = struct {
    arena: std.heap.ArenaAllocator,
    root: Root,
    track_list: TrackList,

    pub fn init(bytes: []const u8) !ItunesDB {
        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        var reader = serializer.ItdbReader.init(arena.allocator(), bytes);

        const root = try reader.parse(Root);

        var track_list: TrackList = undefined;

        for (root.data_sets.items) |data_set| {
            if (data_set.header.data_type == @intFromEnum(mhsd.DataType.track_list)) {
                track_list = data_set.data.track_list;
            }
        }

        return ItunesDB{
            .arena = arena,
            .root = root,
            .track_list = track_list,
        };
    }

    pub fn deinit(self: *ItunesDB) void {
        self.arena.deinit();
    }

    pub fn add_track(self: *ItunesDB) !TrackItem {
        const track_to_add = self.track_list.track_items.items[3];

        try self.track_list.track_items.append(track_to_add);

        return track_to_add;
    }
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

    const mhsd_struct = try reader.read_header_as(mhsd.Fields);

    std.debug.print("mhsd data:\n{}\n", .{mhsd_struct});
}

test "parse itdb" {
    const test_alloc = std.testing.allocator;
    const bytes = try load_test_file(2);
    defer test_alloc.free(bytes);

    var itdb = try ItunesDB.init(bytes);
    const track = try itdb.add_track();
    std.debug.print("\n{s}\n", .{track.data.items[1].string.string_data});
    itdb.deinit();
}
