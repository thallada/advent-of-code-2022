const std = @import("std");

pub const input = @embedFile("input/day11.txt");
const test_input1 = @embedFile("input/day11_test1.txt");

var gpa = std.heap.GeneralPurposeAllocator(.{ .safety = true }){};
const allocator = gpa.allocator();

const Op = enum {
    Add,
    Mult,
    fn from_char(char: u8) error{InvalidChar}!Op {
        return switch (char) {
            '+' => Op.Add,
            '*' => Op.Mult,
            else => error.InvalidChar,
        };
    }
};

const Operation = struct {
    op: Op,
    value: ?u8,
};

const Monkey = struct {
    num: u8,
    items: std.ArrayList(usize),
    operation: Operation,
    div_test: u8,
    true_monkey: u8,
    false_monkey: u8,
    inspect_count: usize,
    fn parse(data: []const u8) !Monkey {
        var lines = std.mem.tokenize(u8, data, "\n");
        var num_line = lines.next().?;
        num_line = std.mem.trimRight(u8, num_line, ":");
        const num = try std.fmt.parseInt(u8, num_line[7..], 10);
        const items_line = lines.next().?;
        var items_input = std.mem.tokenize(u8, items_line[18..], ", ");
        var items = std.ArrayList(usize).init(allocator);
        while (items_input.next()) |item| {
            try items.append(try std.fmt.parseInt(usize, item, 10));
        }
        const op_line = lines.next().?;
        const op = try Op.from_char(op_line[23]);
        const value = if (std.mem.eql(u8, op_line[25..], "old")) null else try std.fmt.parseInt(u8, op_line[25..], 10);
        const div_test = try std.fmt.parseInt(u8, lines.next().?[21..], 10);
        const true_monkey = try std.fmt.parseInt(u8, lines.next().?[29..], 10);
        const false_monkey = try std.fmt.parseInt(u8, lines.next().?[30..], 10);
        return Monkey{
            .num = num,
            .items = items,
            .operation = Operation{
                .op = op,
                .value = value,
            },
            .div_test = div_test,
            .true_monkey = true_monkey,
            .false_monkey = false_monkey,
            .inspect_count = 0,
        };
    }
};

fn inspect_and_throw_items(monkeys: *std.ArrayList(Monkey), index: usize, div_3: bool, common_divisor: ?usize) !void {
    var monkey = monkeys.items[index];
    // std.debug.print("Monkey {d}\n", .{monkey.num});
    var i: usize = 0;
    while (monkeys.items[index].items.items.len > 0) : (i += 1) {
        var item = monkeys.items[index].items.pop();
        // std.debug.print("  Monkey inspects an item with a worry level of {d}\n", .{item});
        switch (monkey.operation.op) {
            Op.Add => {
                if (monkey.operation.value) |value| {
                    item += @intCast(usize, value);
                    // std.debug.print("    Worry level is added by {d} to {d}\n", .{ value, item });
                } else {
                    item += item;
                    // std.debug.print("    Worry level is added by old to {d}\n", .{item});
                }
            },
            Op.Mult => {
                if (monkey.operation.value) |value| {
                    item *= @intCast(usize, value);
                    // std.debug.print("    Worry level is multiplied by {d} to {d}\n", .{ value, item });
                } else {
                    item *= item;
                    // std.debug.print("    Worry level is multiplied by old to {d}\n", .{item});
                }
            },
        }
        if (div_3) item /= 3;
        if (common_divisor) |divisor| item = item % divisor;
        // std.debug.print("    Monkey gets bored with item. Worry level is divided by 3 to {d}\n", .{item});
        if (item % monkey.div_test == 0) {
            // std.debug.print("    Current worry level is divisible by {d}\n", .{monkey.div_test});
            try monkeys.items[monkey.true_monkey].items.append(item);
            // std.debug.print("    Item with worry level {d} is thrown to monkey {d}\n", .{ item, monkey.true_monkey });
        } else {
            // std.debug.print("    Current worry level is not divisible by {d}\n", .{monkey.div_test});
            try monkeys.items[monkey.false_monkey].items.append(item);
            // std.debug.print("    Item with worry level {d} is thrown to monkey {d}\n", .{ item, monkey.false_monkey });
        }
        monkeys.items[index].inspect_count += 1;
    }
}

fn calc_monkey_business(monkeys: *std.ArrayList(Monkey)) !usize {
    var inspect_counts = std.ArrayList(usize).init(allocator);
    var m: usize = 0;
    while (m < monkeys.items.len) : (m += 1) {
        try inspect_counts.append(monkeys.items[m].inspect_count);
    }
    var sorted_inspect_counts = try inspect_counts.toOwnedSlice();
    std.sort.sort(usize, sorted_inspect_counts, {}, std.sort.desc(usize));

    return sorted_inspect_counts[0] * sorted_inspect_counts[1];
}

pub fn solve_part1(data: []const u8) !usize {
    var monkey_inputs = std.mem.split(u8, data, "\n\n");
    var monkeys = std.ArrayList(Monkey).init(allocator);
    while (monkey_inputs.next()) |monkey| {
        try monkeys.append(try Monkey.parse(monkey));
    }

    var round: usize = 0;
    while (round < 20) : (round += 1) {
        var m: usize = 0;
        while (m < monkeys.items.len) : (m += 1) {
            try inspect_and_throw_items(&monkeys, m, true, null);
        }
    }

    return calc_monkey_business(&monkeys);
}

pub fn solve_part2(data: []const u8) !usize {
    var monkey_inputs = std.mem.split(u8, data, "\n\n");
    var monkeys = std.ArrayList(Monkey).init(allocator);
    while (monkey_inputs.next()) |monkey| {
        try monkeys.append(try Monkey.parse(monkey));
    }

    var common_divisor: usize = 1;
    for (monkeys.items) |monkey| {
        common_divisor *= monkey.div_test;
    }

    var round: usize = 0;
    while (round < 10_000) : (round += 1) {
        var m: usize = 0;
        while (m < monkeys.items.len) : (m += 1) {
            try inspect_and_throw_items(&monkeys, m, false, common_divisor);
        }
    }

    return calc_monkey_business(&monkeys);
}

test "solves part1" {
    try std.testing.expectEqual(solve_part1(test_input1), 10605);
}

test "solves part2" {
    try std.testing.expectEqual(solve_part2(test_input1), 2713310158);
}
