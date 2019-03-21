#!/usr/bin/env python
import sys
import os

if len(sys.argv) < 2:
    sys.stderr.write("usage: "+sys.argv[0]+" <width: 8/16/32>\n")
    sys.exit(1)

fin = sys.stdin
fout = sys.stdout

fin.seek(0, os.SEEK_END)
size = fin.tell()
fin.seek(0, os.SEEK_SET)

width = int(sys.argv[1])
nbytes = width/8

addr = 0;
while True:
    b = fin.read(nbytes)
    if len(b)==0:
        break;
    fout.write(":04");
    fout.write("".join('{0:0>4x}'.format(addr)))
    fout.write("00");
    fout.write("".join(format(ord(j),'02x') for j in b[::-1]))
    fout.write("\n");
    addr += 1


