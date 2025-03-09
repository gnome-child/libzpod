const std = @import("std");

pub const MAGIC_VALUE: [4]u8 = [4]u8{ 'm', 'h', 's', 'd' };

pub const ListContainerHeader = extern struct {
    magic: [4]u8 align(1) = MAGIC_VALUE,
    header_len: u32 align(1) = @sizeOf(ListContainerHeader),
    len: u32 align(1) = @sizeOf(ListContainerHeader),
    data_set_type: u32 align(1) = 1,
    padding: [80]u8 align(1) = std.mem.zeroes([80]u8),
};
