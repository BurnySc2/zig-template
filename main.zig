const std = @import("std");
const ArrayList = std.ArrayList;
const expect = std.testing.expect;
const print = std.debug.print;
const eql = std.mem.eql;
const meta = std.meta;
const Vector = meta.Vector;
const len = std.mem.len;
const test_allocator = std.testing.allocator;

pub fn main() void {
    print("Hello, {s}!\n", .{"World"});

    const string = [_]u8{ 'a', 'b', 'c' };
    for (string) |character, index| {
        print("Counting: {d}!\n", .{character});
    }
}

// Export functions
export fn add(a: i32, b: i32) i32 {
    return a + b;
}

// Private functions
fn fibonacci(n: u16) u16 {
    if (n == 0 or n == 1) {
        return n;
    }
    return fibonacci(n - 1) + fibonacci(n - 2);
}

fn failingFunction() error{Oops}!void {
    return error.Oops;
}

fn failFn() error{Oops}!i32 {
    try failingFunction();
    return 12;
}
var problems: u32 = 98;

fn failFnCounter() error{Oops}!void {
    errdefer problems += 1;
    try failingFunction();
}

fn total(values: []const u8) usize {
    var count: usize = 0;
    for (values) |v| count += v;
    return count;
}

fn rangeHasNumber(begin: usize, end: usize, number: usize) bool {
    var i = begin;
    return while (i < end) : (i += 1) {
        if (i == number) {
            break true;
        }
    } else false;
}

fn ticker(step: u8) void {
    while (true) {
        std.time.sleep(1 * std.time.ns_per_s);
        tick += @as(isize, step);
    }
}

// Structs
const Stuff = struct {
    x: i32,
    y: i32,
    fn swap(self: *Stuff) void {
        const tmp = self.x;
        self.x = self.y;
        self.y = tmp;
    }
};

const Place = struct { lat: f32, long: f32 };

// Tests
test "if statement" {
    const a = true;
    var x: u16 = 0;
    if (a) {
        x += 1;
    } else {
        x += 2;
    }
    expect(x == 1);
}

test "while" {
    var i: u8 = 2;
    while (i < 100) {
        i *= 2;
    }
    expect(i == 128);
}

test "while with continue expression" {
    var sum: u8 = 0;
    var i: u8 = 1;
    while (i <= 10) : (i += 1) {
        sum += i;
    }
    expect(sum == 55);
}

test "for" {
    //character literals are equivalent to integer literals
    const string = [_]u8{ 'a', 'b', 'c' };

    for (string) |character, index| {
        expect(character == index + 97);
    }

    for (string) |character| {}

    for (string) |_, index| {}

    for (string) |_| {}
}

test "function recursion" {
    const x = fibonacci(10);
    expect(x == 55);
}

test "defer" {
    var x: i16 = 5;
    {
        // defer is executed when exiting the block
        defer x += 2;
        expect(x == 5);
    }
    expect(x == 7);
}

test "multi defer" {
    var x: f32 = 5;
    {
        // defers are executed in reverse order
        defer x += 2;
        defer x /= 2;
    }
    expect(x == 4.5);
}

test "try" {
    var v = failFn() catch |err| {
        expect(err == error.Oops);
        return;
    };
    expect(v == 12); // is never reached
}

test "errdefer" {
    failFnCounter() catch |err| {
        expect(err == error.Oops);
        expect(problems == 99);
        return;
    };
}

test "switch statement" {
    var x: i8 = 10;
    switch (x) {
        -1...1 => {
            x = -x;
        },
        10, 100 => {
            //special considerations must be made
            //when dividing signed integers
            x = @divExact(x, 10);
        },
        else => {},
    }
    expect(x == 1);
}

test "switch expression" {
    var x: i8 = 10;
    x = switch (x) {
        -1...1 => -x,
        10, 100 => @divExact(x, 10),
        else => x,
    };
    expect(x == 1);
}

test "out of bounds, no safety" {
    @setRuntimeSafety(false);
    const a = [3]u8{ 1, 2, 3 };
    var index: u8 = 5;
    const b = a[index];
}

test "slices" {
    const array = [_]u8{ 1, 2, 3, 4, 5 };
    const slice = array[0..3];
    expect(total(slice) == 6);
}

test "slices 2" {
    const array = [_]u8{ 1, 2, 3, 4, 5 };
    const slice = array[0..3];
    expect(@TypeOf(slice) == *const [3]u8);
}

