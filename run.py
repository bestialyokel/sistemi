import os, subprocess
import matplotlib.pyplot as plt
import numpy as np


KeyRanges = [];
Operations = [];

SIZE = 100

for i in range(SIZE):
   KeyRanges.append(250 + 250*i)
   Operations.append(250 + 250*i)

#MATRIX
result = [None] * SIZE
for i in range(SIZE):
    result[i] = [i] * SIZE

for r in range(SIZE):
    for o in range(SIZE):
        os.system(f'escript bst.erl {KeyRanges[r]} {Operations[o]}')

plt.imshow(result, cmap='hot', interpolation='nearest')
plt.savefig('result.png')