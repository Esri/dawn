#!/bin/bash

source $(dirname ${BASH_SOURCE})/helpers.sh

function _display_help_dialog() {
  echo "================================================================================"
  echo "Usage: update_lua_file.sh [OPTION]..."
  echo
  echo "Description: The update_lua_file.sh script updates dawn.lua with the necessary includes to build the library."
  echo "              It also produces shim files for the windows build."
  echo
  echo " -o      Remove the current includes in dawn.lua. Run with this option if this is the first OS you are updating on."
  echo "          Optional"
  echo
  echo " -h      Displays this help dialog."
  echo "          Optional"
  echo "================================================================================"
  exit 0
}
overwrite=0
while getopts "oh" flag; do
  case $flag in 
    o)
    overwrite=1
    ;;
    h)
    _display_help_dialog
    ;;
  esac
done

python_path="/usr/local/rtc/python/${python_version}/bin/python"
cmake_path="/usr/local/rtc/cmake/${cmake_version}/bin/cmake"

# If on winows update paths
if [[ "${os}" == "windows" ]]; then
  cmake_path="${cmake_path/\/usr\/local/C:}"
  python_path="${C:/rtc/python/${python_version}/Scripts/python.exe}"
fi

# Delete shim files and revert lua file includes to their normal names
find .. -name "*rtc_shim*" -delete
_sed_inplace "s|_rtc_shim_.*\.|.|" ../dawn.lua

cd ../..
mkdir temp_dawn_build
cd temp_dawn_build

# Create command and run it to generate compile_commands.json
command="../dawn "

command_options=(\
    "-DDAWN_FETCH_DEPENDENCIES=ON" # Needed for Dawn's CMake build system
    "-DDAWN_BUILD_TESTS=OFF" \
    "-DDAWN_BUILD_SAMPLES=OFF" \
    "-DTINT_BUILD_TESTS=OFF" \
    "-DDAWN_USE_GLFW=OFF" \
    "-DDAWN_ENABLE_OPENGLES=OFF" \ 
    "-DDAWN_ENABLE_DESKTOP_GL=OFF" \
    "-DDAWN_ENABLE_D3D11=OFF" \
  )
if [ "${os}" == "linux" ]; then
  command_options+=( "-DX11_X11_INCLUDE_PATH=/usr/local/rtc/sysroot/redhat8.4/x86_64/usr/include" )
  command_options+=( "-DX11_X11_LIB=/usr/local/rtc/sysroot/redhat8.4/x86_64/usr/lib64/libX11.so" )
  command_options+=( "-DCMAKE_C_COMPILER=/usr/local/rtc/llvm/${llvm_version}/bin/clang" )
  command_options+=( "-DCMAKE_CXX_COMPILER=/usr/local/rtc/llvm/${llvm_version}/bin/clang++" )
fi
for ((i=0; i<${#command_options[@]}; i++)) do
  command+="${command_options[${i}]} "
done

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


