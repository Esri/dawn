#!/usr/bin/env python

with open ('dawn.lua', 'r') as f1, \
     open ('shim_temp_file.txt', 'r') as f2:
  
  origtxt = f1.read()
  lines = f2.readlines()
  for line in lines:
    paths = line.rstrip('\n').split(' ')
    origtxt = origtxt.replace(paths[0], paths[1])

with open ('dawn.lua', 'w') as f:
  f.write(origtxt)
  f.close()


