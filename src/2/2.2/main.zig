const std = @import("std");

const range = struct {
    start: []u8,
    end: []u8,
};

const range2 = struct {
    start: u64,
    end: u64,
    digits: usize,
};

var map: std.AutoHashMap(u64, void) = undefined;

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

    map = .init(gpa);
    defer map.deinit();

    var total: u64 = 0;
    for (ranges.items) |value| {
        std.log.debug("{s}-{s}", .{ value.start, value.end });

        var range2s = [_]range2{.{
            .start = 0,
            .end = 0,
            .digits = 0,
        }} ** 2;
        var range2sCount: u32 = 0;
        if (value.start.len >= 12 or value.end.len >= 12) {
            std.debug.panic("digits too big", .{});
        }
        if (value.start.len != value.end.len) {
            range2s[0] = .{
                .start = std.fmt.parseInt(u64, value.start, 10) catch unreachable,
                .end = std.math.pow(u64, 10, value.start.len) - 1,
                .digits = value.start.len,
            };
            range2s[1] = .{
                .start = std.math.pow(u64, 10, value.start.len),
                .end = std.fmt.parseInt(u64, value.end, 10) catch unreachable,
                .digits = value.end.len,
            };
            range2sCount = 2;
        } else {
            range2s[0] = .{
                .start = std.fmt.parseInt(u64, value.start, 10) catch unreachable,
                .end = std.fmt.parseInt(u64, value.end, 10) catch unreachable,
                .digits = value.start.len,
            };
            range2sCount = 1;
        }
        for (0..range2sCount) |j| {
            var c1: u64 = 0;
            var c2: u64 = 0;
            var c3: u64 = 0;
            var c4: u64 = 0;
            var c5: u64 = 0;

            if (range2s[j].digits != 1) {
                c1 = cal1(range2s[j]);
                total += c1;
            }
            // std.log.debug("c1 {d}", .{c1});
            if (range2s[j].digits != 2 and range2s[j].digits % 2 == 0) {
                c2 = cal2(range2s[j]);
                // std.log.debug("c2 {d}", .{c2});
                total += c2;
                total -= c1;
            }
            if (range2s[j].digits != 3 and range2s[j].digits % 3 == 0) {
                c3 = cal3(range2s[j]);
                // std.log.debug("c3 {d}", .{c3});
                total += c3;
                total -= c1;
            }
            if (range2s[j].digits != 4 and range2s[j].digits % 4 == 0) {
                c4 = cal4(range2s[j]);
                // std.log.debug("c4 {d}", .{c4});
                total += c4;
                total -= c2;
            }
            if (range2s[j].digits != 5 and range2s[j].digits % 5 == 0) {
                c5 = cal5(range2s[j]);
                // std.log.debug("c5 {d}", .{c5});
                total += c5;
                total -= c1;
            }
        }
    }

    var keyIt = map.keyIterator();
    while (keyIt.next()) |key| {
        total += key.*;
        // std.log.debug("{d}", .{key.*});
    }

    std.log.debug("total {d}", .{total});
}
fn cal1(value: range2) u64 {
    const pow_of_10 = std.math.pow(u64, 10, value.digits - 1);
    const base = blk: {
        var v: u64 = 0;
        for (0..value.digits) |_| {
            v *= 10;
            v += 1;
        }
        break :blk v;
    };

    var start = value.start / pow_of_10;
    if (base * start < value.start) {
        start += 1;
    }

    var end = value.end / pow_of_10;
    if (base * end > value.end) {
        end -= 1;
    }

    if (end < start) {
        return 0;
    }

    for (start..end + 1) |v| {
        std.log.debug("{d}", .{v * base});
        map.put(v * base, void{}) catch unreachable;
    }

    return 0;
    // return (start + end) * (end - start + 1) * base / 2;
}
fn cal2(value: range2) u64 {
    const pow_of_10 = std.math.pow(u64, 10, value.digits - 2);
    const base = blk: {
        const loop: usize = value.digits / 2;
        var v: u64 = 0;
        for (0..loop) |_| {
            v *= 100;
            v += 1;
        }
        break :blk v;
    };

    var start = value.start / pow_of_10;
    if (base * start < value.start) {
        start += 1;
    }

    var end = value.end / pow_of_10;
    if (base * end > value.end) {
        end -= 1;
    }

    if (end < start) {
        return 0;
    }

    for (start..end + 1) |v| {
        map.put(v * base, void{}) catch unreachable;
    }

    return 0;
    // return (start + end) * (end - start + 1) * base / 2;
}
fn cal3(value: range2) u64 {
    const pow_of_10 = std.math.pow(u64, 10, value.digits - 3);
    const base = blk: {
        const loop: usize = value.digits / 3;
        var v: u64 = 0;
        for (0..loop) |_| {
            v *= 1000;
            v += 1;
        }
        break :blk v;
    };

    var start = value.start / pow_of_10;
    if (base * start < value.start) {
        start += 1;
    }

    var end = value.end / pow_of_10;
    if (base * end > value.end) {
        end -= 1;
    }

    // std.log.debug("start {d}, end {d}", .{ start, end });
    if (end < start) {
        return 0;
    }

    for (start..end + 1) |v| {
        map.put(v * base, void{}) catch unreachable;
    }

    return 0;
    // return (start + end) * (end - start + 1) * base / 2;
}
fn cal4(value: range2) u64 {
    const pow_of_10 = std.math.pow(u64, 10, value.digits - 4);
    const base = blk: {
        const loop: usize = value.digits / 4;
        var v: u64 = 0;
        for (0..loop) |_| {
            v *= 10000;
            v += 1;
        }
        break :blk v;
    };

    var start = value.start / pow_of_10;
    if (base * start < value.start) {
        start += 1;
    }

    var end = value.end / pow_of_10;
    if (base * end > value.end) {
        end -= 1;
    }

    if (end < start) {
        return 0;
    }

    for (start..end + 1) |v| {
        map.put(v * base, void{}) catch unreachable;
    }

    return 0;
    // return (start + end) * (end - start + 1) * base / 2;
}
fn cal5(value: range2) u64 {
    const pow_of_10 = std.math.pow(u64, 10, value.digits - 5);
    const base = blk: {
        const loop: usize = value.digits / 5;
        var v: u64 = 0;
        for (0..loop) |_| {
            v *= 100000;
            v += 1;
        }
        break :blk v;
    };

    var start = value.start / pow_of_10;
    if (base * start < value.start) {
        start += 1;
    }

    var end = value.end / pow_of_10;
    if (base * end > value.end) {
        end -= 1;
    }

    if (end < start) {
        return 0;
    }

    for (start..end + 1) |v| {
        map.put(v * base, void{}) catch unreachable;
    }

    return 0;
    // return (start + end) * (end - start + 1) * base / 2;
}
