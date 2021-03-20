import os
#import matplotlib.pyplot as plt
import matplotlib.pyplot as plt
import numpy as np

FILENAME = "result"

result = open(FILENAME, 'r')
Lines = result.readlines()

SIZE = 99

matrix = [None] * SIZE
for i in range(SIZE):
    matrix[i] = [0] * SIZE

oxy = np.arange(1000, 100000, 10000)

for i in range(SIZE):
    Lines[i] = Lines[i].split(',')
    Lines[i].pop()
    for j in range(len(Lines[i])):
        Lines[i][j] = float(Lines[i][j])


plt.xlabel("KeyRange")
plt.ylabel("Operations")

plt.imshow(Lines, cmap='hot')


plt.gca().invert_yaxis()

plt.savefig('result.png')



