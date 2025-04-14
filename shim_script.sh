#!/bin/bash

variable=`grep '\.c.*' dawn.lua | sed 's/^\ *\".*\/\([a-zA-Z0-9_]*\)\.[cp]*\"\,/\1/' | sort | uniq -d`
var=`grep 'load\.c.*' dawn.lua | sed 's/\"\(.*\)load\.c.*\"\,/\1/'`

int=0
while IFD= read -r line ; do
  if (( int > 0)); then
    echo $int
    path="${line}load_rtc_shim.cc"
    echo $path
    touch $path
    echo '#include "load.cc"' >> $path
  fi
  echo $line
  int=$((int+1))

done <<< "$var"

#while IFS= read -r line ; do 
#  echo "$line bla ba"
#  pattern="$line\.c.*"
#  var=`grep "load\.c.*" dawn.lua`
#  echo $var
#  #grep "$pattern" dawn.lua | while read -r file; do
#  #  echo $file
#  #done
#done <<< "$variable"