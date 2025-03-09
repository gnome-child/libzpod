const std = @import("std");

pub const MAGIC_VALUE: [4]u8 = [4]u8{ 'm', 'h', 'b', 'd' };

pub const DatabaseHeader = extern struct {
    magic: [4]u8 align(1) = MAGIC_VALUE,
    header_len: u32 align(1) = @sizeOf(DatabaseHeader),
    len: u32 align(1) = @sizeOf(DatabaseHeader),
    unk_0x0C: u32 align(1) = 1,
    version: u32 align(1) = 0x70,
    data_set_count: u32 align(1) = 0,
    database_id: u64 align(1) = 0, // TODO: generate id
    unk_0x20: u16 align(1) = 2,
    hashing_scheme: u16 align(1) = 1,
    unk_0x24: u64 align(1) = 0,
    padding_0x2C: [26]u8 align(1) = std.mem.zeroes([26]u8),
    lang: u16 align(1) = 0x656E, // 'en' in little-endian
    persistent_id: u64 align(1) = 0, // TODO: generate persistent id
    unk_0x50: u32 align(1) = 0,
    unk_0x54: u32 align(1) = 0,
    padding_0x58: [20]u8 align(1) = std.mem.zeroes([20]u8),
    timezone_offset: i32 align(1) = 0,
    padding_0x70: [48]u8 align(1) = std.mem.zeroes([48]u8),
    unk_0xA0: u32 align(1) = 0xFFFFFFFF,
    audio_lang: u16 align(1) = 25,
    subtitle_lang: u16 align(1) = 10,
    padding_0xA8: [76]u8 align(1) = std.mem.zeroes([76]u8),
};
