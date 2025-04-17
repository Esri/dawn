#!/bin/bash

source $(dirname ${BASH_SOURCE})/../../runtimecore/runtimecore_scripts/scripts/platform_helper.sh
export PATH=$PATH:"C:/rtc/ninja/1.11.1/bin/"

rm -rf ./third_party/abseil-cpp

target=$(readlink -f "../abseil-cpp")
link_name="./third_party/abseil-cpp"
#echo "$target"
#echo "$link_name"
ln -s "$target" "$link_name"

python_dir=/usr/local/rtc/python/3.12/bin/python
enable_vulkan="ON"
fetch_dependencies="ON"

os="$(uname)"
if [[ "${os}" == *"Darwin"* ]]; then
  os="macos"
elif [[ "${os}" == *"Linux"* ]]; then
  os="linux"
  enable_vulkan="ON"
  fetch_dependencies="ON"
else
  os="windows"
fi

ninja_path="/usr/local/rtc/ninja/1.11.1/bin"
ninja_path="${ninja_path/\/usr\/local/c:}"
ninja_path="c:/rtc/ninja/1.11.1/bin"
export PATH=$PATH':/c/rtc/ninja/1.11.1/bin'
export PATH=$PATH':/c/rtc/llvm/19.1.2/bin"'

cd ..
mkdir temp_dawn_build
cd temp_dawn_build
cmake_path="/usr/local/rtc/cmake/3.29.2/bin/cmake"
cmake_path="${cmake_path/\/usr\/local/C:}"
echo $cmake_path
python_dir="${C:/rtc/python/3.12/Scripts/python.exe}"
command="${cmake_path} -GNinja ../dawn -DDAWN_BUILD_TESTS=OFF -DTINT_BUILD_TESTS=OFF -DDAWN_ENABLE_VULKAN=${enable_vulkan} -DTINT_BUILD_GLSL_WRITER=OFF -DTINT_BUILD_GLSL_VALIDATOR=OFF -DDAWN_USE_GLFW=OFF -DDAWN_BUILD_SAMPLES=OFF -DPython3_EXECUTABLE=${python_dir} -DENABLE_NULL=OFF -DDAWN_FETCH_DEPENDENCIES=${fetch_dependencies} -DCMAKE_EXPORT_COMPILE_COMMANDS=1"
_run_visual_studio_native_tools_command "x64" "windows" "${command}"
cd ../dawn
grep "file" ../temp_dawn_build/compile_commands.json > temp_file

${python_dir} ./file_splitter.py $os

rm temp_file
git checkout HEAD~1 -- ./third_party/abseil-cpp


