const std = @import("std");

pub const input = @embedFile("input/day09.txt");
const test_input1 = @embedFile("input/day09_test1.txt");

var gpa = std.heap.GeneralPurposeAllocator(.{ .safety = true }){};
const allocator = gpa.allocator();

pub fn solve_part1(data: []const u8) !usize {
    var lines = std.mem.tokenize(u8, data, "\n");
    var visited = std.AutoHashMap([2]isize, void).init(allocator);
    var head = [2]isize{ 0, 0 };
    var tail = [2]isize{ 0, 0 };
    try visited.put(tail, {});
    while (lines.next()) |line| {
        const direction = line[0];
        const steps = try std.fmt.parseInt(u8, line[2..], 10);
        // std.debug.print("{s} {d}\n", .{ [_]u8{direction}, steps });
        var step: usize = 0;
        while (step < steps) : (step += 1) {
            // std.debug.print("move head: {s}\n", .{[_]u8{direction}});
            switch (direction) {
                'R' => {
                    head[0] += 1;
                },
                'L' => {
                    head[0] -= 1;
                },
                'U' => {
                    head[1] -= 1;
                },
                'D' => {
                    head[1] += 1;
                },
                else => unreachable,
            }
            var x_diff = tail[0] - head[0];
            var y_diff = tail[1] - head[1];
            // std.debug.print("x_diff: {d}\n", .{x_diff});
            // std.debug.print("y_diff: {d}\n", .{y_diff});
            if (x_diff < -1 or x_diff > 1 or y_diff < -1 or y_diff > 1) {
                if (x_diff < 0) {
                    // std.debug.print("move tail x: {d}\n", .{-1});
                    tail[0] += 1;
                } else if (x_diff > 0) {
                    // std.debug.print("move tail x: {d}\n", .{1});
                    tail[0] -= 1;
                }
                if (y_diff < 0) {
                    // std.debug.print("move tail y: {d}\n", .{-1});
                    tail[1] += 1;
                } else if (y_diff > 0) {
                    // std.debug.print("move tail y: {d}\n", .{1});
                    tail[1] -= 1;
                }
                try visited.put(tail, {});
            }
            // std.debug.print("head: {d}\n", .{head});
            // std.debug.print("tail: {d}\n", .{tail});
        }
    }
    return visited.count();
}

pub fn solve_part2(data: []const u8) !usize {
    _ = data;
    return 0;
}

test "solves part1" {
    try std.testing.expectEqual(solve_part1(test_input1), 13);
}

test "solves part2" {
    try std.testing.expectEqual(solve_part2(test_input1), 0);
}
