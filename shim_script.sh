#!/bin/bash
source $(dirname ${BASH_SOURCE})/helpers.sh

find . -name "*rtc_shim*" -delete

repeated_names=`grep '\.c.*' dawn.lua | sed -n 's/^\ *\".*\/\([a-zA-Z0-9_]*\)\.[cp]*\"\,/\1/p' | sort -f | uniq -d -i`

while IFS= read -r file_name ; do 
  int=0
  replace_pattern="s/^\ *\"\(.*\/\)${file_name}\(\.[cp]*\)\"\,/\1 \2/pI"
  files_to_replace=`grep -i "\/${file_name}\." dawn.lua | sed -n "$replace_pattern"`

  while IFS= read -r line ; do
    IFS=' ' read -r path extension <<< "$line"
    if ((int > 0)); then
      replace_pattern2="s|^\(\ *\"$path$file_name\)\([cp]*.*\)|\1_rtc_shim_$int\2|I"
      _sed_inplace "$replace_pattern2" dawn.lua
      echo "#include \"${path}${file_name}${extension}\"" >> "${path}${file_name}_rtc_shim_${int}${extension}"
    fi
    int=$((int+1))
  done <<< "$files_to_replace"
done <<< "$repeated_names"
