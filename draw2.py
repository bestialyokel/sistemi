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

oxy = np.arange(1000, 100000, 1000)

for i in range(99):
    Lines[i] = Lines[i].split(',')
    Lines[i].pop()
    for j in range(len(Lines[i])):
        Lines[i][j] = float(Lines[i][j])



fig = plt.figure()
ax = fig.add_subplot(111, projection='3d')

X, Y = np.meshgrid(oxy, oxy)

ax.plot_surface(X, Y, np.array(Lines), cmap='inferno', interpolation='nearest')
ax.legend()


plt.show()


#axes = plt.gca()
#axes.invert_yaxis()
#plt.show()
#
#plt.xticks(oxy)
#plt.yticks(oxy)
#
#plt.xlabel("KeyRange")
#plt.ylabel("Operations")