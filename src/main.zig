const std = @import("std");

pub fn main() void {
    std.debug.print("hello world!!\n", .{});
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);
    const allocator = gpa.allocator();
    var client = std.http.Client{ .allocator = allocator };
    defer client.deinit();

    const uri = std.Uri.parse("https://whatthecommit.com") catch unreachable;

    // var headers = std.http.Headers{ .allocator = allocator };
    var headers = std.http.Header{};
    defer headers.deinit();

    try headers.append("accept", "*/*");
    var request = try client.request(.GET, uri, headers, .{});
    defer request.deinit();

    try request.start();

    try request.wait();

    const body = request.reader().readAllAlloc(allocator, 8192) catch unreachable;
    defer allocator.free(body);

    std.log.info("{s}", .{body});
}
