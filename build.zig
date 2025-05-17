const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{
        .default_target = .{
            .cpu_arch = .wasm32,
            .os_tag = .freestanding,
        },
    });

    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "pong",
        .root_source_file = .{ .cwd_relative = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    exe.rdynamic = true;
    exe.entry = .disabled;

    const install = b.addInstallArtifact(exe, .{
        .dest_dir = .{ .override = .{ .custom = "" } },
    });

    b.getInstallStep().dependOn(&install.step);
}
