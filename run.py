import os, subprocess
import numpy as np


TESTS = 1

nums = np.arange(1000, 100000, 1000)

FILENAME = "result"



with open(FILENAME, "a") as file:
    for r in nums:
        for o in nums:
            sum = 0
            for i in range(TESTS):
                val = subprocess.check_output(f'escript bst.erl {r} {o}', shell=True)
                val = int( val )
                sum = sum + val

            sum = sum/TESTS
            file.write( str(sum) )
            file.write(",")

        file.write("\n")
