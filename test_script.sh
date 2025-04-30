#!/bin/bash

source $(dirname ${BASH_SOURCE})/helpers.sh

overwrite=0
while getopts "o" flag; do
  case $flag in 
    o)
    overwrite=1
    ;;
  esac
done

#export PATH=$PATH:"C:/rtc/ninja/1.11.1/bin/"

python_dir=/usr/local/rtc/python/3.12/bin/python
cmake_path="/usr/local/rtc/cmake/3.29.2/bin/cmake"
enable_vulkan="ON"
fetch_dependencies="ON"

# If on winows update paths
if [[ "${os}" == "windows" ]]; then
  cmake_path="${cmake_path/\/usr\/local/C:}"
  python_dir="${C:/rtc/python/3.12/Scripts/python.exe}"
fi

#windows: which is needed???
#ninja_path="/usr/local/rtc/ninja/1.11.1/bin"
#ninja_path="${ninja_path/\/usr\/local/c:}"
#ninja_path="c:/rtc/ninja/1.11.1/bin"
#export PATH=$PATH':/c/rtc/llvm/19.1.2/bin"'
#export PATH=$PATH':/c/rtc/ninja/1.11.1/bin' cant remember which one it was

# Delete shim files and revert lua file includes to their normal names
find . -name "*rtc_shim*" -delete
_sed_inplace "s|_rtc_shim_.*\.|.|" dawn.lua

cd ..
mkdir temp_dawn_build
cd temp_dawn_build

# Create command and run it to generate compile_commands.json
command="../dawn -DDAWN_FETCH_DEPENDENCIES=ON -DDAWN_BUILD_TESTS=OFF -DDAWN_BUILD_SAMPLES=OFF -DTINT_BUILD_TESTS=OFF -DDAWN_USE_GLFW=OFF -DPython3_EXECUTABLE=${python_dir} -DDAWN_ENABLE_OPENGLES=OFF -DDAWN_ENABLE_DESKTOP_GL=OFF"
if [[ "${os}" == "windows" ]]; then
  command= "-GNinja ${command}"
  _run_visual_studio_native_tools_command "${cmake_path} ${command}"
else
  ${cmake_path} ${command}
fi

cd ../dawn

# Updade dawn.lua file with the correct file includes
include_files=`grep "file" ../temp_dawn_build/compile_commands.json`
${python_dir} ./file_splitter.py $os "${include_files}" "${overwrite}"

# Run the shim script to add shim files for windows
./shim_script.sh

# remove temporary build directory
rm -r ../temp_dawn_build


