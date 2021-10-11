const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    var target = b.standardTargetOptions(.{
        .default_target = .{
            .os_tag = .windows,
            .cpu_model = .baseline,
        }
    });

    const mode: std.builtin.Mode = b.standardReleaseOptions();
    const exe = b.addExecutable("IsRunning", "src/main.zig");

    exe.single_threaded = true;
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
