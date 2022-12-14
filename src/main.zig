const std = @import("std");

const day01 = @import("day01.zig");
const day02 = @import("day02.zig");
const day03 = @import("day03.zig");
const day04 = @import("day04.zig");
const day05 = @import("day05.zig");
const day06 = @import("day06.zig");
const day07 = @import("day07.zig");
const day08 = @import("day08.zig");
const day09 = @import("day09.zig");
const day10 = @import("day10.zig");
const day11 = @import("day11.zig");
const day12 = @import("day12.zig");
const utils = @import("utils.zig");

fn solve_day(comptime day_num: u8, day: anytype, stdout: anytype, timer: *std.time.Timer) !void {
    try stdout.print("Day {}\n", .{day_num});

    const part1_start = timer.read();
    var part1 = try day.solve_part1(day.input);
    const part1_end = timer.read();
    const part1_time = utils.HumanTime.new(part1_end - part1_start);
    if (@TypeOf(part1) == usize or @TypeOf(part1) == isize or @TypeOf(part1) == u64 or @TypeOf(part1) == u128) {
        try stdout.print("Part 1: {} ({d:.2} {s})\n", .{ part1, part1_time.value, part1_time.unit.abbr() });
    } else {
        try stdout.print("Part 1: \n{s} ({d:.2} {s})\n", .{ part1, part1_time.value, part1_time.unit.abbr() });
    }

    const part2_start = timer.read();
    var part2 = try day.solve_part2(day.input);
    const part2_end = timer.read();
    const part2_time = utils.HumanTime.new(part2_end - part2_start);
    if (@TypeOf(part2) == usize or @TypeOf(part2) == isize or @TypeOf(part2) == u64 or @TypeOf(part2) == u128) {
        try stdout.print("Part 2: {} ({d:.2} {s})\n", .{ part2, part2_time.value, part2_time.unit.abbr() });
    } else {
        try stdout.print("Part 2: \n{s} ({d:.2} {s})\n", .{ part2, part2_time.value, part2_time.unit.abbr() });
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
    try solve_day(6, day06, &stdout, &timer);
    try solve_day(7, day07, &stdout, &timer);
    try solve_day(8, day08, &stdout, &timer);
    try solve_day(9, day09, &stdout, &timer);
    try solve_day(10, day10, &stdout, &timer);
    try solve_day(11, day11, &stdout, &timer);
    try solve_day(12, day12, &stdout, &timer);

    try bw.flush();
}

test {
    std.testing.refAllDecls(@This());

    _ = day01;
    _ = day02;
    _ = day03;
    _ = day04;
    _ = day05;
    _ = day06;
    _ = day07;
    _ = day08;
    _ = day09;
    _ = day10;
    _ = day11;
    _ = day12;
    _ = utils;
}
