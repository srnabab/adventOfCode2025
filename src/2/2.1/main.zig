const std = @import("std");

const range = struct {
    start: []u8,
    end: []u8,
};

pub fn main() !void {
    var debug_allocator: std.heap.DebugAllocator(.{}) = .init;
    const gpa = debug_allocator.allocator();

    var inputFile = try std.fs.cwd().openFile("input.txt", .{});
    defer inputFile.close();

    const fileStat = try inputFile.stat();

    var buffer: [256]u8 = [_]u8{0} ** 256;
    var fileReader = inputFile.reader(&buffer);
    const inputContent = try fileReader.interface.readAlloc(gpa, fileStat.size);
    defer gpa.free(inputContent);

    var ranges: std.array_list.Managed(range) = .init(gpa);
    defer ranges.deinit();

    var i: u32 = 0;
    while (true) {
        switch (inputContent[i]) {
            '0'...'9' => {
                var start_i = i;
                const range1 = try ranges.addOne();
                i += 1;
                while (inputContent[i] != '-') {
                    i += 1;
                }
                range1.start = inputContent[start_i..i];

                i += 1;
                start_i = i;
                while (inputContent[i] != ',') {
                    i += 1;
                    if (inputContent[i] == '\n') {
                        break;
                    }
                }
                range1.end = inputContent[start_i..i];
                i += 1;
            },
            else => {
                std.log.debug("i:{d}, c:{d}", .{ i, inputContent[i] });
                unreachable;
            },
        }

        if (i >= inputContent.len) {
            break;
        }
    }

    var total: u64 = 0;
    for (ranges.items) |value| {
        std.log.debug("{s}-{s}", .{ value.start, value.end });
        var digits: usize = 0;

        var start: u64 = 0;
        var end: u64 = 0;
        var half_start: u64 = 0;
        var half_end: u64 = 0;

        if (value.start.len % 2 != 0) {
            digits = 1 + value.start.len;
            start = std.math.pow(u64, 10, value.start.len) + std.math.pow(u64, 10, value.start.len / 2);
            half_start = std.math.pow(u64, 10, value.start.len / 2);
        } else {
            digits = value.start.len;
            start = std.fmt.parseInt(u64, value.start, 10) catch unreachable;
            const half_1 = std.fmt.parseInt(u64, value.start[0 .. value.start.len / 2], 10) catch unreachable;
            const half_2 = std.fmt.parseInt(u64, value.start[value.start.len / 2 ..], 10) catch unreachable;
            if (half_1 > half_2) {
                half_start = half_1;
            } else {
                half_start = half_1 + 1;
            }
        }

        if (digits > value.end.len) {
            continue;
        }
        if (value.end.len % 2 != 0) {
            std.debug.assert(value.end.len - 1 == digits);
            end = std.math.pow(u64, 10, digits) - 1;
            half_end = std.math.pow(u64, 10, digits / 2) - 1;
        } else {
            end = std.fmt.parseInt(u64, value.end, 10) catch unreachable;
            const half_1 = std.fmt.parseInt(u64, value.end[0 .. value.end.len / 2], 10) catch unreachable;
            const half_2 = std.fmt.parseInt(u64, value.end[value.end.len / 2 ..], 10) catch unreachable;
            if (half_1 > half_2) {
                half_end = half_1 - 1;
            } else {
                half_end = half_1;
            }
        }

        // std.log.debug("end {d}, start {d}", .{ half_end, half_start });
        const a = (half_start + half_end) * (half_end - half_start + 1) * (std.math.pow(u64, 10, digits / 2) + 1) / 2;
        total += a;
        std.log.debug("a {d} {d}", .{ a, digits });
        // std.log.debug("total {d}", .{total});
    }

    std.log.debug("total {d}", .{total});
}
