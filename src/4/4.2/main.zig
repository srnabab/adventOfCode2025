const std = @import("std");

pub fn main() !void {
    var debug_allocator: std.heap.DebugAllocator(.{}) = .init;
    const gpa = debug_allocator.allocator();

    var inputFile = try std.fs.cwd().openFile("input2.txt", .{});
    defer inputFile.close();

    const fileStat = try inputFile.stat();

    var buffer: [256]u8 = [_]u8{0} ** 256;
    var fileReader = inputFile.reader(&buffer);
    const inputContent = try fileReader.interface.readAlloc(gpa, fileStat.size);
    defer gpa.free(inputContent);

    const width = blk: {
        var i: u32 = 0;
        while (inputContent[i] != '\n') {
            i += 1;
        }
        break :blk i + 2;
    };

    const height = fileStat.size / (width - 1) + 2;

    std.log.debug("{d} {d}", .{ width, height });

    var map = try gpa.alloc(u1, width * height);
    defer gpa.free(map);

    @memset(map, 0);

    const width_start: u32 = 1;
    const height_start: u32 = 1;

    const width_end: u32 = @intCast(width - 2);
    const height_end: u32 = @intCast(height - 2);

    var x: u32 = width_start;
    var y: u32 = height_start;

    for (inputContent) |value| {
        switch (value) {
            '@' => {
                map[y * width + x] = 1;
                x += 1;
            },
            '.' => {
                map[y * width + x] = 0;
                x += 1;
            },
            '\n' => {
                x = width_start;
                y += 1;
            },
            else => unreachable,
        }
    }

    var xs: std.array_list.Managed(u32) = .init(gpa);
    defer xs.deinit();

    var total: usize = 0;
    while (true) {
        for (map[height_start * width + width_start .. height_end * width + width_end + 1], height_start * width + width_start..height_end * width + width_end + 1) |value, i| {
            // std.log.debug("{d} {d}", .{ i, value });
            if (i % width == 0 or i % width == width - 1) {
                continue;
            }
            const avg: u32 = blk: {
                const a: u32 = @intCast(map[i - width]);
                const b: u32 = @intCast(map[i + width]);
                const c: u32 = @intCast(map[i - 1]);
                const d: u32 = @intCast(map[i + 1]);
                const e: u32 = @intCast(map[i - width - 1]);
                const f: u32 = @intCast(map[i - width + 1]);
                const g: u32 = @intCast(map[i + width - 1]);
                const h: u32 = @intCast(map[i + width + 1]);
                break :blk (a + b + c + d + e + f + g + h) / 4;
            };

            if (value == 1 and avg == 0) {
                try xs.append(@intCast(i));
            }
        }
        total += xs.items.len;

        for (xs.items) |value| {
            map[value] = 0;
        }

        if (xs.items.len == 0) {
            break;
        }

        xs.clearRetainingCapacity();
    }

    std.log.debug("count {d}", .{total});
}
