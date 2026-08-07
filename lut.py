import numpy as np

N = 256
AMP = 32767

for i in range(N):
    angle = 2 * np.pi * i / N
    value = int(AMP * np.sin(angle))
    print(f"sine_lut[{i}] = 16'sd{value};")
