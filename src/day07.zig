const std = @import("std");

pub const input = @embedFile("input/day07.txt");
const test_input = @embedFile("input/day07_test1.txt");

var gpa = std.heap.GeneralPurposeAllocator(.{ .safety = true }){};
const allocator = gpa.allocator();

const Dir = struct {
    name: []const u8,
    saved_size: ?usize,
    parent: ?*Dir,
    dirs: std.StringHashMap(*Dir),
    file_size: usize,
    fn new(name: []const u8, parent: ?*Dir) !*Dir {
        const dir = try allocator.create(Dir);
        dir.* = Dir{
            .name = name,
            .saved_size = null,
            .parent = parent,
            .dirs = std.StringHashMap(*Dir).init(allocator),
            .file_size = 0,
        };
        return dir;
    }
    fn size(self: Dir) usize {
        if (self.saved_size) |s| return s;

        var total = self.file_size;
        var dir_iter = self.dirs.valueIterator();
        while (dir_iter.next()) |dir| {
            total += dir.*.size();
        }
        return total;
    }
    fn sum_sizes_lte(self: Dir, size_limit: usize) usize {
        var sum: usize = if (self.size() <= size_limit) self.size() else 0;
        var dir_iter = self.dirs.valueIterator();
        while (dir_iter.next()) |dir| {
            sum += dir.*.sum_sizes_lte(size_limit);
        }
        return sum;
    }
    fn find_smallest_size_gte(self: Dir, size_limit: usize) ?usize {
        var smallest_size = if (self.size() >= size_limit) self.size() else null;
        var dir_iter = self.dirs.valueIterator();
        while (dir_iter.next()) |dir| {
            if (dir.*.find_smallest_size_gte(size_limit)) |child_size| {
                if (smallest_size) |current_size| {
                    if (child_size < current_size) {
                        smallest_size = child_size;
                    }
                } else {
                    smallest_size = child_size;
                }
            }
        }
        return smallest_size;
    }
};

fn build_dir_tree(commands: []const u8) !*Dir {
    var lines = std.mem.tokenize(u8, commands, "\n");
    _ = lines.next(); // first line is always `cd /`
    var root = try Dir.new("/", null);
    var current_dir = root;
    while (lines.next()) |line| {
        if (std.mem.eql(u8, line[0..1], "$")) {
            if (std.mem.eql(u8, line[2..4], "cd")) {
                if (std.mem.eql(u8, line[5..], "..")) {
                    current_dir = current_dir.parent.?;
                } else {
                    if (current_dir.dirs.get(line[5..])) |dir| {
                        current_dir = dir;
                    } else {
                        var new_dir = try Dir.new(line[5..], current_dir);
                        try current_dir.dirs.put(line[5..], new_dir);
                        current_dir = new_dir;
                    }
                }
            }
        } else {
            var output_parts = std.mem.tokenize(u8, line, " ");
            const dir_or_size = output_parts.next().?;
            if (std.mem.eql(u8, dir_or_size, "dir")) {
                const name = output_parts.next().?;
                var new_dir = try Dir.new(name, current_dir);
                try current_dir.dirs.put(name, new_dir);
            } else {
                const size = try std.fmt.parseInt(usize, dir_or_size, 10);
                current_dir.file_size += size;
            }
        }
    }
    return root;
}

pub fn solve_part1(data: []const u8) !usize {
    const root = try build_dir_tree(data);
    return root.sum_sizes_lte(100000);
}

pub fn solve_part2(data: []const u8) !usize {
    const root = try build_dir_tree(data);
    const space_needed = 30000000 - (70000000 - root.size());
    return root.find_smallest_size_gte(space_needed).?;
}

test "solves part1" {
    try std.testing.expectEqual(solve_part1(test_input), 95437);
}

test "solves part2" {
    try std.testing.expectEqual(solve_part2(test_input), 24933642);
}
