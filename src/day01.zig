const std = @import("std");

pub const input = @embedFile("input/day01.txt");
const test_input = @embedFile("input/day01_test1.txt");

var gpa = std.heap.GeneralPurposeAllocator(.{ .safety = true }){};
const allocator = gpa.allocator();

pub fn solve_part1(data: []const u8) !usize {
    var lines = std.mem.split(u8, data, "\n");
    var largest_calories: usize = 0;
    var calories: usize = 0;
    while (lines.next()) |line| {
        if (std.mem.eql(u8, line, "")) {
            calories = 0;
        } else {
            calories += try std.fmt.parseInt(usize, line, 10);
        }

        if (calories > largest_calories) {
            largest_calories = calories;
        }
    }
    return largest_calories;
}

pub fn solve_part2(data: []const u8) !usize {
    var lines = std.mem.split(u8, data, "\n");
    var elves = std.ArrayList(usize).init(allocator);
    defer elves.deinit();
    var calories: usize = 0;
    while (lines.next()) |line| {
        if (std.mem.eql(u8, line, "")) {
            try elves.append(calories);
            calories = 0;
        } else {
            calories += try std.fmt.parseInt(usize, line, 10);
        }
    }

    var elves_slice = elves.toOwnedSlice();
    defer allocator.free(elves_slice);
    std.sort.sort(usize, elves_slice, {}, comptime std.sort.desc(usize));
    return elves_slice[0] + elves_slice[1] + elves_slice[2];
}

test "solves part1" {
    try std.testing.expectEqual(solve_part1(test_input), 24000);
}

test "solves part2" {
    try std.testing.expectEqual(solve_part2(test_input), 45000);
}
