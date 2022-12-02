const std = @import("std");

pub const input = @embedFile("input/day02.txt");
const test_input = @embedFile("input/day02_test1.txt");

var gpa = std.heap.GeneralPurposeAllocator(.{ .safety = true }){};
const allocator = gpa.allocator();

const Choice = enum(usize) {
    Rock = 1,
    Paper = 2,
    Scissors = 3,
    fn from_opponent_char(char: u8) Choice {
        return switch (char) {
            'A' => Choice.Rock,
            'B' => Choice.Paper,
            'C' => Choice.Scissors,
            else => @panic("invalid opponent char!"),
        };
    }
    fn from_me_char(char: u8) Choice {
        return switch (char) {
            'X' => Choice.Rock,
            'Y' => Choice.Paper,
            'Z' => Choice.Scissors,
            else => @panic("invalid me char!"),
        };
    }
    fn from_outcome(self: Choice, outcome_char: u8) Choice {
        return switch (outcome_char) {
            'X' => self.lose_choice(),
            'Y' => self,
            'Z' => self.win_choice(),
            else => @panic("invalid outcome char!"),
        };
    }
    fn lose_choice(self: Choice) Choice {
        return switch (self) {
            Choice.Rock => Choice.Scissors,
            Choice.Paper => Choice.Rock,
            Choice.Scissors => Choice.Paper,
        };
    }
    fn win_choice(self: Choice) Choice {
        return switch (self) {
            Choice.Rock => Choice.Paper,
            Choice.Paper => Choice.Scissors,
            Choice.Scissors => Choice.Rock,
        };
    }
    fn beats(self: Choice, other: Choice) bool {
        return if (other.win_choice() == self) true else false;
    }
    fn ties(self: Choice, other: Choice) bool {
        return self == other;
    }
};

pub fn solve_part1(data: []const u8) usize {
    var lines = std.mem.split(u8, data, "\n");
    var score: usize = 0;
    while (lines.next()) |line| {
        if (std.mem.eql(u8, line, "")) break;
        var player_choices = std.mem.split(u8, line, " ");
        var opponent = Choice.from_opponent_char(player_choices.next().?[0]);
        var me = Choice.from_me_char(player_choices.next().?[0]);
        score += @enumToInt(me);
        if (me.beats(opponent)) {
            score += 6;
        } else if (me.ties(opponent)) {
            score += 3;
        }
    }
    return score;
}

pub fn solve_part2(data: []const u8) usize {
    var lines = std.mem.split(u8, data, "\n");
    var score: usize = 0;
    while (lines.next()) |line| {
        if (std.mem.eql(u8, line, "")) break;
        var player_choices = std.mem.split(u8, line, " ");
        var opponent = Choice.from_opponent_char(player_choices.next().?[0]);
        var me = opponent.from_outcome(player_choices.next().?[0]);
        score += @enumToInt(me);
        if (me.beats(opponent)) {
            score += 6;
        } else if (me.ties(opponent)) {
            score += 3;
        }
    }
    return score;
}

test "solves part1" {
    try std.testing.expectEqual(solve_part1(test_input), 15);
}

test "solves part2" {
    try std.testing.expectEqual(solve_part2(test_input), 12);
}
