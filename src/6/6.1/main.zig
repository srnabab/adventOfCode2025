const std = @import("std");

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

    var i: usize = inputContent.len - 2;
    const calCount = blk: {
        var count: u32 = 0;
        while (true) {
            switch (inputContent[i]) {
                '*' => {
                    count += 1;
                },
                '+' => {
                    count += 1;
                },
                '\n' => {
                    break :blk count;
                },
                ' ' => {},
                else => unreachable,
            }
            i -= 1;
        }
    };

    const end = i;

    var signs = try gpa.alloc(bool, calCount);
    defer gpa.free(signs);

    var j: usize = 0;
    for (inputContent[i + 1 ..]) |c| {
        if (c == '*') {
            signs[j] = true;
            j += 1;
        } else if (c == '+') {
            signs[j] = false;
            j += 1;
        } else if (c == ' ') {
            continue;
        } else if (c == '\n') {
            break;
        }
    }

    var ress = try gpa.alloc(u64, calCount);
    defer gpa.free(ress);

    @memset(ress, 0);

    i = 0;
    var col: u32 = 0;
    while (true) {
        switch (inputContent[i]) {
            '0'...'9' => {
                const start_i = i;
                while (inputContent[i] != ' ' and inputContent[i] != '\n') {
                    i += 1;
                }

                if (signs[col]) {
                    if (ress[col] == 0) {
                        ress[col] = 1;
                    }
                    ress[col] *= std.fmt.parseInt(u64, inputContent[start_i..i], 10) catch |err| {
                        std.log.debug("err {s}", .{@errorName(err)});
                        for (inputContent[start_i..i]) |value| {
                            std.log.debug("{d}", .{value});
                        }
                        unreachable;
                    };
                } else {
                    ress[col] += std.fmt.parseInt(u64, inputContent[start_i..i], 10) catch |err| {
                        std.log.debug("err {s} \n{s}", .{ @errorName(err), inputContent[start_i..i] });
                        for (inputContent[start_i..i]) |value| {
                            std.log.debug("{d}", .{value});
                        }
                        unreachable;
                    };
                }

                col += 1;

                if (inputContent[i] == '\n') {
                    col = 0;
                }

                i += 1;
            },
            ' ' => {
                i += 1;
            },
            '\n' => {
                col = 0;
                i += 1;
            },
            else => unreachable,
        }
        // std.log.debug("{d}", .{inputContent[i]});

        if (i >= end) {
            break;
        }
    }

    var total: u64 = 0;
    for (ress) |value| {
        total += value;
    }

    std.log.debug("total: {d}", .{total});
}
