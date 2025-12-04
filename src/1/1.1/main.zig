const std = @import("std");

const start = 50;
const total = 100;

pub fn main() !void {
    var debug_allocator: std.heap.DebugAllocator(.{}) = .init;
    const gpa = debug_allocator.allocator();

    var point: u32 = start;
    var zeroCount: u32 = 0;

    var inputFile = try std.fs.cwd().openFile("input.txt", .{});
    defer inputFile.close();

    const fileStat = try inputFile.stat();

    var buffer: [256]u8 = [_]u8{0} ** 256;
    var fileReader = inputFile.reader(&buffer);
    const inputContent = try fileReader.interface.readAlloc(gpa, fileStat.size);
    defer gpa.free(inputContent);

    var i: u32 = 0;
    while (true) {
        // std.log.debug("{d}", .{inputContent[i]});
        switch (inputContent[i]) {
            'R' => {
                i += 1;
                const start_i = i;
                while (inputContent[i] != '\n') {
                    i += 1;
                }
                const dis = std.fmt.parseInt(u32, inputContent[start_i..i], 10) catch unreachable;
                // std.log.debug("R{d}", .{dis});
                R(&point, dis);
                std.log.debug("R point {d}", .{point});
                i += 1;
            },
            'L' => {
                i += 1;
                const start_i = i;
                while (inputContent[i] != '\n') {
                    i += 1;
                }
                const dis = std.fmt.parseInt(u32, inputContent[start_i..i], 10) catch unreachable;
                // std.log.debug("L{d}", .{dis});
                L(&point, dis);
                std.log.debug("L point {d}", .{point});
                i += 1;
            },
            else => {
                std.log.debug("i:{d}, c:{d}", .{ i, inputContent[i] });
                unreachable;
            },
        }

        if (point == 0) {
            zeroCount += 1;
        }

        if (i >= inputContent.len) {
            break;
        }
    }

    std.log.debug("zero count: {d}", .{zeroCount});
}

fn L(point: *u32, dis: u32) void {
    var temp = dis;
    if (dis >= point.*) {
        temp -= point.*;
        point.* = 0;

        const mod = temp % total;
        point.* = total - mod;
        if (point.* == total) {
            point.* = 0;
        }
    } else {
        point.* -= dis;
    }
}

fn R(point: *u32, dis: u32) void {
    var temp = dis;
    if (dis + point.* >= total) {
        temp -= total - point.*;
        point.* = 0;

        const mod = temp % total;
        point.* = mod;
    } else {
        point.* += dis;

        if (point.* == total) {
            point.* = 0;
        }
    }
}

test "a" {
    var point: u32 = 0;
    L(&point, 3);
    std.debug.assert(point == 97);
    R(&point, 4);
    std.debug.assert(point == 1);

    L(&point, 51);
    std.debug.assert(point == 50);
    R(&point, 50);
    std.debug.assert(point == 0);
}
