const std = @import("std");

const day01 = @import("day01.zig");

pub fn main() !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Day 1\nPart 1: {}\nPart 2: {}\n\n", .{ try day01.solve_part1(), try day01.solve_part2() });

    try bw.flush();
}

test {
    std.testing.refAllDecls(@This());

    _ = day01;
}
