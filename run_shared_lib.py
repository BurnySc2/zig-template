import ctypes
import platform
from time import perf_counter_ns

filename = ""
if platform.system() == "Linux":
    filename = "libmain.so"
elif platform.system() == "Darwin":
    filename = "libmain.dylib"
elif platform.system() == "Windows":
    filename = "main.dll"
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
print(f"Program took {total_time_ns} nanoseconds")
