const std = @import("std");

pub const input = @embedFile("input/day09.txt");
const test_input1 = @embedFile("input/day09_test1.txt");
const test_input2 = @embedFile("input/day09_test2.txt");

var gpa = std.heap.GeneralPurposeAllocator(.{ .safety = true }){};
const allocator = gpa.allocator();

fn move_rope(comptime S: usize, knots: *[S][2]isize, line: []const u8, visited: *std.AutoHashMap([2]isize, void)) !void {
    const direction = line[0];
    const steps = try std.fmt.parseInt(u8, line[2..], 10);
    var step: usize = 0;
    while (step < steps) : (step += 1) {
        switch (direction) {
            'R' => {
                knots[0][0] += 1;
            },
            'L' => {
                knots[0][0] -= 1;
            },
            'U' => {
                knots[0][1] -= 1;
            },
            'D' => {
                knots[0][1] += 1;
            },
            else => unreachable,
        }

        var i: usize = 1;
        while (i < knots.len) : (i += 1) {
            var x_diff = knots[i][0] - knots[i - 1][0];
            var y_diff = knots[i][1] - knots[i - 1][1];
            if (x_diff < -1 or x_diff > 1 or y_diff < -1 or y_diff > 1) {
                if (x_diff < 0) {
                    knots[i][0] += 1;
                } else if (x_diff > 0) {
                    knots[i][0] -= 1;
                }
                if (y_diff < 0) {
                    knots[i][1] += 1;
                } else if (y_diff > 0) {
                    knots[i][1] -= 1;
                }
                if (i == knots.len - 1) try visited.put(knots[i], {});
            }
        }
    }
}

pub fn solve_part1(data: []const u8) !usize {
    var lines = std.mem.tokenize(u8, data, "\n");
    var visited = std.AutoHashMap([2]isize, void).init(allocator);
    var knots = [2][2]isize{ [2]isize{ 0, 0 }, [2]isize{ 0, 0 } };
    try visited.put(knots[0], {});
    while (lines.next()) |line| {
        try move_rope(2, &knots, line, &visited);
    }
    return visited.count();
}

pub fn solve_part2(data: []const u8) !usize {
    var lines = std.mem.tokenize(u8, data, "\n");
    var visited = std.AutoHashMap([2]isize, void).init(allocator);
    var knots = [_][2]isize{[_]isize{ 0, 0 }} ** 10;
    try visited.put(knots[0], {});
    while (lines.next()) |line| {
        try move_rope(10, &knots, line, &visited);
    }
    return visited.count();
}

test "solves part1" {
    try std.testing.expectEqual(solve_part1(test_input1), 13);
}

test "solves part2" {
    try std.testing.expectEqual(solve_part2(test_input1), 1);
    try std.testing.expectEqual(solve_part2(test_input2), 36);
}
