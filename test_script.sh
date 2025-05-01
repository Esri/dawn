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

# If on winows update paths
if [[ "${os}" == "windows" ]]; then
  cmake_path="${cmake_path/\/usr\/local/C:}"
  python_dir="${C:/rtc/python/3.12/Scripts/python.exe}"
fi

# Delete shim files and revert lua file includes to their normal names
find . -name "*rtc_shim*" -delete
_sed_inplace "s|_rtc_shim_.*\.|.|" dawn.lua

cd ..
mkdir temp_dawn_build
cd temp_dawn_build

# Create command and run it to generate compile_commands.json
command="../dawn -DDAWN_FETCH_DEPENDENCIES=ON -DDAWN_BUILD_TESTS=OFF -DDAWN_BUILD_SAMPLES=OFF -DTINT_BUILD_TESTS=OFF -DDAWN_USE_GLFW=OFF -DPython3_EXECUTABLE=${python_dir} -DDAWN_ENABLE_OPENGLES=OFF -DDAWN_ENABLE_DESKTOP_GL=OFF -DDAWN_ENABLE_D3D11=OFF"
if [[ "${os}" == "windows" ]]; then
  command="-GNinja ${command}"
  _run_visual_studio_native_tools_command "${cmake_path} ${command}"
else
  ${cmake_path} ${command}
fi

cd ../dawn

# Update dawn.lua file with the correct file includes
grep "file" ../temp_dawn_build/compile_commands.json > temp_file
${python_dir} ./file_splitter.py $os "${overwrite}"

# Run the shim script to add shim files for windows
./shim_script.sh

# remove temporary build directory
rm ./temp_file
rm -r ../temp_dawn_build