test "slices 3" {
    var array = [_]u8{ 1, 2, 3, 4, 5 };
    var slice = array[2..];
    expect(total(slice) == 12);
}

test "automatic dereference" {
    var thing = Stuff{ .x = 10, .y = 20 };
    thing.swap();
    expect(thing.x == 20);
    expect(thing.y == 10);
}

test "integer widening" {
    const a: u8 = 250;
    const b: u16 = a;
    const c: u32 = b;
    expect(c == a);
}

test "@intCast" {
    const x: u64 = 200;
    const y = @intCast(u8, x);
    expect(@TypeOf(y) == u8);
}

test "well defined overflow" {
    var a: u8 = 255;
    a +%= 1;
    expect(a == 0);
}

test "float widening" {
    const a: f16 = 0;
    const b: f32 = a;
    const c: f128 = b;
    expect(c == @as(f128, a));
}

test "int-float conversion" {
    const a: i32 = 0;
    const b = @intToFloat(f32, a);
    const c = @floatToInt(i32, b);
    expect(c == a);
    expect(@TypeOf(c) == @TypeOf(a));
}

// Labelled loops
test "nested continue" {
    var count: usize = 0;
    outer: for ([_]i32{ 1, 2, 3, 4, 5, 6, 7, 8 }) |_| {
        for ([_]i32{ 1, 2, 3, 4, 5 }) |_| {
            count += 1;
            continue :outer;
        }
    }
    expect(count == 8);
}

test "while loop expression" {
    expect(rangeHasNumber(0, 10, 3));
}

test "optional" {
    var found_index: ?usize = null;
    const data = [_]i32{ 1, 2, 3, 4, 5, 6, 7, 8, 12 };
    for (data) |v, i| {
        if (v == 10) found_index = i;
    }
    expect(found_index == null);
}

test "orelse" {
    var a: ?f32 = null;
    var b = a orelse 0;
    expect(b == 0);
    expect(@TypeOf(b) == f32);
}

// Executed at compile time
test "comptime blocks" {
    var x = comptime fibonacci(10);

    var y = comptime blk: {
        break :blk fibonacci(10);
    };
}

test "comptime_int" {
    const a = 12;
    const b = a + 10;

    const c: u4 = a;
    const d: f32 = b;
}

test "branching on types" {
    const a = 5;
    const b: if (a < 10) f32 else i32 = 5;
    expect(@TypeOf(b) == f32);
}

// Concatenating arrays
test "++" {
    const x: [4]u8 = undefined;
    const y = x[0..];

    const a: [6]u8 = undefined;
    const b = a[0..];

    const new = y ++ b;
    expect(new.len == 10);
}

// Multiplying / repeating arrays
test "**" {
    const pattern = [_]u8{ 0xCC, 0xAA };
    const memory = pattern ** 3;
    expect(eql(u8, &memory, &[_]u8{ 0xCC, 0xAA, 0xCC, 0xAA, 0xCC, 0xAA }));
}

// Compile time loop unrolling
test "inline for" {
    const types = [_]type{ i32, f32, u8, bool };
    var sum: usize = 0;
    inline for (types) |T| sum += @sizeOf(T);
    expect(sum == 10);

    var sum2: u32 = 0;
    const some_array = [5]u8{ 1, 2, 3, 4, 5 };
    inline for (some_array) |i| sum2 += i;
    expect(sum2 == 15);
}

// No struct type defined
test "anonymous struct literal" {
    const Point = struct { x: i32, y: i32 };

    var pt: Point = .{
        .x = 13,
        .y = 67,
    };
    expect(pt.x == 13);
    expect(pt.y == 67);
}

test "string literal" {
    expect(@TypeOf("hello") == *const [5:0]u8);
}

test "C string" {
    const c_string: [*:0]const u8 = "hello";
    var array: [5]u8 = undefined;

    var i: usize = 0;
    while (c_string[i] != 0) : (i += 1) {
        array[i] = c_string[i];
    }
}

test "vector add" {
    const x: Vector(4, f32) = .{ 1, -10, 20, -1 };
    const y: Vector(4, f32) = .{ 2, 10, 0, 1 };
    const z = x + y;
    expect(meta.eql(z, Vector(4, f32){ 3, 0, 20, 0 }));
}

test "vector indexing" {
    const x: Vector(4, u8) = .{ 255, 0, 255, 0 };
    expect(x[0] == 255);
}

test "vector * scalar" {
    const x: Vector(3, f32) = .{ 12.5, 37.5, 2.5 };
    const y = x * @splat(3, @as(f32, 2));
    expect(meta.eql(y, Vector(3, f32){ 25, 75, 5 }));
}

