const std = @import("std");

/// Attempts to parse an iTunesDB header from a given byte array and advances the offset the size of the header.
/// Note: This should not be used on DataObjects.
///
/// - `header_type`: The type of the header to be parsed.
/// - `bytes`: The bytes to be parsed.
/// - `offset`: Address of an offset integer to be incremented.
/// - **Returns**: A struct containing the parsed header and a byte array of padding.
pub fn parse_header(comptime header_type: type, bytes: []const u8, offset: *usize) !struct { header: header_type, padding: []const u8 } {
    comptime {
        if (!@hasField(header_type, "prefix"))
            @compileError("Header type must have 'prefix' field");
        const dummy: header_type = undefined;
        const dummy_pref_type = @TypeOf(dummy.prefix);
        if (!@hasField(dummy_pref_type, "header_len"))
            @compileError("Header prefix must have 'header_len' field");
    }

    const data_size = @sizeOf(header_type);

    if (offset.* + data_size > bytes.len)
        return error.NotEnoughBytes;

    const header = std.mem.bytesToValue(header_type, bytes[offset.* .. offset.* + data_size]);
    const header_len = header.prefix.header_len;

    if (header_len < data_size)
        return error.InvalidHeaderLength;

    const padding = bytes[offset.* + data_size .. offset.* + header_len];
    offset.* += header_len;

    return .{
        .header = header,
        .padding = padding,
    };
}
