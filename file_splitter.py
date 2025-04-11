from itertools import groupby
from os.path import dirname
from os.path import commonpath
from os import getcwd
import re

def file_to_list(file_path, dawn_lines, platform_lines):
    try:
        curr_direct = getcwd()
        regex = re.compile('\"file\": \"{}/(.*)\",'.format(curr_direct))
        with open(file_path, 'r') as file:
            lines = file.readlines()
            for line in lines:
                line = line.rstrip('\n')
                match = re.search(regex, line)
                if(match != None) :
                    line = match.group(1)
                    if "/metal/" in line or "/msl/" in line:
                        platform_lines.append(line)
                    else:
                        dawn_lines.append(line)
    except FileNotFoundError:
        return "File not found."

parents = {
    "src/dawn/native" : [],
    "src/dawn/common" : [],
    "src/dawn/platform" : [],
    "src/tint/api" : [],
    "src/tint/lang/core" : [],
    "src/tint/lang/wgsl" : [],
    "src/tint/utils" : [],
}

paths = [
  "src/dawn/native/SharedFence.cpp",
  "src/dawn/native/SharedResourceMemory.cpp",
  "src/dawn/native/SharedTextureMemory.cpp",
  "src/dawn/native/Subresource.cpp",
  "src/tint/lang/core/constant/node.cc",
  "src/tint/lang/core/constant/scalar.cc",
  "src/tint/lang/core/constant/splat.cc",
  "src/dawn/common/FutureUtils.cpp",
  "src/tint/lang/core/constant/value.cc",
  "src/tint/lang/wgsl/ast/builder_rtc_shim1.cc",
  "src/dawn/common/GPUInfo.cpp",
  "src/dawn/common/Log.cpp",
  "src/tint/lang/wgsl/ast/builtin_attribute.cc",
  "src/tint/utils/generation_id.cc",
  "src/tint/utils/macros/macros.cc",
  "src/tint/utils/math/math_rtc_shim.cc",
  "src/tint/utils/memory/memory.cc",
  "src/tint/utils/reflection.cc",
]

file_path = "temp_file"
paths = []
platform_paths = []
file_to_list(file_path, paths, platform_paths)

sorted(paths)
sorted(platform_paths)

out = {}
others = []
for p in paths:
    found = False
    for parent, files in parents.items():
        try:
            if (commonpath([p, parent]) == parent):
                files.append(p)
                found = True
        except:
            print(p)
            print(parent)
            exit()
    if not found:
        others.append(p)
l = list(out.values())

print()

result = ""
for parent, files in parents.items():
    result = result + "  -- CMake target: " + parent + "\n"
    if parent == "src/dawn/native":
        result = result + "  DAWN_GEN_OUTPUT_DIR..\"/src/dawn/native/**.cpp\",\n"
    if parent == "src/dawn/common":
        result = result + "  DAWN_GEN_OUTPUT_DIR..\"/src/dawn/common/**.cpp\",\n"
    for file in files:
        result = result + "  \"" + file + "\",\n"
    result = result + "\n"

with open ('dawn.lua', 'r' ) as fl:
    content = fl.read()
    content_new = re.sub('files {\n.*--.*?src/dawn/native/(.|\n)*?}', 'files {\n' + result + '}', content)
with open('dawn.lua', 'w') as fl:
    fl.write(content_new)


print()
for line in platform_paths:
    print("\"" + line + "\",")

print()
print()
for line in others:
    print(line)