test "vector looping" {
    const x = Vector(4, u8){ 255, 0, 255, 0 };
    var sum = blk: {
        var tmp: u10 = 0;
        var i: u8 = 0;
        while (i < len(x)) : (i += 1) tmp += x[i];
        break :blk tmp;
    };
    expect(sum == 510);
}

test "vector coercing" {
    const arr: [4]f32 = @Vector(4, f32){ 1, 2, 3, 4 };
}

test "json parse" {
    var stream = std.json.TokenStream.init(
        \\{ "lat": 40.684540, "long": -74.401422 }
    );
    const x = try std.json.parse(Place, &stream, .{});

    expect(x.lat == 40.684540);
    expect(x.long == -74.401422);
}

test "json stringify" {
    const x = Place{
        .lat = 51.997664,
        .long = -0.740687,
    };

    var buf: [100]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buf);
    var string = std.ArrayList(u8).init(&fba.allocator);
    try std.json.stringify(x, .{}, string.writer());

    expect(eql(u8, string.items,
        \\{"lat":5.19976654e+01,"long":-7.40687012e-01}
    ));
}

test "random numbers" {
    var prng = std.rand.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        try std.os.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });
    const rand = &prng.random;

    const a = rand.float(f32);
    const b = rand.boolean();
    const c = rand.int(u8);
    const d = rand.intRangeAtMost(u8, 0, 255);
}

test "arraylist" {
    // test_allocator only works in tests
    var list = ArrayList(u8).init(test_allocator);
    defer list.deinit();
    try list.append('H');
    try list.append('e');
    try list.append('l');
    try list.append('l');
    try list.append('o');
    try list.appendSlice(" World!");

    expect(eql(u8, list.items, "Hello World!"));
}

test "hash map" {
    const Point = struct { x: i32, y: i32 };

    var map = std.AutoHashMap(u32, Point).init(
        test_allocator,
    );
    defer map.deinit();

    try map.put(1525, .{ .x = 1, .y = -4 });
    try map.put(1550, .{ .x = 2, .y = -3 });
    try map.put(1575, .{ .x = 3, .y = -2 });
    try map.put(1600, .{ .x = 4, .y = -1 });

    expect(map.count() == 4);

    var sum = Point{ .x = 0, .y = 0 };
    var iterator = map.iterator();

    while (iterator.next()) |entry| {
        sum.x += entry.value.x;
        sum.y += entry.value.y;
    }

    expect(sum.x == 10);
    expect(sum.y == -10);
}

test "string hashmap" {
    var map = std.StringHashMap(enum { cool, uncool }).init(
        test_allocator,
    );
    defer map.deinit();

    try map.put("loris", .uncool);
    try map.put("me", .cool);

    expect(map.get("me").? == .cool);
    expect(map.get("loris").? == .uncool);
}

test "stack" {
    const string = "(()())";
    var stack = std.ArrayList(usize).init(
        test_allocator,
    );
    defer stack.deinit();

    const Pair = struct { open: usize, close: usize };
    var pairs = std.ArrayList(Pair).init(
        test_allocator,
    );
    defer pairs.deinit();

    for (string) |char, i| {
        if (char == '(') try stack.append(i);
        if (char == ')')
            try pairs.append(.{
                .open = stack.pop(),
                .close = i,
            });
    }

    for (pairs.items) |pair, i| {
        expect(std.meta.eql(pair, switch (i) {
            0 => Pair{ .open = 1, .close = 2 },
            1 => Pair{ .open = 3, .close = 4 },
            2 => Pair{ .open = 0, .close = 5 },
            else => unreachable,
        }));
    }
}

test "sorting" {
    var data = [_]u8{ 10, 240, 0, 0, 10, 5 };
    std.sort.sort(u8, &data, {}, comptime std.sort.asc(u8));
    expect(eql(u8, &data, &[_]u8{ 0, 0, 5, 10, 10, 240 }));
    std.sort.sort(u8, &data, {}, comptime std.sort.desc(u8));
    expect(eql(u8, &data, &[_]u8{ 240, 10, 10, 5, 0, 0 }));
}

// Errors

//test "out of bounds" {
//    const a = [3]u8{ 1, 2, 3 };
//    var index: u8 = 5;
//    const b = a[index];
//}

//test "unreachable" {
//    const x: i32 = 1;
//    const y: u32 = if (x == 2) 5 else unreachable;
//}
