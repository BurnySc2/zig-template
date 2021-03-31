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

t0 = perf_counter_ns()
process = subprocess.Popen([filename])
process.wait()
t1 = perf_counter_ns()
limit = 10 ** 9  # 10**9 = 1second
assert t1 - t0 < limit, "Program took more than 1 second"
