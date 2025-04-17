#!/usr/bin/env python

from itertools import groupby
import sys
from os.path import dirname
from os.path import commonpath
from os import getcwd
from pathlib import Path
import re

def file_to_list_macos(file_path, dawn_lines, platform_lines):
    regex = re.compile('\"file\": \".*/dawn/(src/.*)\",')
    file_list = open(file_path, 'r')
    lines = file_list.readlines()

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

def file_to_list_linux(file_path, dawn_lines, platform_lines):
    regex = re.compile('\"file\": \".*/dawn/(src/.*)\",')
    file_list = open(file_path, 'r')
    lines = file_list.readlines()

    for line in lines:
        line = line.rstrip('\n')
        match = re.search(regex, line)
        if(match != None) :
            line = match.group(1)
            if "/vulkan/" in line:
                platform_lines[0].append(line)
            elif "/spirv/" in line:
                platform_lines[1].append(line)
            elif "opengl" not in line:
                dawn_lines.append(line)
                print(line)

def file_to_list_windows(file_path, dawn_lines, platform_lines):
    regex = re.compile('\"file\": \".*/dawn/(src/.*)\",')
    file_list = open(file_path, 'r')
    lines = file_list.readlines()

    for line in lines:
        line = line.rstrip('\n')
        line = re.sub(r'\\\\', '/', line)
        match = re.search(regex, line)
        if(match != None) :
            line = match.group(1)
            if "/vulkan/" in line:
                platform_lines[0].append(line)
            elif "/spirv/" in line:
                platform_lines[1].append(line)
            elif "/d3d/" in line or "/d3d12/" in line:
                platform_lines[2].append(line)
            elif "/hlsl/" in line:
                platform_lines[3].append(line)
            elif "opengl" not in line:
                dawn_lines.append(line)


def get_platform_result(operating_sys, platform_lines):
    paltform1_lines = ""
    platform_lines[0].sort()
    for line in platform_lines[0] :
        paltform1_lines = paltform1_lines + "    \"" + line + "\",\n"
    paltform1_lines = paltform1_lines + "\n"

    paltform2_lines = ""
    platform_lines[1].sort()
    for line in platform_lines[1] :
        paltform2_lines = paltform2_lines + "    \"" + line + "\",\n"
    paltform2_lines = paltform2_lines + "\n"

    lua_file = open('dawn.lua', 'r')
    content_new = lua_file.read()
    if operating_sys == "linux":
        content_new = re.sub(r'(if \(enable_vulkan\) then(.|\n)*?files {\n)(.|\n)*?}', r'\1' + paltform1_lines + '}', content_new)
        content_new = re.sub(r'(if \(enable_spirv\) then(.|\n)*?files {\n.*tint_lang_spirv\n)(.|\n)*?}', r'\1' + paltform2_lines + '}', content_new)
    elif operating_sys == "macos":
        content_new = re.sub(r'(if \(enable_metal\) then(.|\n)*?files {\n)(.|\n)*?}', r'\1' + paltform1_lines + '}', content_new)
        content_new = re.sub(r'(if \(enable_msl\) then(.|\n)*?files {\n.*tint_lang_msl\n)(.|\n)*?}', r'\1' + paltform2_lines + '}', content_new)
    elif operating_sys == "windows":
        paltform3_lines = ""
        platform_lines[2].sort()
        for line in platform_lines[2] :
            paltform3_lines = paltform3_lines + "    \"" + line + "\",\n"
        paltform3_lines = paltform3_lines + "\n"

        platform_lines[3].sort()
        paltform4_lines = ""
        for line in platform_lines[3] :
            paltform4_lines = paltform4_lines + "    \"" + line + "\",\n"
        paltform3_lines = paltform3_lines + "\n"
        content_new = re.sub(r'(if \(enable_vulkan\) then(.|\n)*?files {\n)(.|\n)*?}', r'\1' + paltform1_lines + '}', content_new)
        content_new = re.sub(r'(if \(enable_spirv\) then(.|\n)*?files {\n.*tint_lang_spirv\n)(.|\n)*?}', r'\1' + paltform2_lines + '}', content_new)
        content_new = re.sub(r'(if \(enable_d3d12\) then(.|\n)*?files {\n.*\n)(.|\n)*?}', r'\1' + paltform3_lines + '}', content_new)
        content_new = re.sub(r'(if \(enable_hlsl\) then(.|\n)*?files {\n.*\n)(.|\n)*?}', r'\1' + paltform4_lines + '}', content_new)

    lua_file.close()
    return content_new

parent_paths = {
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
platform_lines = [[],[], [], []]
operating_sys = sys.argv[1]

if operating_sys == "linux":
    file_to_list_linux(file_path, paths, platform_lines)
elif operating_sys == "macos":
    file_to_list_macos(file_path, paths, platform_lines)
elif operating_sys == "windows":
    file_to_list_windows(file_path, paths, platform_lines)


out = {}
others = []
print(paths)
for p in paths:
    found = False
    for parent, files in parent_paths.items():
        if parent in p:
            files.append(p)
            found = True
    if not found:
        others.append(p)
l = list(out.values())

result = ""
for parent, files in parent_paths.items():
    result = result + "  -- CMake target: " + parent + "\n"
    if parent == "src/dawn/native":
        result = result + "  DAWN_GEN_OUTPUT_DIR..\"/src/dawn/native/**.cpp\",\n"
    if parent == "src/dawn/common":
        result = result + "  DAWN_GEN_OUTPUT_DIR..\"/src/dawn/common/**.cpp\",\n"
    files.sort()
    for file in files:
        result = result + "  \"" + file + "\",\n"
    result = result + "\n"
print(result)

lua_file = open('dawn.lua', 'r')
content = lua_file.read()
lua_file.close()
content = get_platform_result(operating_sys, platform_lines)
content = re.sub('files {\n.*?--.*?src/dawn/native(.|\n)*?}', 'files {\n' + result + '}', content)
content = re.sub(r'_rtc_shim.*?\.', '.', content)

lua_file = open('dawn.lua', 'w')
lua_file.write(content)
lua_file.close()
