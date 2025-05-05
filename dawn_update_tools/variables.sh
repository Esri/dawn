#!/bin/bash

os="$(uname)"
if [[ "${os}" == *"Darwin"* ]]; then
  os="macos"
elif [[ "${os}" == *"Linux"* ]]; then
  os="linux"
else
  os="windows"
fi

# Multiple OS
python_version="3.12"
cmake_version="3.29.2"
llvm_version="19.1.2"
python_path=/usr/local/rtc/python/3.12/bin/python
cmake_path="/usr/local/rtc/cmake/3.29.2/bin/cmake"
windows_target_sdk="10.0.19041.0"

# Liunx
c_comp="/usr/local/rtc/llvm/19.1.2/bin/clang"
cxx_comp="/usr/local/rtc/llvm/19.1.2/bin/clang++"
x11_include="/usr/local/rtc/sysroot/redhat8.4/x86_64/usr/include"
x11_lib="/usr/local/rtc/sysroot/redhat8.4/x86_64/usr/lib64/libX11.so"

# Windows
visual_studio_install_paths=(\
    "C:/Program Files/Microsoft Visual Studio/2022/Enterprise" \
    "C:/Program Files/Microsoft Visual Studio/2022/Professional" \
    "C:/Program Files/Microsoft Visual Studio/2022/Preview" \
    "C:/Program Files (x86)/Microsoft Visual Studio/2022/BuildTools" \
  )