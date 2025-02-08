const std = @import("std");

const itdb = @import("index.zig");

const DataObject = @import("data-object.zig").DataObject;

pub const AlbumItem = struct {
    header: itdb.Header,
    data_objects: std.ArrayList(DataObject),
};

pub const MHIA = struct {
    prefix: itdb.Prefix,
    body: MhiaBody,
    padding: []const u8,
};

pub const MhiaBody = packed struct {
    number_of_strings: u32,
    unk0: u16,
    album_id: u16,

    // Some kind of timestamp?
    unk1: u64,

    // Always 2?
    unk2: u32,
};
