#!/usr/bin/python
import sys
try:
    if 'x' in sys.argv[1] or 'X' in sys.argv[1]:
        v = int(sys.argv[1], 16)
    else:
        v = int(sys.argv[1])
except:
    print "%s NUM" % sys.argv[0]
    sys.exit(-1)

for v in [36, 36, 126, 66, 90, 126, 24, 60, 126, 255, 189, 189, 36, 36, 102, 102]:
    bits = 32
    sys.stdout.write("0b")
    for i in range(bits - 1, -1, -1):
        s = 1 << i
        if v & s:
            sys.stdout.write("1")
        else:
            sys.stdout.write("0")
        if i and not i % 8:
            sys.stdout.write(" ")
    sys.stdout.write("\n")
