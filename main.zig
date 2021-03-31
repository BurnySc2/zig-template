const std = @import("std");
const expect = @import("std").testing.expect;
const print = @import("std").debug.print;

pub fn main() void {
    print("Hello, {s}!\n", .{"World"});

    const string = [_]u8{ 'a', 'b', 'c' };
    for (string) |character, index| {
        print("Counting: {d}!\n", .{character});
    }
}

fn fibonacci(n: u16) u16 {
    if (n == 0 or n == 1) {
        return n;
    }
    return fibonacci(n - 1) + fibonacci(n - 2);
}

export fn add(a: i32, b: i32) i32 {
    return a + b;
}

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
