# Requirements
zig installed (on arch systems: `pacman -S zig`)

# Building and running
`zig run main.zig`

# Testing
Test statements starting with `test`

`zig test main.zig`

Or to test all zig files in current directory

`zig test *.zig`

# Building a shared lib that can be used in Python
`zig build-lib main.zig -dynamic`

and call from Python:

```py
import ctypes
a = ctypes.CDLL("./libmain.so")
print(a.add(400, 400)) #  prints 800
```

