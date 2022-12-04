const std = @import("std");

pub const input = @embedFile("input/day03.txt");
const test_input = @embedFile("input/day03_test1.txt");

const PrioritySet = std.StaticBitSet(26 * 2 + 1);
const EmptyGroup = [3]PrioritySet{ PrioritySet.initEmpty(), PrioritySet.initEmpty(), PrioritySet.initEmpty() };

fn ascii_to_priority(char: u8) error{InvalidChar}!u8 {
    return switch (char) {
        'a'...'z' => char - 'a' + 1,
        'A'...'Z' => char - 'A' + 27,
        else => error.InvalidChar,
    };
}

pub fn solve_part1(data: []const u8) !usize {
    var lines = std.mem.tokenize(u8, data, "\n");
    var sum: usize = 0;
    while (lines.next()) |line| {
        var compartment1 = PrioritySet.initEmpty();
        var compartment2 = PrioritySet.initEmpty();
        var i: usize = 0;
        while (i < line.len) : (i += 1) {
            const priority = try ascii_to_priority(line[i]);
            if (i < line.len / 2) {
                compartment1.set(priority);
            } else {
                compartment2.set(priority);
            }
        }
        compartment1.setIntersection(compartment2);
        sum += compartment1.findFirstSet().?;
    }
    return sum;
}

pub fn solve_part2(data: []const u8) !usize {
    var lines = std.mem.tokenize(u8, data, "\n");
    var sum: usize = 0;
    var i: usize = 0;
    var group = EmptyGroup;
    while (i < 3) : (i = (i + 1) % 3) {
        const line = lines.next() orelse break;

        for (line) |item| group[i].set(try ascii_to_priority(item));

        if (i == 2) {
            group[0].setIntersection(group[1]);
            group[0].setIntersection(group[2]);
            const priority = group[0].findFirstSet().?;
            sum += priority;

            group = EmptyGroup;
        }
    }
    return sum;
}

test "ascii_to_priority" {
    try std.testing.expectEqual(ascii_to_priority('a'), 1);
    try std.testing.expectEqual(ascii_to_priority('z'), 26);
    try std.testing.expectEqual(ascii_to_priority('A'), 27);
    try std.testing.expectEqual(ascii_to_priority('Z'), 52);
}

test "solves part1" {
    try std.testing.expectEqual(solve_part1(test_input), 157);
}

test "solves part2" {
    try std.testing.expectEqual(solve_part2(test_input), 70);
}
