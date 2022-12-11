const std = @import("std");

pub const input = @embedFile("input/day10.txt");
const test_input1 = @embedFile("input/day10_test1.txt");
const test_input2 = @embedFile("input/day10_test2.txt");

fn signal_strength(cycle: usize, x: isize) isize {
    if (cycle == 20 or cycle == 60 or cycle == 100 or cycle == 140 or cycle == 180 or cycle == 220) {
        return @intCast(isize, cycle) * x;
    } else {
        return 0;
    }
}

pub fn solve_part1(data: []const u8) !isize {
    var lines = std.mem.tokenize(u8, data, "\n");
    var x: isize = 1;
    var cycle: usize = 0;
    var sum: isize = 0;
    while (lines.next()) |line| {
        if (std.mem.eql(u8, line, "noop")) {
            cycle += 1;
            sum += signal_strength(cycle, x);
        } else {
            var delta = try std.fmt.parseInt(isize, line[5..], 10);
            cycle += 1;
            sum += signal_strength(cycle, x);
            cycle += 1;
            sum += signal_strength(cycle, x);
            x += delta;
        }
    }
    return sum;
}

fn emit_ray(cycle: usize, x: isize, crt: *[6][40]bool) void {
    if (x >= @mod(@intCast(isize, cycle), 40) - 1 and x <= (cycle % 40) + 1) {
        crt[cycle / 40][cycle % 40] = true;
    }
}

fn print_screen(crt: [6][40]bool) [246]u8 {
    var screen = [_]u8{'.'} ** (6 * 41);
    var row: usize = 0;
    while (row < 6) : (row += 1) {
        var col: usize = 0;
        while (col < 40) : (col += 1) {
            screen[(row * 41) + col] = if (crt[row][col]) '#' else '.';
        }
        screen[(row * 41) + col] = '\n';
    }
    return screen;
}

pub fn solve_part2(data: []const u8) ![246]u8 {
    var lines = std.mem.tokenize(u8, data, "\n");
    var x: isize = 1;
    var cycle: usize = 0;
    var crt = [_][40]bool{[_]bool{false} ** 40} ** 6;
    while (lines.next()) |line| {
        emit_ray(cycle, x, &crt);
        if (std.mem.eql(u8, line, "noop")) {
            cycle += 1;
        } else {
            var delta = try std.fmt.parseInt(isize, line[5..], 10);
            cycle += 1;
            emit_ray(cycle, x, &crt);
            cycle += 1;
            x += delta;
            emit_ray(cycle, x, &crt);
        }
    }
    return print_screen(crt);
}

test "solves part1" {
    try std.testing.expectEqual(solve_part1(test_input2), 13140);
}

test "solves part2" {
    try std.testing.expectEqualStrings(&try solve_part2(test_input2),
        \\##..##..##..##..##..##..##..##..##..##..
        \\###...###...###...###...###...###...###.
        \\####....####....####....####....####....
        \\#####.....#####.....#####.....#####.....
        \\######......######......######......####
        \\#######.......#######.......#######.....
        \\
    );
}
