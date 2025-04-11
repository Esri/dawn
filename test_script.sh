#!/bin/bash

#rm -rf ./third_party/abseil-cpp

#target=$(readlink -f "../abseil-cpp")
#link_name="./third_party/abseil-cpp"
#echo "$target"
#echo "$link_name"
#ln -s "$target" "$link_name"

cd ..
mkdir temp_dawn_build
cd temp_dawn_build
/usr/local/rtc/cmake/3.29.2/bin/cmake ../dawn -DDAWN_BUILD_TESTS=OFF -DTINT_BUILD_TESTS=OFF -DDAWN_ENABLE_VULKAN=ON -DTINT_BUILD_GLSL_WRITER=OFF -DTINT_BUILD_GLSL_VALIDATOR=OFF -DDAWN_USE_GLFW=OFF -DDAWN_BUILD_SAMPLES=OFF -DPython3_EXECUTABLE=/usr/local/rtc/python/3.12/bin/python3.12 -DENABLE_NULL=OFF -DDAWN_FETCH_DEPENDENCIES=ON
cd ../dawn
touch "temp_file"
grep "file" ../temp_dawn_build/compile_commands.json > temp_file

/usr/local/rtc/python/3.12/bin/python file_splitter.py
