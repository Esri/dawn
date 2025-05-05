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

include_files = {
    "src/dawn/" : set(),
    "src/tint/" : set(),
}

# FIle names that are platform specific but have parent directories that are shared between platforms. We need to handle these differently.
special_file_names = ["_mac.", "Windows", "windows", "linux", "posix", "SpirvValidation", "Surface_metal", "IOSurfaceUtils", "X11"]
special_file_names_vulkan_linux = [
    "src/dawn/native/vulkan/external_memory/MemoryServiceImplementationDmaBuf.cpp",
    "src/dawn/native/vulkan/external_memory/MemoryServiceImplementationOpaqueFD.cpp",
    "src/dawn/native/vulkan/external_semaphore/SemaphoreServiceImplementationFD.cpp",
]
special_files = []
special_file_linux = []

# Exclude the files that are in these parent directories.
excludes = ["src/dawn/wire", "src/dawn/utils", "/glsl/", "src/tint/cmd"]
# Exclude parent directories that belong to other platforms.
for target_os, includes in os_includes.items():
    if target_os != os:
        for include in includes:
            if not include in os_includes[os]:
                excludes.append(include)

# If overwriting, remove all current includes that have parent directories that are listed in include files and os_includes.
# This allows you to start "fresh" by removing potentially any old includes that are not used anymore.
# If not overwriting, it will update the include_files dictionary so that they are present files are not overwritten.
def prepare(): 
    lua_file = open('../dawn.lua', 'r')
    content = lua_file.read()

    if overwrite:
        all_parents = set(include_files.keys())
        for key, value in os_includes.items():
            all_parents.update(value)

        for parent in all_parents:
            regex = r'(?m)(-- {}.*?\n)^\ *\"(.|\n)*?((  --)|(}}))'.format(parent)
            regex_pattern = re.compile(regex)
            content = re.sub(regex_pattern, r'\1' + r'\3', content)

        lua_file.close()
        lua_file = open('../dawn.lua', 'w')
        lua_file.write(content)
        lua_file.close()

        for include in os_includes[os]:
            include_files[include] = set()

    else:
        for include in os_includes[os]:
            include_files[include] = set()

        for parent_path in include_files:
            regex = r'(?m)-- {}.*\n((^\ *\".*\",\n)*?)\n((\ *-- )|(\ *}}))'.format(parent_path)
            regex_pattern = re.compile(regex)
            match = re.search(regex, content)
            if match != None:
                files = match.group(1)
                regex = re.compile(r'(?m)^ *\"(src/.*?)\",.*')
                files = re.sub(regex, r'\1', files)
                include_files[parent_path] = set(files.splitlines())

# Read in the compile_commands.json file and group by their parent directories.
def file_to_list():
    compile_commands = open('temp_compile_commands', 'r')
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
            if line in special_file_names_vulkan_linux:
                special_file_linux.append(line)
                found = True
            for exclude in excludes:
                if exclude in line:
                    found = True
                    break
            if not found:
                # We need to iterate over the dictionary in reversed order so that the files specific to the platform will
                # be added to their specific group instead of the groups shared by all platforms.
                for parent_path, parent_files in reversed(include_files.items()):
                    if parent_path in line:
                        parent_files.add(line)
                        break

def create_lua_string(lines, whitespace):
    result = ""
    lines.sort()
    for line in lines:
        result = result + whitespace + "\"" + line + "\",\n"
    return result

def update_lua_file():
    lua_file = open('../dawn.lua', 'r')
    content_new = lua_file.read()

    for parent_path, parent_files in include_files.items():
        whitespace = "  "
        if parent_path.startswith("/"):
            whitespace = "    "
        to_insert = create_lua_string(list(parent_files), whitespace)
        regex = r'(?m)(-- {}(.|\n)*?)(^\ *\"(.|\n)*?)*?((  --)|(}}))'.format(parent_path)
        regex_pattern = re.compile(regex)
        content_new = re.sub(regex_pattern, r'\1' + to_insert + r'\n\5', content_new)
    
    # Deal with platform specific special files that share common parent directories.
    # Add them to their OS group.
    special_area =""
    if os == "windows":
        special_area = "win"
    if os == "macos":
        special_area = "apple"
    if os == "linux":
        special_area = "linux"
        # Linux has some special Vulkan files
        to_insert = create_lua_string(special_file_linux, "    ")
        content_new = re.sub(r'(if \(enable_vulkan\) then(.|\n)*?if \(_PLATFORM_LINUX\) then(.|\n)*?files {{\n)(.|\n)*?}}', r'\1' + to_insert + '  }', content_new)
    to_insert = create_lua_string(special_files, "    ")
    content_new = re.sub(r'(if \(enable_{}\) then(.|\n)*?files {{\n)(.|\n)*?}}'.format(special_area), r'\1' + to_insert + '  }', content_new)

    lua_file = open('../dawn.lua', 'w')
    lua_file.write(content_new)
    lua_file.close()


prepare()
file_to_list()
update_lua_file()

