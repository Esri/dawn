#!/bin/bash

source $(dirname ${BASH_SOURCE})/variables.sh

function _sed_inplace() {
  # copied from runtimecore
  # sed helper function to encapsulate the different ways to invoke sed
  # Parameter ${1}: The sed string
  # Parameter ${2}: The file to run sed on
  if [ "${os}" != "macos" ]; then
    sed -i "${1}" "${2}"
  else
    sed -i '' "${1}" "${2}"
  fi
}

# Windows helpers

visual_studio_install_path=

function _get_visual_studio_install_path() {
  # Copied from runtimecore
  # checks the common installer paths and returns the installer path once it is found. The install paths all have spaces
  # due to Windows using it which needs to then be wrapped in "" once the full path is completed
  if [ -z "${visual_studio_install_path}" ]; then
    for ((i=0; i<${#visual_studio_install_paths[@]}; i++)) do
      if [ -d "${visual_studio_install_paths[${i}]}" ]; then
        visual_studio_install_path="${visual_studio_install_paths[${i}]}"
        break
      fi
    done

    if [ -z "${visual_studio_install_path}" ]; then
      echo "error: Couldn't detect any installed versions of visual studio at the following locations:"
      for ((i=0; i<${#visual_studio_install_paths[@]}; i++)) do
        echo "${visual_studio_install_paths[${i}]}"
      done
      exit 1
    fi
  fi
  echo "${visual_studio_install_path}"
}

function _run_visual_studio_native_tools_command() {
  # Copied and modified from runtimecore
  # Runs an input command using a native tools prompt. This provides access to the Visual Studio developer environment
  # that is not set on a normal cmd or bash prompt. The vcvarsall script expects and arch, platform_type, winsdk_version
  # and vcvars_ver. The arch and platform_type are required but the winsdk_version and vcvars_ver can be deduced from
  # global variables
  # Parameter 1: the command to run
  local command="${*:1}" # capture the input as a single string to pass along to the native tools

  local arch=`uname -m`
  if [ "$arch" == "x86_64" ]; then
    arch="x64"
  fi

  # find the native tools path by checking common installations
  local vcvarsall_path="\"$(_get_visual_studio_install_path)/VC/Auxiliary/Build/vcvarsall.bat\""

  # arch
  local vcvarsall_parameters="${arch} "
  vcvarsall_parameters+="${windows_target_sdk} "
  echo $vcvarsall_parameters

  # windows cannot use the mingwin/cygwin environment as it requires using a windows cmd. Generate the bat file and
  # invoke it in order to correctly configure and run the build
  local batch_file="/tmp/_run_visual_studio_native_tools_command.bat"
  echo "${vcvarsall_path} ${vcvarsall_parameters} && ^" > "${batch_file}"
  echo "${command}" >> "${batch_file}"
  chmod +x "${batch_file}"
  "${batch_file}"
}
