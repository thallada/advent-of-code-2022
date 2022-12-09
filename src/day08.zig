const std = @import("std");

pub const input = @embedFile("input/day08.txt");
const test_input1 = @embedFile("input/day08_test1.txt");

var gpa = std.heap.GeneralPurposeAllocator(.{ .safety = true }){};
const allocator = gpa.allocator();

const MAX_X = 99;
const MAX_Y = 99;

const Grid = struct {
    grid: [MAX_Y][MAX_X]u8,
    size: usize,
    fn new() Grid {
        return Grid{
            .grid = [_][MAX_X]u8{[_]u8{0} ** MAX_X} ** MAX_Y,
            .size = MAX_Y,
        };
    }
    fn parse(data: []const u8) !Grid {
        var grid = Grid.new();
        var lines = std.mem.tokenize(u8, data, "\n");
        var y: usize = 0;
        while (lines.next()) |line| : (y += 1) {
            var x: usize = 0;
            grid.size = line.len;
            while (x < line.len) : (x += 1) {
                const height = try std.fmt.parseInt(u8, line[x .. x + 1], 10);
                grid.grid[y][x] = height;
            }
        }
        return grid;
    }
    fn is_tree_visible(self: Grid, x: usize, y: usize) bool {
        const height = self.grid[y][x];
        var up_y = y - 1;
        while (true) : (up_y -= 1) {
            if (self.grid[up_y][x] >= height) {
                break;
            }
            if (up_y == 0) return true;
        }
        var left_x = x - 1;
        while (true) : (left_x -= 1) {
            if (self.grid[y][left_x] >= height) {
                break;
            }
            if (left_x == 0) return true;
        }
        var down_y = y + 1;
        while (down_y < self.size) : (down_y += 1) {
            if (self.grid[down_y][x] >= height) {
                break;
            }
            if (down_y == self.size - 1) return true;
        }
        var right_x = x + 1;
        while (right_x < self.size) : (right_x += 1) {
            if (self.grid[y][right_x] >= height) {
                break;
            }
            if (right_x == self.size - 1) return true;
        }
        return false;
    }
    fn tree_score(self: Grid, x: usize, y: usize) usize {
        const height = self.grid[y][x];
        var up_y: usize = 1;
        while (y - up_y > 0) : (up_y += 1) {
            if (self.grid[y - up_y][x] >= height) {
                break;
            }
        }
        var left_x: usize = 1;
        while (x - left_x > 0) : (left_x += 1) {
            if (self.grid[y][x - left_x] >= height) {
                break;
            }
        }
        var down_y: usize = 1;
        while (y + down_y < self.size - 1) : (down_y += 1) {
            if (self.grid[y + down_y][x] >= height) {
                break;
            }
        }
        var right_x: usize = 1;
        while (x + right_x < self.size - 1) : (right_x += 1) {
            if (self.grid[y][x + right_x] >= height) {
                break;
            }
        }
        return up_y * left_x * down_y * right_x;
    }
};

pub fn solve_part1(data: []const u8) !usize {
    var grid = try Grid.parse(data);
    var count: usize = (grid.size * 4) - 4;
    var y: usize = 1;
    while (y < grid.size - 1) : (y += 1) {
        var x: usize = 1;
        while (x < grid.size - 1) : (x += 1) {
            if (grid.is_tree_visible(x, y)) {
                count += 1;
            }
        }
    }
    return count;
}

pub fn solve_part2(data: []const u8) !usize {
    var grid = try Grid.parse(data);
    var best_score: usize = 0;
    var y: usize = 1;
    while (y < grid.size - 1) : (y += 1) {
        var x: usize = 1;
        while (x < grid.size - 1) : (x += 1) {
            const score = grid.tree_score(x, y);
            if (score > best_score) {
                best_score = score;
            }
        }
    }
    return best_score;
}

test "solves part1" {
    try std.testing.expectEqual(solve_part1(test_input1), 21);
}

test "solves part2" {
    try std.testing.expectEqual(solve_part2(test_input1), 8);
}
