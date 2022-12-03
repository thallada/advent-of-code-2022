const std = @import("std");

pub const input = @embedFile("input/day03.txt");
const test_input = @embedFile("input/day03_test1.txt");

fn ascii_to_priority(char: u8) error{InvalidChar}!u8 {
    if (char >= 97 and char <= 122) {
        return char - 96;
    } else if (char >= 65 and char <= 90) {
        return char - 64 + 26;
    } else {
        return error.InvalidChar;
    }
}

const PrioritySet = std.StaticBitSet(26 * 2 + 1);

pub fn solve_part1(data: []const u8) !usize {
    var lines = std.mem.split(u8, data, "\n");
    var sum: usize = 0;
    while (lines.next()) |line| {
        if (std.mem.eql(u8, line, "")) break;
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
    var lines = std.mem.split(u8, data, "\n");
    var sum: usize = 0;
    var i: usize = 0;
    var group = [3]PrioritySet{ PrioritySet.initEmpty(), PrioritySet.initEmpty(), PrioritySet.initEmpty() };
    while (i < 3) {
        const line = lines.next().?;
        if (std.mem.eql(u8, line, "")) break;

        var j: usize = 0;
        while (j < line.len) : (j += 1) {
            group[i].set(try ascii_to_priority(line[j]));
        }

        if (i == 2) {
            group[0].setIntersection(group[1]);
            group[0].setIntersection(group[2]);
            const priority = group[0].findFirstSet().?;
            sum += priority;

            i = 0;
            group = [3]PrioritySet{ PrioritySet.initEmpty(), PrioritySet.initEmpty(), PrioritySet.initEmpty() };
            continue;
        }

        i += 1;
    }
    return sum;
}

test "solves part1" {
    try std.testing.expectEqual(solve_part1(test_input), 157);
}

test "solves part2" {
    try std.testing.expectEqual(solve_part2(test_input), 70);
}
