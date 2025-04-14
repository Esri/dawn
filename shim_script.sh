#!/bin/bash

variable=`grep '\.c.*' dawn.lua | sed -n 's/^\ *\".*\/\([a-zA-Z0-9_]*\.[cp]*\)\"\,/\1/p' | sort | uniq -d`
#var=`grep 'load\.c.*' dawn.lua | sed 's/\"\(.*\)load\.c.*\"\,/\1/'`

while IFS= read -r line ; do 
  pattern="$line"
  sub="s/^\ *\"\(.*\)\/${line}\"\,/\1/p"
  #echo $sub
  echo ""
  echo $line
  echo "==============="
  var=`grep "$pattern" dawn.lua | sed -n "$sub"`
  int=0
  #echo $var
  while IFS= read -r file ; do 
    if ((int > 0)); then
      search="\(.*\)\.\(.*\)"
      replace="bla"
      result="$(sed "s/\(.*\)\.\(.*\)/\1_rtc_shim_${int}.\2/" <<< $line)"
      path="${file}/${result}"
      echo $path
      touch $path
      echo "#include \"${line}\"" >> $path
    fi
    int=$((int+1))
  done <<< "$var"
done <<< "$variable"