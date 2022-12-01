const std = @import("std");

const MAX_BYTES = 2048 * 2048;

pub fn read_file(allocator: std.mem.Allocator, filename: []const u8) ![]const u8 {
    const input_file = try std.fs.cwd().openFile(filename, .{ .mode = std.fs.File.OpenMode.read_only });
    defer input_file.close();

    return try input_file.readToEndAlloc(allocator, MAX_BYTES);
}

pub const TimeUnit = enum {
    nanoseconds,
    microseconds,
    milliseconds,
    seconds,
    minutes,
    hours,
    pub fn abbr(self: TimeUnit) []const u8 {
        return switch (self) {
            TimeUnit.nanoseconds => "ns",
            TimeUnit.microseconds => "μs",
            TimeUnit.milliseconds => "ms",
            TimeUnit.seconds => "s",
            TimeUnit.minutes => "m",
            TimeUnit.hours => "h",
        };
    }
};

pub const HumanTime = struct {
    value: f64,
    unit: TimeUnit,
    pub fn new(nanoseconds: u64) HumanTime {
        @setFloatMode(.Optimized);
        const time: f64 = @intToFloat(f64, nanoseconds);
        if (time > 1_000_000_000 * 60 * 60) {
            return HumanTime{
                .value = time / (1_000_000_000 * 60 * 60),
                .unit = TimeUnit.hours,
            };
        } else if (time > 1_000_000_000 * 60) {
            return HumanTime{
                .value = time / (1_000_000_000 * 60),
                .unit = TimeUnit.minutes,
            };
        } else if (time > 1_000_000_000) {
            return HumanTime{
                .value = time / 1_000_000_000,
                .unit = TimeUnit.seconds,
            };
        } else if (time > 1_000_000) {
            return HumanTime{
                .value = time / 1_000_000,
                .unit = TimeUnit.milliseconds,
            };
        } else if (time > 1_000) {
            return HumanTime{
                .value = time / 1000,
                .unit = TimeUnit.microseconds,
            };
        } else {
            return HumanTime{
                .value = time,
                .unit = TimeUnit.nanoseconds,
            };
        }
    }
};

test "HumanTime.new" {
    try std.testing.expectEqual(HumanTime.new(100), HumanTime{ .value = 100, .unit = TimeUnit.nanoseconds });
    try std.testing.expectEqual(HumanTime.new(2_000), HumanTime{ .value = 2, .unit = TimeUnit.microseconds });
    try std.testing.expectEqual(HumanTime.new(2_000_000), HumanTime{ .value = 2, .unit = TimeUnit.milliseconds });
    try std.testing.expectEqual(HumanTime.new(2_000_000_000), HumanTime{ .value = 2, .unit = TimeUnit.seconds });
    try std.testing.expectEqual(HumanTime.new(2_000_000_000 * 60), HumanTime{ .value = 2, .unit = TimeUnit.minutes });
    try std.testing.expectEqual(HumanTime.new(2_000_000_000 * 60 * 60), HumanTime{ .value = 2, .unit = TimeUnit.hours });
}
