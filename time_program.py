from time import perf_counter_ns
import subprocess
import platform

if platform.system() == "Linux":
    filename = "./main"
elif platform.system() == "Darwin":
    filename = "./main"
elif platform.system() == "Windows":
    filename = "./main.exe"
else:
    filename = ""
assert filename, "Unknown platform"

run_amount = 1000
t0 = perf_counter_ns()
for i in range(run_amount):
    process = subprocess.Popen([filename], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    process.wait()
t1 = perf_counter_ns()

total_time_ns = (t1 - t0) // run_amount
time_in_ms = total_time_ns / 10 ** 6
print(f"Program took {time_in_ms:.3f} milliseconds")

limit_ns = 10 ** 9  # 10**9 = 1second
assert total_time_ns < limit_ns, "Program took more than 1 second"
