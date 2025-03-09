const std = @import("std");

data: std.ArrayList(u8),

pub fn init(allocator: std.mem.Allocator) !@This() {
    return .{
        .data = std.ArrayList(u8).init(allocator),
    };
}

pub fn deinit(self: *@This()) void {
    self.data.deinit();
}

pub fn fromBytes(allocator: std.mem.Allocator, bytes: []const u8) !@This() {
    var data = try std.ArrayList(u8).initCapacity(allocator, bytes.len);
    data.items.len = bytes.len;
    std.mem.copyForwards(u8, data.items, bytes);
    return .{
        .data = data,
    };
}

pub fn toBytes(self: *const @This(), allocator: std.mem.Allocator) ![]u8 {
    const bytes = try allocator.alloc(u8, self.data.items.len);
    std.mem.copyForwards(u8, bytes, self.data.items);
    return bytes;
}
