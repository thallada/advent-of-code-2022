const std = @import("std");

const day01 = @import("day01.zig");
const day02 = @import("day02.zig");
const utils = @import("utils.zig");

pub fn main() !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();
    var timer = std.time.Timer.start() catch @panic("need timer to benchmark solutions");

    {
        try stdout.print("Day 1\n", .{});

        const part1_start = timer.read();
        var part1 = try day01.solve_part1(day01.input);
        const part1_end = timer.read();
        const part1_time = utils.HumanTime.new(part1_end - part1_start);
        try stdout.print("Part 1: {} ({d:.2} {s})\n", .{ part1, part1_time.value, part1_time.unit.abbr() });

        const part2_start = timer.read();
        var part2 = try day01.solve_part2(day01.input);
        const part2_end = timer.read();
        const part2_time = utils.HumanTime.new(part2_end - part2_start);
        try stdout.print("Part 2: {} ({d:.2} {s})\n", .{ part2, part2_time.value, part2_time.unit.abbr() });
    }

    {
        try stdout.print("\nDay 2\n", .{});

        const part1_start = timer.read();
        var part1 = day02.solve_part1(day02.input);
        const part1_end = timer.read();
        const part1_time = utils.HumanTime.new(part1_end - part1_start);
        try stdout.print("Part 1: {} ({d:.2} {s})\n", .{ part1, part1_time.value, part1_time.unit.abbr() });

        const part2_start = timer.read();
        var part2 = day02.solve_part2(day02.input);
        const part2_end = timer.read();
        const part2_time = utils.HumanTime.new(part2_end - part2_start);
        try stdout.print("Part 2: {} ({d:.2} {s})\n", .{ part2, part2_time.value, part2_time.unit.abbr() });
    }

    try bw.flush();
}

test {
    std.testing.refAllDecls(@This());

    _ = day01;
    _ = day02;
    _ = utils;
}
