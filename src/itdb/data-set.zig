const std = @import("std");

const prefix = @import("index.zig")._Prefix;

pub const DataSet = struct {
    header: MHSD,
};

pub const MHSD = packed struct {
    prefix: prefix,
    type: u32,
};
