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
    _ = calCount;

    const len = inputContent.len - i - 1;
    // std.log.debug("len {d}", .{len});

    // std.log.debug("{d}", .{inputContent[3731]});

    var mul = false;
    var string: [4]u8 = [_]u8{0} ** 4;
    var res: u64 = 0;
    var total: u64 = 0;
    for (inputContent[i + 1 ..], 0..) |c, idx| {
        // std.log.debug("idx {d}", .{idx});
        if (c == '*') {
            mul = true;
            var s: usize = idx;
            var z: usize = 0;
            while (inputContent[s] == ' ') {
                s += len;
            }

            if (res == 0) {
                res = 1;
            }

            while (inputContent[s] != ' ' and inputContent[s] != '*' and inputContent[s] != '+') {
                string[z] = inputContent[s];
                s += len;
                z += 1;
            }

            res *= std.fmt.parseInt(u64, string[0..z], 10) catch unreachable;
            // std.log.debug("{s}", .{string[0..z]});
        } else if (c == '+') {
            mul = false;
            var s: usize = idx;
            var z: usize = 0;
            while (inputContent[s] == ' ') {
                s += len;
            }

            while (inputContent[s] != ' ' and inputContent[s] != '*' and inputContent[s] != '+') {
                string[z] = inputContent[s];
                s += len;
                z += 1;
            }

            res += std.fmt.parseInt(u64, string[0..z], 10) catch unreachable;
            // std.log.debug("{s}", .{string[0..z]});
        } else if (c == ' ' or c == '\n') {
            if (c == '\n') {
                total += res;
                // std.log.debug("{dif ()c==

                res = 0;
                break;
            }

            if (mul) {
                var s: usize = idx;
                var z: usize = 0;
                var t: usize = 0;
                while (inputContent[s] == ' ') {
                    s += len;

                    t += 1;

                    if (t >= 4) {
                        total += res;
                        // std.log.debug("{d}", .{res});
                        res = 0;

                        break;
                    }
                }

                while (inputContent[s] != ' ' and inputContent[s] != '*' and inputContent[s] != '+') {
                    string[z] = inputContent[s];
                    s += len;
                    z += 1;
                }

                if (z != 0) {
                    res *= std.fmt.parseInt(u64, string[0..z], 10) catch unreachable;
                    // std.log.debug("{s}", .{string[0..z]});
                }
            } else {
                var s: usize = idx;
                var z: usize = 0;
                var t: usize = 0;
                while (inputContent[s] == ' ') {
                    s += len;
                    t += 1;

                    if (t >= 4) {
                        total += res;
                        // std.log.debug("{d}", .{res});
                        res = 0;
                        break;
                    }
                }

                while (inputContent[s] != ' ' and inputContent[s] != '*' and inputContent[s] != '+') {
                    string[z] = inputContent[s];
                    s += len;
                    z += 1;
                }

                if (z != 0) {
                    res += std.fmt.parseInt(u64, string[0..z], 10) catch unreachable;
                    // std.log.debug("{s}", .{string[0..z]});
                }
            }
        }
    }

    std.log.debug("total: {d}", .{total});
}
