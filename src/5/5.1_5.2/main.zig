const std = @import("std");

const range = struct {
    const Self = @This();

    start: u64 = 0,
    end: u64 = 0,
    next: ?*Self = null,
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

    var ranges: std.heap.MemoryPoolExtra(range, .{}) = .init(gpa);
    defer ranges.deinit();
    var head: ?*range = null;

    var smallest: u64 = std.math.maxInt(u64);
    var largest: u64 = 0;

    var i: usize = 0;
    var repeat_n = false;
    while (true) {
        switch (inputContent[i]) {
            '0'...'9' => {
                repeat_n = false;

                const start = i;
                while (inputContent[i] != '-') {
                    i += 1;
                }

                const range1 = try ranges.create();
                range1.* = .{};
                range1.start = std.fmt.parseInt(u64, inputContent[start..i], 10) catch unreachable;

                i += 1;

                smallest = @min(smallest, range1.start);

                const end = i;
                while (inputContent[i] != '\n') {
                    i += 1;
                }
                repeat_n = true;

                range1.end = std.fmt.parseInt(u64, inputContent[end..i], 10) catch unreachable;

                i += 1;

                largest = @max(largest, range1.end);

                if (head == null) {
                    head = range1;
                } else {
                    var last = head;
                    var prev: ?*range = null;
                    var insert = false;
                    while (last) |v| {
                        if (range1.start < v.start and range1.end < v.start) {
                            range1.next = v;

                            if (prev == null) {
                                head = range1;
                            } else {
                                prev.?.next = range1;
                            }

                            insert = true;
                            break;
                        } else if (range1.start < v.start and range1.end + 1 >= v.start and range1.end <= v.end) {
                            v.start = range1.start;
                            insert = true;
                            break;
                        } else if (range1.start >= v.start and range1.end >= v.end and range1.start < v.end) {
                            v.end = range1.end;

                            var next = v.next;
                            while (next) |n| {
                                if (v.end + 1 >= n.start and v.end <= n.end) {
                                    v.end = n.end;
                                    v.next = n.next;
                                    break;
                                } else if (v.end + 1 >= n.start and v.end > n.end) {
                                    v.next = n.next;
                                    next = n.next;
                                    continue;
                                } else {
                                    break;
                                }
                            }

                            insert = true;
                            break;
                        } else if (range1.start >= v.start and range1.end <= v.end) {
                            insert = true;
                            break;
                        } else if (range1.start < v.start and range1.end > v.end) {
                            v.start = range1.start;
                            v.end = range1.end;

                            var next = v.next;
                            while (next) |n| {
                                if (v.end + 1 >= n.start and v.end <= n.end) {
                                    v.end = n.end;
                                    v.next = n.next;
                                    break;
                                } else if (v.end + 1 >= n.start and v.end > n.end) {
                                    v.next = n.next;
                                    next = n.next;
                                    continue;
                                } else {
                                    break;
                                }
                            }

                            insert = true;
                            break;
                        }

                        prev = v;
                        last = v.next;
                    }

                    if (!insert) {
                        if (prev) |v| {
                            v.next = range1;
                        } else {
                            head.?.next = range1;
                        }
                    }
                }
            },
            '\n' => {
                if (repeat_n) {
                    i += 1;
                    break;
                }
                repeat_n = true;
            },
            else => unreachable,
        }
    }

    var numList: std.array_list.Managed(u64) = .init(gpa);
    defer numList.deinit();

    while (true) {
        switch (inputContent[i]) {
            '0'...'9' => {
                const start = i;
                while (inputContent[i] != '\n') {
                    i += 1;
                }
                const v = std.fmt.parseInt(u64, inputContent[start..i], 10) catch unreachable;
                i += 1;
                try numList.append(v);
            },
            else => unreachable,
        }

        if (i >= inputContent.len) {
            break;
        }
    }

    // std.log.debug("small: {d}, large: {d}", .{ smallest, largest });

    var aCount: u64 = 0;
    var count: u64 = 0;

    var last = head;
    while (last) |v| {
        // std.log.debug("{d}-{d}", .{ v.start, v.end });
        // count += v.end - v.start + 1;

        if (v.next) |n| {
            std.debug.assert(v.end <= n.start);
            if (v.end + 1 == n.start or v.end == n.start) {
                v.end = n.end;
                v.next = n.next;
            }
        }
        last = v.next;
    }

    last = head;
    while (last) |v| {
        // std.log.debug("{d}-{d}", .{ v.start, v.end });
        count += v.end - v.start + 1;

        last = v.next;
    }

    for (numList.items) |num| {
        var last1 = head;
        while (last1) |v| {
            // std.log.debug("{d}-{d}", .{ v.start, v.end });
            if (num >= v.start and num <= v.end) {
                aCount += 1;
                break;
            }
            // count += v.end - v.start + 1;
            last1 = v.next;
        }
    }
    std.log.debug("part2 {d}, part1 {d}", .{ count, aCount });
}
