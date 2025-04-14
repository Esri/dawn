from itertools import groupby
from os.path import dirname
from os.path import commonpath
from os import getcwd
from pathlib import Path
import re

def file_to_list(file_path, dawn_lines, platform_lines):
    try:
        curr_direct = getcwd()
        regex = re.compile('\"file\": \".*/dawn/(src/.*)\",')
        with open(file_path, 'r') as file:
            lines = file.readlines()
            for line in lines:
                line = line.rstrip('\n')
                match = re.search(regex, line)
                if(match != None) :
                    line = match.group(1)
                    if "/spirv/" in line:
                        platform_lines[0].append(line)
                    elif "/vulkan/" in line:
                        platform_lines[1].append(line)
                    elif "/opengl/" not in line:
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

file_path = "temp_file"
paths = []
platform_lines = [[],[]]
file_to_list(file_path, paths, platform_lines)

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
    files.sort()
    for file in files:
        result = result + "  \"" + file + "\",\n"
    result = result + "\n"

metal_str = ""
platform_lines[0].sort()
for file in platform_lines[0] :
    metal_str = metal_str + " \"" + file + "\",\n"
metal_str = metal_str + "\n"

msl_str = ""
platform_lines[1].sort()

for file in platform_lines[1] :
    msl_str = msl_str + " \"" + file + "\",\n"
msl_str = msl_str + "\n"

with open ('dawn.lua', 'r' ) as fl:
    content = fl.read()
    content_new = re.sub('files {\n.*?--.*?src/dawn/native(.|\n)*?}', 'files {\n' + result + '}', content)
    if content_new == content:
        print("didn't sub")
    content_new = re.sub('(if \(enable_spirv\) then(.|\n)*?files {\n)(.|\n)*?}', r'\1' + metal_str + '}', content_new)
    content_new = re.sub('(if \(enable_vulkan\) then(.|\n)*?files {\n)(.|\n)*?}', r'\1' + msl_str + '}', content_new)
    fl.close()
with open('dawn.lua', 'w') as fl:
    fl.write(content_new)
    fl.close()


print()
print()
