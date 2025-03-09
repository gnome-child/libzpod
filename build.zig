const std = @import("std");

pub fn build(builder: *std.Build) void {
    const target = builder.standardTargetOptions(.{});
    const optimize = builder.standardOptimizeOption(.{});

    // Create main library module
    const libzpod_module = builder.addModule("libzpod", .{
        .root_source_file = builder.path("src/libzpod.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Create static library
    const lib_static = builder.addLibrary(.{
        .name = "libzpod",
        .root_module = libzpod_module,
        .linkage = .static,
    });

    builder.installArtifact(lib_static);

    const test_module = builder.createModule(.{
        .root_source_file = builder.path("test/test.zig"),
        .target = target,
        .optimize = optimize,
    });

    test_module.linkLibrary(lib_static);
    test_module.addImport("libzpod", libzpod_module);

    // Create test executable
    const tests = builder.addTest(.{
        .root_module = test_module,
    });

    // Set up test step
    const run_tests = builder.addRunArtifact(tests);
    const test_step = builder.step("test", "Run tests");
    test_step.dependOn(&run_tests.step);
}
