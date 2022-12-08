const std = @import("std");

pub const input = @embedFile("input/day08.txt");
const test_input1 = @embedFile("input/day08_test1.txt");

var gpa = std.heap.GeneralPurposeAllocator(.{ .safety = true }){};
const allocator = gpa.allocator();

const MAX_X = 99;
const MAX_Y = 99;

const Grid = struct {
    grid: [MAX_Y][MAX_X]u8,
    fn new() Grid {
        return Grid{
            .grid = [_][MAX_X]u8{[_]u8{0} ** MAX_X} ** MAX_Y,
        };
    }
    fn is_tree_visible(self: Grid, size: usize, x: usize, y: usize) bool {
        const height = self.grid[y][x];
        // std.debug.print("testing: {d}, {d}: {d}\n", .{ x, y, height });
        var up_y = y - 1;
        while (true) : (up_y -= 1) {
            if (self.grid[up_y][x] >= height) {
                // std.debug.print("up_y fail: {d}, {d}: {d}\n", .{ x, up_y, height });
                break;
            }
            if (up_y == 0) return true;
        }
        var left_x = x - 1;
        while (true) : (left_x -= 1) {
            if (self.grid[y][left_x] >= height) {
                // std.debug.print("left_x fail: {d}, {d}: {d}\n", .{ left_x, y, height });
                break;
            }
            if (left_x == 0) return true;
        }
        var down_y = y + 1;
        while (down_y < size) : (down_y += 1) {
            if (self.grid[down_y][x] >= height) {
                // std.debug.print("down_y fail: {d}, {d}: {d}\n", .{ x, down_y, height });
                break;
            }
            if (down_y == size - 1) return true;
        }
        var right_x = x + 1;
        while (right_x < size) : (right_x += 1) {
            if (self.grid[y][right_x] >= height) {
                // std.debug.print("right_x fail: {d}, {d}: {d}\n", .{ right_x, y, height });
                break;
            }
            if (right_x == size - 1) return true;
        }
        return false;
    }
};

pub fn solve_part1(data: []const u8) !usize {
    var lines = std.mem.tokenize(u8, data, "\n");
    var grid = Grid.new();
    var size: usize = 0;
    var y: usize = 0;
    while (lines.next()) |line| : (y += 1) {
        var x: usize = 0;
        size = line.len;
        std.debug.print("line.len: {d}\n", .{line.len});
        while (x < line.len) : (x += 1) {
            const height = try std.fmt.parseInt(u8, line[x .. x + 1], 10);
            grid.grid[y][x] = height;
        }
    }

    var count: usize = (size * 4) - 4;
    std.debug.print("count: {d}\n", .{count});
    y = 1;
    while (y < size - 1) : (y += 1) {
        var x: usize = 1;
        while (x < size - 1) : (x += 1) {
            if (grid.is_tree_visible(size, x, y)) {
                count += 1;
            }
        }
    }
    return count;
}

pub fn solve_part2(data: []const u8) !usize {
    var lines = std.mem.tokenize(u8, data, "\n");
    _ = lines;
    return 0;
}

test "solves part1" {
    try std.testing.expectEqual(solve_part1(test_input1), 21);
}

test "solves part2" {
    try std.testing.expectEqual(solve_part2(test_input1), 0);
}
