const std = @import("std");

const MAX_BYTES = 2048 * 2048;

pub fn read_file(allocator: std.mem.Allocator, filename: []const u8) ![]const u8 {
    const input_file = try std.fs.cwd().openFile(filename, .{ .mode = std.fs.File.OpenMode.read_only });
    defer input_file.close();

    return try input_file.readToEndAlloc(allocator, MAX_BYTES);
}
