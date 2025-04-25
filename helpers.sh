#!/bin/bash

os="$(uname)"
if [[ "${os}" == *"Darwin"* ]]; then
  os="macos"
elif [[ "${os}" == *"Linux"* ]]; then
  os="linux"
else
  os="windows"
fi

function _sed_inplace() {
  # sed helper function to encapsulate the different ways to invoke sed
  # Parameter ${1}: The sed string
  # Parameter ${2}: The file to run sed on
  if [ "${os}" != "macos" ]; then
    sed -i "${1}" "${2}"
  else
    sed -i '' "${1}" "${2}"
  fi
}

