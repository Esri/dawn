#!/bin/bash

rm -rf ./third_party/abseil-cpp

target=$(readlink -f "../abseil-cpp")
link_name="./third_party/abseil-cpp"
#echo "$target"
#echo "$link_name"
ln -s "$target" "$link_name"

python_dir=/usr/local/rtc/python/3.12/bin/python
enable_vulkan="OFF"
fetch_dependencies="OFF"

os="$(uname)"
if [[ "${os}" == *"Darwin"* ]]; then
  os="macos"
elif [[ "${os}" == *"Linux"* ]]; then
  os="linux"
  enable_vulkan="ON"
  fetch_dependencies="ON"
fi

cd ..
mkdir temp_dawn_build
cd temp_dawn_build
/usr/local/rtc/cmake/3.29.2/bin/cmake ../dawn -DDAWN_BUILD_TESTS=OFF -DTINT_BUILD_TESTS=OFF -DDAWN_ENABLE_VULKAN=${enable_vulkan} -DTINT_BUILD_GLSL_WRITER=OFF -DTINT_BUILD_GLSL_VALIDATOR=OFF -DDAWN_USE_GLFW=OFF -DDAWN_BUILD_SAMPLES=OFF -DPython3_EXECUTABLE=${python_dir} -DENABLE_NULL=OFF -DDAWN_FETCH_DEPENDENCIES=${fetch_dependencies}
cd ../dawn
grep "file" ../temp_dawn_build/compile_commands.json > temp_file

${python_dir} file_splitter.py $os

rm temp_file
git checkout HEAD~1 -- ./third_party/abseil-cpp

