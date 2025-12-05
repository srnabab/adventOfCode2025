const std = @import("std");

const digit = 12;

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

    var len: u32 = 0;
    for (inputContent, 0..) |v, i| {
        if (v == '\n') {
            len = @intCast(i);
            break;
        }
    }

    var i: u32 = 0;
    var total: u64 = 0;
    while (true) {
        var num_list: [10]std.array_list.Managed(u32) = [_]std.array_list.Managed(u32){.init(gpa)} ** 10;
        defer for (num_list) |v| v.deinit();

        var num_list_start: [10]u32 = [_]u32{0} ** 10;

        var currentBiggest: u32 = 0;
        var num: [12]u8 = [_]u8{0} ** 12;
        var num_index: [12]u32 = [_]u32{0} ** 12;
        var index: u32 = 0;

        var remain: u32 = len;
        var need: u32 = digit;

        var last_index: u32 = 0;

        while (remain >= need) {
            switch (inputContent[i]) {
                '1'...'9' => {
                    num_list[inputContent[i] - 48].append(i) catch unreachable;

                    currentBiggest = @max(currentBiggest, inputContent[i] - 48);

                    for (num_list[inputContent[i] - 48].items[num_list_start[inputContent[i] - 48]..], num_list_start[inputContent[i] - 48]..) |value, vi| {
                        if (value > last_index) {
                            num_list_start[inputContent[i] - 48] = @intCast(vi);
                            // std.log.debug("ji {d}, vi {d}, value {d}, innerBiggest {d}", .{ ji, vi, value, innerBiggest });
                            break;
                        }
                    }
                },
                else => unreachable,
            }
            remain -= 1;
            i += 1;

            if (remain < need) {
                var innerBiggest: u32 = 0;
                num_index[index] = num_list[currentBiggest].items[num_list_start[currentBiggest]];
                last_index = num_index[index];
                // std.log.debug("{d}, {d}", .{ num_index[index], currentBiggest });

                for (num_list[1..], 1..) |*j, ji| {
                    for (j.items[num_list_start[ji]..], num_list_start[ji]..) |value, vi| {
                        if (value > num_index[index]) {
                            num_list_start[ji] = @intCast(vi);
                            innerBiggest = @max(innerBiggest, @as(u32, @intCast(ji)));
                            // std.log.debug("ji {d}, vi {d}, value {d}, innerBiggest {d}", .{ ji, vi, value, innerBiggest });
                            break;
                        }
                    }
                }

                index += 1;
                need -= 1;
                currentBiggest = innerBiggest;
                // std.log.debug("need {d} {d}\n", .{ need, currentBiggest });

                if (need == 0 or index == 12) {
                    break;
                }
            }
        }

        for (num_index, 0..) |c, j| {
            num[j] = inputContent[c];
        }
        // std.log.debug("{s}", .{num});
        i += 1;

        total += std.fmt.parseInt(u64, &num, 10) catch unreachable;

        if (i == inputContent.len) {
            break;
        }
    }

    std.log.debug("total {d}", .{total});
}
