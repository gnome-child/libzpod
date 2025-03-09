const std = @import("std");

pub fn readInt(bytes: []const u8, offset: *usize, comptime T: type, endian: std.builtin.Endian) T {
    const start = offset.*;
    offset.* += @sizeOf(T);
    return std.mem.readInt(T, bytes[start .. start + @sizeOf(T)][0..@sizeOf(T)], endian);
}
