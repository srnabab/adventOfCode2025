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

    var i: u32 = 0;
    var total: u32 = 0;
    while (true) {
        switch (inputContent[i]) {
            '1'...'9' => {
                var ten: u8 = inputContent[i];
                var one: u8 = 0;
                var old_ten: u8 = 0;
                i += 1;

                while (inputContent[i] != '\n') {
                    if (inputContent[i] > ten) {
                        old_ten = ten;
                        ten = inputContent[i];
                        one = 0;
                    } else if (inputContent[i] > one) {
                        one = inputContent[i];
                    }
                    i += 1;
                }
                i += 1;

                if (one == 0) {
                    one = ten;
                    ten = old_ten;
                }

                var num: [2]u8 = .{ ten, one };
                total += std.fmt.parseInt(u32, &num, 10) catch unreachable;
            },
            else => {
                std.debug.panic("invalid input", .{});
            },
        }
        if (i == inputContent.len) {
            break;
        }
    }

    std.log.debug("total {d}", .{total});
}
