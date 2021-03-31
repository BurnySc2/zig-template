import ctypes

mylib = ctypes.CDLL("./libmain.so")
print(mylib.add(400, 400))  # prints 800
