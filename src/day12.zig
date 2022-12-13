const std = @import("std");

pub const input = @embedFile("input/day12.txt");
const test_input1 = @embedFile("input/day12_test1.txt");

var gpa = std.heap.GeneralPurposeAllocator(.{ .safety = true }){};
const allocator = gpa.allocator();

const MAX_X = 159;
const MAX_Y = 41;

const PathNode = struct {
    position: [2]u8,
    f_score: usize,
    g_score: usize,
    parent: ?*PathNode,
};

fn h_score(a: [2]u8, b: [2]u8) !usize {
    return std.math.sqrt(std.math.pow(usize, @intCast(usize, try std.math.absInt(@intCast(i16, a[0]) - @intCast(i16, b[0]))), 2) +
        std.math.pow(usize, @intCast(usize, try std.math.absInt(@intCast(i16, a[1]) - @intCast(i16, b[1]))), 2));
}

fn lowest_f(context: void, a: *PathNode, b: *PathNode) std.math.Order {
    _ = context;
    return std.math.order(a.f_score, b.f_score);
}

const Grid = struct {
    grid: [MAX_Y][MAX_X]u8,
    max_x: usize,
    max_y: usize,
    start: [2]u8,
    end: [2]u8,
    fn new() Grid {
        return Grid{ .grid = [_][MAX_X]u8{[_]u8{0} ** MAX_X} ** MAX_Y, .max_x = MAX_X, .max_y = MAX_Y, .start = [2]u8{ 0, 0 }, .end = [2]u8{ 0, 0 } };
    }
    fn parse(data: []const u8) !Grid {
        var grid = Grid.new();
        var lines = std.mem.tokenize(u8, data, "\n");
        var y: u8 = 0;
        while (lines.next()) |line| : (y += 1) {
            var x: u8 = 0;
            grid.max_x = line.len;
            while (x < line.len) : (x += 1) {
                var height = line[x];
                if (height == 'S') {
                    grid.start = [2]u8{ y, x };
                    height = 'a';
                } else if (height == 'E') {
                    grid.end = [2]u8{ y, x };
                    height = 'z';
                }
                grid.grid[y][x] = height;
            }
        }
        grid.max_y = y;
        return grid;
    }
    fn a_star(self: Grid) !usize {
        var open_list = std.PriorityQueue(*PathNode, void, lowest_f).init(allocator, {});
        var open_g_scores = std.AutoHashMap([2]u8, usize).init(allocator);
        var closed_list = std.AutoHashMap([2]u8, void).init(allocator);
        var start = try allocator.create(PathNode);
        start.* = PathNode{ .position = self.start, .g_score = 0, .f_score = 0, .parent = null };
        try open_list.add(start);
        while (open_list.count() != 0) {
            var current_node = open_list.remove();
            var current = current_node.position;
            _ = open_g_scores.remove(current);
            var current_height = self.grid[current[0]][current[1]];
            try closed_list.put(current, {});

            if (std.mem.eql(u8, &current, &self.end)) {
                // try self.print_path(current_node);
                return current_node.g_score;
            }

            const neighbors = [4][2]i16{
                [2]i16{ -1, 0 },
                [2]i16{ 1, 0 },
                [2]i16{ 0, -1 },
                [2]i16{ 0, 1 },
            };

            var i: u8 = 0;
            while (i < neighbors.len) : (i += 1) {
                if ((neighbors[i][0] == -1 and current[0] > 0) or
                    (neighbors[i][0] == 1 and current[0] < MAX_Y - 1) or
                    (neighbors[i][1] == -1 and current[1] > 0) or
                    (neighbors[i][1] == 1 and current[1] < MAX_X - 1))
                {
                    var neighbor = [2]u8{ @intCast(u8, @intCast(i16, current[0]) + neighbors[i][0]), @intCast(u8, @intCast(i16, current[1]) + neighbors[i][1]) };
                    if (!closed_list.contains(neighbor) and self.grid[neighbor[0]][neighbor[1]] <= current_height + 1) {
                        var g = current_node.g_score + 1;

                        if (!open_g_scores.contains(neighbor) or open_g_scores.get(neighbor).? < g) {
                            var h = try h_score(neighbor, self.end);
                            var f = g + h;

                            var node = try allocator.create(PathNode);
                            node.* = PathNode{ .position = neighbor, .g_score = g, .f_score = f, .parent = current_node };
                            try open_list.add(node);
                            try open_g_scores.put(neighbor, g);
                        }
                    }
                }
            }
        }
        return 0;
    }
    fn print_path(self: Grid, end_node: *PathNode) !void {
        var path = std.AutoHashMap([2]u8, u8).init(allocator);
        var node = end_node;
        while (node.parent) |parent| {
            var char: u8 = '#';
            if (node.position[0] < parent.position[0]) {
                char = '^';
            } else if (node.position[0] > parent.position[0]) {
                char = 'v';
            } else if (node.position[1] < parent.position[1]) {
                char = '<';
            } else if (node.position[1] > parent.position[1]) {
                char = '>';
            }
            try path.put(node.position, char);
            node = parent;
        }

        var y: u8 = 0;
        while (y < MAX_Y) : (y += 1) {
            var x: u8 = 0;
            while (x < MAX_X) : (x += 1) {
                var char = self.grid[y][x];
                if (path.get([2]u8{ y, x })) |path_char| {
                    char = path_char;
                }
                std.debug.print("{s}", .{[_]u8{char}});
            }
            std.debug.print("\n", .{});
        }
    }
};

pub fn solve_part1(data: []const u8) !usize {
    var grid = try Grid.parse(data);
    return grid.a_star();
}

pub fn solve_part2(data: []const u8) !usize {
    var grid = try Grid.parse(data);
    var min_score: ?usize = null;
    var y: u8 = 0;
    while (y < grid.max_y) : (y += 1) {
        grid.start = [2]u8{ y, 0 };
        const score = try grid.a_star();
        if (min_score) |min| {
            if (score < min) {
                min_score = score;
            }
        } else {
            min_score = score;
        }
    }
    return min_score.?;
}

test "solves part1" {
    try std.testing.expectEqual(solve_part1(test_input1), 31);
}

test "solves part2" {
    try std.testing.expectEqual(solve_part2(test_input1), 29);
}
