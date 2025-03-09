const std = @import("std");
const libzpod = @import("libzpod");

test "use libzpod" {
    _ = libzpod.itunesdb;
}

test "create and serialize data tag" {
    const allocator = std.testing.allocator;
    var arena = std.heap.ArenaAllocator.init(allocator);
    var data_tag = try libzpod.itunesdb.DataTag.init(arena.allocator(), libzpod.itunesdb.DataTagType.Title);

    const utf16 = try std.unicode.utf8ToUtf16LeAlloc(arena.allocator(), "donald j trump");
    try data_tag.body.string.setString(utf16);

    const bytes = try data_tag.toBytes(arena.allocator());
    var new_tag = try libzpod.itunesdb.DataTag.fromBytes(arena.allocator(), bytes);

    const utf16_2 = try std.unicode.utf8ToUtf16LeAlloc(arena.allocator(), "deepseek is better at zig than chatgpt??");
    try new_tag.body.string.setString(utf16_2);

    var track_item = libzpod.itunesdb.TrackItem.init(arena.allocator());

    try track_item.setTag(new_tag);

    var tag_ref = try track_item.getTag(.Title);

    std.debug.print("{any}\n{any}\n", .{ try tag_ref.toBytes(arena.allocator()), tag_ref.body.string.getString() });

    arena.deinit();
}
