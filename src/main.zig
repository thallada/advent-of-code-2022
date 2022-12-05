const std = @import("std");

const day01 = @import("day01.zig");
const day02 = @import("day02.zig");
const day03 = @import("day03.zig");
const day04 = @import("day04.zig");
const day05 = @import("day05.zig");
const utils = @import("utils.zig");

fn solve_day(comptime day_num: u8, day: anytype, stdout: anytype, timer: *std.time.Timer) !void {
    try stdout.print("Day {}\n", .{day_num});

    const part1_start = timer.read();
    var part1 = try day.solve_part1(day.input);
    const part1_end = timer.read();
    const part1_time = utils.HumanTime.new(part1_end - part1_start);
    if (@TypeOf(part1) == []const u8) {
        try stdout.print("Part 1: {s} ({d:.2} {s})\n", .{ part1, part1_time.value, part1_time.unit.abbr() });
    } else {
        try stdout.print("Part 1: {} ({d:.2} {s})\n", .{ part1, part1_time.value, part1_time.unit.abbr() });
    }

    const part2_start = timer.read();
    var part2 = try day.solve_part2(day.input);
    const part2_end = timer.read();
    const part2_time = utils.HumanTime.new(part2_end - part2_start);
    if (@TypeOf(part2) == []const u8) {
        try stdout.print("Part 2: {s} ({d:.2} {s})\n", .{ part2, part2_time.value, part2_time.unit.abbr() });
    } else {
        try stdout.print("Part 2: {} ({d:.2} {s})\n", .{ part2, part2_time.value, part2_time.unit.abbr() });
    }
}

pub fn main() !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();
    var timer = std.time.Timer.start() catch @panic("need timer to benchmark solutions");

    try solve_day(1, day01, &stdout, &timer);
    try solve_day(2, day02, &stdout, &timer);
    try solve_day(3, day03, &stdout, &timer);
    try solve_day(4, day04, &stdout, &timer);
    try solve_day(5, day05, &stdout, &timer);

    try bw.flush();
}

test {
    std.testing.refAllDecls(@This());

    _ = day01;
    _ = day02;
    _ = day03;
    _ = day04;
    _ = day05;
    _ = utils;
}
