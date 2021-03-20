import os
#import matplotlib.pyplot as plt
import matplotlib.pyplot as plt
import numpy as np

FILENAME = "result"

result = open(FILENAME, 'r')
Lines = result.readlines()

matrix = [None]*99
for i in range(99):
    matrix[i] = [0]* 99

oxy = np.arange(1000, 99000, 1000)

for i in range(99):
    Lines[i] = Lines[i].split(',')
    Lines[i].pop()
    for j in range(len(Lines[i])):
        Lines[i][j] = float(Lines[i][j])

plt.xticks(oxy)
plt.yticks(oxy)

plt.xlabel("KeyRange")
plt.ylabel("Operations")

plt.imshow(Lines, cmap='hot')

axes = plt.gca()
axes.invert_yaxis()
plt.show()
