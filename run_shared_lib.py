import ctypes
import platform
from time import perf_counter_ns

if platform.system() == "Linux":
    filename = "libmain.so"
elif platform.system() == "Darwin":
    filename = "libmain.dylib"
elif platform.system() == "Windows":
    filename = "main.dll"
else:
    filename = ""
assert filename, "Unknown platform"

mylib = ctypes.CDLL(f"./{filename}")
# print(mylib.add(400, 400))  # prints 800
assert mylib.add(400, 400) == 800

run_amount = 1000
t0 = perf_counter_ns()
for i in range(run_amount):
    mylib.add(400, 400)
t1 = perf_counter_ns()

total_time_ns = (t1 - t0) // run_amount
time_in_ms = total_time_ns / 10 ** 6
print(f"Program took {time_in_ms:.3f} milliseconds")
