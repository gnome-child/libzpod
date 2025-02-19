pub const mhbd = @import("mhbd.zig");
pub const mhsd = @import("mhsd.zig");
pub const mhlt = @import("mhlt.zig");
pub const mhlp = @import("mhlp.zig");
pub const mhla = @import("mhla.zig");
pub const mhit = @import("mhit.zig");
pub const mhyp = @import("mhyp.zig");
pub const mhip = @import("mhip.zig");
pub const mhia = @import("mhia.zig");
pub const mhod = @import("mhod.zig");

pub const TypeId = enum(u32) {
    mhbd = mhbd.type_id_u32,
    mhsd = mhsd.type_id_u32,
    mhlt = mhlt.type_id_u32,
    mhlp = mhlp.type_id_u32,
    mhla = mhla.type_id_u32,
    mhit = mhit.type_id_u32,
    mhyp = mhyp.type_id_u32,
    mhip = mhip.type_id_u32,
    mhia = mhia.type_id_u32,
    mhod = mhod.type_id_u32,
};

pub const Fields = union(TypeId) {
    mhbd: mhbd.Fields,
    mhsd: mhsd.Fields,
    mhlt: mhlt.Fields,
    mhlp: mhlp.Fields,
    mhla: mhla.Fields,
    mhit: mhit.Fields,
    mhyp: mhyp.Fields,
    mhip: mhip.Fields,
    mhia: mhia.Fields,
    mhod: mhod.Fields,
};
