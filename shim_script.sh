#!/bin/bash

find . -name "*rtc_shim*" -delete


variable=`grep '\.c.*' dawn.lua | sed -n 's/^\ *\".*\/\([a-zA-Z0-9_]*\.[cp]*\)\"\,/\1/p' | sort | uniq -d`

while IFS= read -r line ; do 
  pattern="$line"
  sub="s/^\ *\"\(.*\)\/${line}\"\,/\1/p"
  var=`grep "$pattern" dawn.lua | sed -n "$sub"`
  int=0
  while IFS= read -r file ; do 
    if ((int > 0)); then
      search="\(.*\)\.\(.*\)"
      replace="bla"
      result="$(sed "s/\(.*\)\.\(.*\)/\1_rtc_shim_${int}.\2/" <<< $line)"
      shim_path="${file}/${result}"
      old_path="${file}/${line}"
      echo "#include \"${line}\"" >> $shim_path
      echo "${old_path} ${shim_path}" >> "shim_temp_file.txt"
    fi
    int=$((int+1))
  done <<< "$var"
done <<< "$variable"

python_dir="${C:/rtc/python/3.12/Scripts/python.exe}"
${python_dir} ./shim_replacer.py