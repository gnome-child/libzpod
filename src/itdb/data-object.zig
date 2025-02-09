const itdb = @import("index.zig");

pub const DataObject = struct {
    header: itdb.Header,

    pub fn read(reader: *itdb.serialization.itdb_reader) !DataObject {
        const prefix = try reader.read_prefix();
        const header = try reader.read_header(prefix);

        return DataObject{
            .header = header,
        };
    }
};

pub const MHOD = struct {
    prefix: itdb.Prefix,
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
