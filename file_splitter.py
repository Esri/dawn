from itertools import groupby
from os.path import dirname
from os.path import commonpath
from os import getcwd
from pathlib import Path
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
                    if "/metal/" in line:
                        platform_lines[0].append(line)
                    elif "/msl/" in line:
                        platform_lines[1].append(line)
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

msl_str += "    -- CMake target: tint_lang_msl\n"
nxt = False
for file in platform_lines[1] :
    if not nxt and "writer" in file:
        msl_str += "\n    -- CMake target: tint_lang_msl_writer\n"
        nxt = True
    msl_str = msl_str + " \"" + file + "\",\n"
msl_str = msl_str + "\n"


with open ('dawn.lua', 'r' ) as fl:
    content = fl.read()
    content_new = re.sub('files {\n.*--.*?src/dawn/native/(.|\n)*?}', 'files {\n' + result + '}', content)
    content_new = re.sub('(if \(enable_metal\) then(.|\n)*?files {\n)(.|\n)*?}', r'\1' + metal_str + '}', content_new)
    content_new = re.sub('(if \(enable_msl\) then(.|\n)*?files {\n)(.|\n)*?}', r'\1' + msl_str + '}', content_new)
with open('dawn.lua', 'w') as fl:
    fl.write(content_new)


print()
print()
for line in others:
    print(line)
