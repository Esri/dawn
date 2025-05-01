#!/usr/bin/env python

import sys
import re

os = sys.argv[1]
overwrite = int(sys.argv[2])

os_includes = {
    "linux" : ["/vulkan/", "/spirv/"],
    "macos" : ["/metal/", "/msl/"],
    "windows" : ["/vulkan/", "/spirv/", "/d3d/", "/d3d12/", "/hlsl/"]
}

parent_paths = {
    "src/dawn/" : set(),
    "src/tint/" : set(),
}

# file names that are platform specific but are in the common area
special_file_names = ["_mac.", "Windows", "linux", "posix", "SpirvValidation", "Surface_metal"]
special_files = []

excludes = ["src/dawn/wire", "src/dawn/utils", "/glsl/", "src/tint/cmd"]
for target_os, includes in os_includes.items():
    if target_os != os:
        for include in includes:
            if not include in os_includes[os]:
                excludes.append(include)

def prepare():
        
    lua_file = open('dawn.lua', 'r')
    content = lua_file.read()

    if overwrite:
        all_parents = set(parent_paths.keys())
        for key, value in os_includes.items():
            all_parents.update(value)

        for parent in all_parents:
            regex = r'(?m)(-- {}.*?\n)^\ *\"(.|\n)*?((  --)|(}}))'.format(parent)
            regex_pattern = re.compile(regex)
            content = re.sub(regex_pattern, r'\1' + r'\3', content)

        lua_file.close()
        lua_file = open('dawn.lua', 'w')
        lua_file.write(content)
        lua_file.close()

        for include in os_includes[os]:
            parent_paths[include] = set()

    else:
        for include in os_includes[os]:
            parent_paths[include] = set()


        for parent_path in parent_paths:
            regex = r'(?m)-- {}.*\n((^\ *\"(.|\n)*?)*?)((  -- )|(}}))'.format(parent_path)
            regex_pattern = re.compile(regex)
            match = re.search(regex, content)
            files = match.group(1)
            if files != None:
                print("match")
                regex = re.compile(r'(?m)^ *\"(src/.*?)\",.*')
                files = re.sub(regex, r'\1', files)
                parent_paths[parent_path] = set(files.splitlines())
            else:
                print("no match")


# Seperate the files we want to include into their parent directories
# It will be dependent on the OS
# The files that are common to all the operating systems will be put into the global dictionary
def file_to_list():
    compile_commands = open('temp_file', 'r')
    compile_commands = compile_commands.read()
    if os == "windows":
        compile_commands = re.sub(r'\\\\', '/', compile_commands)
    lines = compile_commands.splitlines()

    regex = re.compile('\"file\": \".*/dawn/(src/.*)\",')
    platform_paths = os_includes[os]

    for line in lines:
        line = line.rstrip('\n')
        match = re.search(regex, line)
        if(match != None) :
            line = match.group(1)
            found = False
            for special_file_name in special_file_names:
                if special_file_name in line:
                    special_files.append(line)
                    found = True
                    break
            for exclude in excludes:
                if exclude in line:
                    found = True
                    break
            if not found:
                # need to iterate over the dictionary in reversed order so that the specific os paths will be added to their
                # correct area instead of the common area
                for parent_path, parent_files in reversed(parent_paths.items()):
                    if parent_path in line:
                        parent_files.add(line)
                        break

def create_string(lines, whitespace):
    result = ""
    lines.sort()
    for line in lines:
        result = result + whitespace + "\"" + line + "\",\n"
    return result

def update_lua_file():
    lua_file = open('dawn.lua', 'r')
    content_new = lua_file.read()

    for parent_path, parent_files in parent_paths.items():
        whitespace = "  "
        if parent_path.startswith("/"):
            whitespace = "    "
        to_insert = create_string(list(parent_files), whitespace)
        regex = r'(?m)(-- {}(.|\n)*?)(^\ *\"(.|\n)*?)*?((  --)|(}}))'.format(parent_path)
        regex_pattern = re.compile(regex)
        content_new = re.sub(regex_pattern, r'\1' + to_insert + r'\n\5', content_new)
    
    # deal with edge cases
    special_area =""
    if os == "windows":
        special_area = "win"
    if os == "macos":
        special_area = "apple"
    if os == "linux":
        special_area = "linux"

    to_insert = create_string(special_files, "    ")
    content_new = re.sub(r'(if \(enable_{}\) then(.|\n)*?files {{\n)(.|\n)*?}}'.format(special_area), r'\1' + to_insert + '  }', content_new)

    lua_file = open('dawn.lua', 'w')
    lua_file.write(content_new)
    lua_file.close()


prepare()
to_print = parent_paths["src/tint/"]
for x in to_print:
    print(x)
file_to_list()
update_lua_file()

