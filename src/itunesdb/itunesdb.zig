const std = @import("std");

pub const TrackItem = @import("track_item.zig").TrackItem;
pub const DataTagType = @import("data_tag/data_tag.zig").DataTagType;
pub const DataTagSet = @import("data_tag/data_tag.zig").DataTagSet;
pub const DataTag = @import("data_tag/data_tag.zig").DataTag;

test "assert sizes" {
    const root = @import("root.zig");
    const track_item = @import("track_item.zig");
    const list_container = @import("list_container.zig");

    std.debug.assert(@sizeOf(root.DatabaseHeader) == 244);
    std.debug.assert(@sizeOf(track_item.TrackItemHeader) == 624);
    std.debug.assert(@sizeOf(list_container.ListContainerHeader) == 96);
}

test "create string data tag" {
    //TODO
}
