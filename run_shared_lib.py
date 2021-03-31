import ctypes
import platform

if platform.system() == "Linux":
    filename = "libmain.so"
elif platform.system() == "Darwin":
    filename = "libmain.dylib"
elif platform.system() == "Windows":
    filename = "libmain.dll"
else:
    filename = ""
assert filename, "Unknown platform"

mylib = ctypes.CDLL(f"./{filename}")
print(mylib.add(400, 400))  # prints 800
assert mylib.add == 800
