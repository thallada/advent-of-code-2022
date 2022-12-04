const std = @import("std");

pub const input = @embedFile("input/day04.txt");
const test_input = @embedFile("input/day04_test1.txt");

const Range = struct {
    start: usize,
    end: usize,
    fn parse(str: []const u8) !Range {
        var range_parts = std.mem.tokenize(u8, str, "-");
        const range = Range{
            .start = try std.fmt.parseInt(usize, range_parts.next().?, 10),
            .end = try std.fmt.parseInt(usize, range_parts.next().?, 10),
        };
        return range;
    }
    fn contains(self: Range, other: Range) bool {
        return (other.start >= self.start and other.end <= self.end);
    }
    fn overlaps(self: Range, other: Range) bool {
        return (self.start <= other.end and self.end >= other.start);
    }
};

pub fn solve_part1(data: []const u8) !usize {
    var lines = std.mem.tokenize(u8, data, "\n");
    var count: usize = 0;
    while (lines.next()) |line| {
        var elves = std.mem.tokenize(u8, line, ",");
        const range1 = try Range.parse(elves.next().?);
        const range2 = try Range.parse(elves.next().?);
        if (range1.contains(range2) or range2.contains(range1)) count += 1;
    }
    return count;
}

pub fn solve_part2(data: []const u8) !usize {
    var lines = std.mem.tokenize(u8, data, "\n");
    var count: usize = 0;
    while (lines.next()) |line| {
        var elves = std.mem.tokenize(u8, line, ",");
        const range1 = try Range.parse(elves.next().?);
        const range2 = try Range.parse(elves.next().?);
        if (range1.overlaps(range2)) count += 1;
    }
    return count;
}

test "solves part1" {
    try std.testing.expectEqual(solve_part1(test_input), 2);
}

test "solves part2" {
    try std.testing.expectEqual(solve_part2(test_input), 4);
}
