#!/bin/bash

source $(dirname ${BASH_SOURCE})/variables.sh
source $(dirname ${BASH_SOURCE})/helpers.sh

overwrite=0
while getopts "o" flag; do
  case $flag in 
    o)
    overwrite=1
    ;;
  esac
done

# If on winows update paths
if [[ "${os}" == "windows" ]]; then
  cmake_path="${cmake_path/\/usr\/local/C:}"
  python_path="${C:/rtc/python/3.12/Scripts/python.exe}"
fi

# Delete shim files and revert lua file includes to their normal names
find .. -name "*rtc_shim*" -delete
_sed_inplace "s|_rtc_shim_.*\.|.|" ../dawn.lua

cd ../..
mkdir temp_dawn_build
cd temp_dawn_build

# Create command and run it to generate compile_commands.json
command="../dawn -DDAWN_FETCH_DEPENDENCIES=ON -DX11_X11_INCLUDE_PATH=${x11_include} -DX11_X11_LIB=${x11_lib} -DCMAKE_C_COMPILER=${c_comp} -DCMAKE_CXX_COMPILER=${cxx_comp} -DDAWN_BUILD_TESTS=OFF -DDAWN_BUILD_SAMPLES=OFF -DTINT_BUILD_TESTS=OFF -DDAWN_USE_GLFW=OFF -DPython3_EXECUTABLE=${python_path} -DDAWN_ENABLE_OPENGLES=OFF -DDAWN_ENABLE_DESKTOP_GL=OFF -DDAWN_ENABLE_D3D11=OFF"
if [[ "${os}" == "windows" ]]; then
  command="-GNinja ${command}"
  _run_visual_studio_native_tools_command "${cmake_path} ${command}"
else
  ${cmake_path} ${command}
fi

cd ../dawn/dawn_update_tools

# Update dawn.lua file with the correct file includes
grep "file" ../../temp_dawn_build/compile_commands.json > temp_file
${python_path} ./file_splitter.py $os "${overwrite}"

# Run the shim script to add shim files for windows
./shim_script.sh

# remove temporary build directory
rm ./temp_file
rm -r ../../temp_dawn_build


