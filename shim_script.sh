#!/bin/bash

variable=`grep '\.c.*' dawn.lua | sed 's/^\ *\".*\/\([a-zA-Z0-9_]*\)\.[cp]*\"\,/\1/' | sort | uniq -d`
var=`grep 'load\.c.*' dawn.lua | sed 's/\"\(.*\)load\.c.*\"\,/\1/'`

int=0
while IFD= read -r line ; do
  if (( int > 0)); then
    echo $int
    #path="${line}load_rtc_shim.cc"
    #echo $path
    #touch $path
    #echo '#include "load.cc"' >> $path
  fi
  echo $line
  int=$((int+1))

done <<< "$var"

while IFS= read -r line ; do 
  #echo "$line"
  pattern="$line\.c.*"
  sub="s/\"\(.*\)${line}\.c.*\"\,/\1/"
  #echo $sub
  var=`grep "$pattern" dawn.lua | sed "$sub"`
  int=0
  #echo $var
  while IFS= read -r file ; do 
    echo $file
  done <<< "$var"
done <<< "$variable"