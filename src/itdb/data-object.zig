const itdb = @import("index.zig");

pub const MHOD = struct {
    prefix: itdb.Prefix,
    body: MhodBody,
    string: []const u8,
    padding: []const u8,
};

pub const MhodBody = packed struct {
    type: u32,
    unk0: u32,
    unk1: u32,
    position: u32,
    length: u32,
    unk2: u32,
    unk3: u32,
};
