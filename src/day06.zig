const std = @import("std");

pub const input = @embedFile("input/day06.txt");
const test_input1 = @embedFile("input/day06_test1.txt");
const test_input2 = @embedFile("input/day06_test2.txt");
const test_input3 = @embedFile("input/day06_test3.txt");
const test_input4 = @embedFile("input/day06_test4.txt");
const test_input5 = @embedFile("input/day06_test5.txt");

const CharSet = std.StaticBitSet(26);

fn ascii_to_bit(char: u8) error{InvalidChar}!u8 {
    return switch (char) {
        'a'...'z' => char - 'a',
        else => error.InvalidChar,
    };
}

fn find_unique_marker(comptime length: usize, line: []const u8) !?usize {
    var right: usize = length;
    while (right < line.len) : (right += 1) {
        var charset = CharSet.initEmpty();
        var left: usize = right - length;
        while (left < right) : (left += 1) {
            charset.set(try ascii_to_bit(line[left]));
        }
        if (charset.count() == length) {
            return right;
        }
    }
    return null;
}

pub fn solve_part1(data: []const u8) !usize {
    var line = std.mem.trimRight(u8, data, "\n");
    return (try find_unique_marker(4, line)).?;
}

pub fn solve_part2(data: []const u8) !usize {
    var line = std.mem.trimRight(u8, data, "\n");
    return (try find_unique_marker(14, line)).?;
}

test "solves part1" {
    try std.testing.expectEqual(solve_part1(test_input1), 7);
    try std.testing.expectEqual(solve_part1(test_input2), 5);
    try std.testing.expectEqual(solve_part1(test_input3), 6);
    try std.testing.expectEqual(solve_part1(test_input4), 10);
    try std.testing.expectEqual(solve_part1(test_input5), 11);
}

test "solves part2" {
    try std.testing.expectEqual(solve_part2(test_input1), 19);
    try std.testing.expectEqual(solve_part2(test_input2), 23);
    try std.testing.expectEqual(solve_part2(test_input3), 23);
    try std.testing.expectEqual(solve_part2(test_input4), 29);
    try std.testing.expectEqual(solve_part2(test_input5), 26);
}
