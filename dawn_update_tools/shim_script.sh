#!/bin/bash
source $(dirname ${BASH_SOURCE})/helpers.sh

# Find all files in dawn.lua that have the same name (case and file extension insensitive).
repeated_names=`grep '\.c.*' ../dawn.lua | sed -n 's/^\ *\".*\/\([a-zA-Z0-9_]*\)\.[cp]*\"\,/\1/p' | sort -f | uniq -d -i`

while IFS= read -r file_name ; do 
  shim_number=0
  # Find each file name in dawn.lua and get the path, file name and file extension.
  replace_pattern="s/^\ *\"\(.*\/\)\(${file_name}\)\(\.[cp]*\)\"\,/\1 \2 \3/pI"
  files_to_replace=`grep -i "\/${file_name}\." ../dawn.lua | sed -n "$replace_pattern"`

  while IFS= read -r line ; do
    IFS=' ' read -r path name extension <<< "$line"
    if ((shim_number > 0)); then
      # Replace the file include in dawn.lua with the new shim file name.
      replace_pattern="s|^\(\ *\"$path$name\)\(\.[cp]*\"\,\)|\1_rtc_shim_$shim_number\2|I"
      _sed_inplace "$replace_pattern" ../dawn.lua
      # Create the shim file and include the original file.
      echo "#include \"${name}${extension}\"" >> "../${path}${name}_rtc_shim_${shim_number}${extension}"
    fi
    shim_number=$((shim_number+1))
  done <<< "$files_to_replace"
done <<< "$repeated_names"