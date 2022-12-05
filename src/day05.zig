const std = @import("std");

pub const input = @embedFile("input/day05.txt");
const test_input = @embedFile("input/day05_test1.txt");

var gpa = std.heap.GeneralPurposeAllocator(.{ .safety = true }){};
const allocator = gpa.allocator();

const Stack = std.SinglyLinkedList(u8);

fn print_stacks(stacks: []Stack) void {
    var i: usize = 0;
    for (stacks) |stack| {
        std.debug.print("{}: ", .{i + 1});
        print_stack(stack);
        i += 1;
    }
}

fn print_stack(stack: Stack) void {
    if (stack.first) |first| {
        print_node(first);
    } else {
        std.debug.print("<empty>\n", .{});
    }
}

fn print_node(node: *Stack.Node) void {
    std.debug.print("{s}", .{&[_]u8{node.data}});
    if (node.next) |next| {
        std.debug.print(" -> ", .{});
        print_node(next);
    } else {
        std.debug.print("\n", .{});
    }
}

fn parse_stacks(lines: *std.mem.TokenIterator(u8)) ![9]Stack {
    // TODO: is there a better way to initialize this?
    var stacks: [9]Stack = [9]Stack{
        Stack{},
        Stack{},
        Stack{},
        Stack{},
        Stack{},
        Stack{},
        Stack{},
        Stack{},
        Stack{},
    };
    while (lines.next()) |line| {
        var i: usize = 0;
        while (i < line.len) : (i += 4) {
            const slot = line[i .. i + 3];
            if (slot[0] == '[') {
                const first = stacks[i / 4].first;
                if (first) |f| {
                    var new_node = try allocator.create(Stack.Node);
                    new_node.* = Stack.Node{ .data = slot[1] };
                    f.findLast().insertAfter(new_node);
                } else {
                    var new_node = try allocator.create(Stack.Node);
                    new_node.* = Stack.Node{ .data = slot[1] };
                    stacks[i / 4].prepend(new_node);
                }
            }
        }
    }
    return stacks;
}

const Move = struct {
    crates: usize,
    from: usize,
    to: usize,
};

fn parse_move(line: []const u8) !Move {
    var parts = std.mem.tokenize(u8, line, " ");
    _ = parts.next();
    const crates = try std.fmt.parseInt(usize, parts.next().?, 10);
    _ = parts.next();
    const from = try std.fmt.parseInt(usize, parts.next().?, 10);
    _ = parts.next();
    const to = try std.fmt.parseInt(usize, parts.next().?, 10);
    return Move{
        .crates = crates,
        .from = from - 1,
        .to = to - 1,
    };
}

fn get_top_crate_str(stacks: [9]Stack) ![]const u8 {
    var message = std.ArrayList(u8).init(allocator);
    var i: usize = 0;
    while (i < 9) : (i += 1) {
        if (stacks[i].first) |first| {
            try message.append(first.data);
        }
    }
    return message.toOwnedSlice();
}

pub fn solve_part1(data: []const u8) ![]const u8 {
    var lines = std.mem.split(u8, data, "\n\n");

    var stack_lines = std.mem.tokenize(u8, lines.next().?, "\n");
    var stacks = try parse_stacks(&stack_lines);

    var move_lines = std.mem.tokenize(u8, lines.next().?, "\n");
    while (move_lines.next()) |line| {
        const move = try parse_move(line);

        var i: usize = 0;
        while (i < move.crates) : (i += 1) {
            const crate = stacks[move.from].popFirst().?;
            stacks[move.to].prepend(crate);
        }
    }

    return try get_top_crate_str(stacks);
}

pub fn solve_part2(data: []const u8) ![]const u8 {
    var lines = std.mem.split(u8, data, "\n\n");

    var stack_lines = std.mem.tokenize(u8, lines.next().?, "\n");
    var stacks = try parse_stacks(&stack_lines);

    var move_lines = std.mem.tokenize(u8, lines.next().?, "\n");
    while (move_lines.next()) |line| {
        const move = try parse_move(line);

        // print_stacks(&stacks);
        var i: usize = 0;
        var temp = Stack{};
        while (i < move.crates) : (i += 1) {
            const crate = stacks[move.from].popFirst().?;
            const first = temp.first;
            if (first) |f| {
                f.findLast().insertAfter(crate);
            } else {
                temp.prepend(crate);
            }
            // print_stack(temp);
        }
        if (stacks[move.to].first) |to_first| {
            temp.first.?.findLast().next = to_first;
        }
        stacks[move.to].first = temp.first;
    }

    return try get_top_crate_str(stacks);
}

test "solves part1" {
    try std.testing.expectEqualStrings(try solve_part1(test_input), "CMZ");
}

test "solves part2" {
    try std.testing.expectEqualStrings(try solve_part2(test_input), "MCD");
}
