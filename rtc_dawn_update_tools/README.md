# Updating the Dawn third party library

The `update_lua_file` script automates some of the process of updating the Dawn library. It updates the file includes in
`dawn.lua` and updates shim files which are needed by Windows. The script does the following:

1. Removes all shim files (files with \_rtc_shim\_"number" in the file name) and replaces any shim file includes in
   `dawn.lua` to their original file names.
2. Creates a temporary folder where build files will be written using the CMake build system.
3. Creates the dawn build. Uses the generated `compile_commands.json` to populate the file includes in `dawn.lua`.
4. Runs `shim_script.sh` to find all source files included in `dawn.lua` that have the same name (case and file
   extension insensitive) and adds the `rtc_shim_"number"` ending to them. It then creates files with those names and an
   include to the original file.
5. Removes all temporary files and directories.

## Shim files

The Dawn library contains many source files that have the same name. This confuses the premake/lua build system on
windows currently used by RTC, which assumes each translation unit has a unique file name, discarding the leading path.

E.g. both the following source files lead to a .o file written to to the same output location. One will overwrite the
other.

```lua
  "src/tint/lang/core/ir/function.cc",
  "src/tint/lang/wgsl/ast/function.cc",
```

To remedy this, the runtimecore branch introduces "shim" files with unique names which simply include the original. We
build the shim file which results in uniquely named .o files.

E.g.:

```lua
  "src/tint/lang/core/ir/function.cc",
  "src/tint/lang/wgsl/ast/function_rtc_shim1.cc",
```

where the content of "src/tint/lang/wgsl/ast/function_rtc_shim1.cc" is simply:

```cpp
  #include "function.cc"
```

This conflict is case and suffix insensitive. E.g. the following files lead to conflicting .o files:

```lua
 "src/dawn/native/Texture.cpp",
 "src/tint/lang/core/type/texture.cc",
```

## Pre-requisites

Before running the script, check that all listed RTC dependencies in `rtc_dawn_update_tools/variables.sh` are up to
date, they have been manually copied from RTC so may need updating.

- The version numbers are taken from `runtimecore/runtimecore_scripts/scripts/install_dependencies/variables.yml`.
- The Windows `visual_studio_install_paths` list is taken from
  `runtimecore/runtimecore_scripts/scripts/platform_helper.sh`.

The update script is only run manually so the variables do not need to be updated for Dawn to build successfully.

## Usage

Run `update_lua_file.sh` on each operating system: Windows, MacOS and Linux, the order of execution does not matter. On
the first operating system, run these commands:

```
cd ~/"your_development_directory"/3rdparty/dawn/rtc_dawn_update_tools
./update_lua_file.sh -o
```

Note the `-o` flag, this should only be used on the first platform the script is being run on.

Run these commands to check if there are any build failures:

```
cd ~/"your_development_directory"/runtimecore/runtimecore_scripts/scripts
./create_build.sh -3 -f & ./build.sh -3 -c
```

Fix any errors and build a project that uses Dawn. Once Dawn and RTC builds, commit the changes to a new branch and push
them up. On the next operating system, pull the updated branch and run these commands:

```
cd ~/"your_development_directory/3rdparty/dawn/rtc_dawn_update_tools
./update_lua_file.sh
```

These are the same commands as before but without the `-o` flag. This makes any changes to `dawn.lua` additive only, so
that files that were added by the script on the previous operating systems are not removed. Repeat the process of
building Dawn and RTC. Repeat the whole process again for the last operating system.

### `-o` Flag

Some file includes are used by all the platforms while others are only used by some or one platform. The `-o` flag makes
the script overwrite most includes in `dawn.lua` only with those in `compile_commands.json` so that files that are not
needed or don't exist anymore are removed. Without this flag, changes are additive only. This design allows for changes
by the previous operating system to not be overwritten by the current one.

For example, if you run the script first on MacOS with the `-o` flag, it will remove unneeded files from the Metal and
MSL section, and clear all the Vulkan, SPIRV, HLSL and DirectX sections since it does not use any files in those
directories. When you run the script on the next platform, it will populate its specific sections with only the files it
needs. The same would happen if Windows or Linux was used first, the MSL and Metal sections would be empty until it was
ran on MacOS. Note that specific platform files (those found in the `enable_"platform_name"` section in `dawn.lua`) are
only altered by its corresponding operating system as these files are not shared. For example, if you run the script on
MacOS, it will alter the `enable_apple` section but won't make any changes to the sections marked by `enable_linux` or
`enable_win`, no matter which order you run the script or if you use the `-o` flag or not.

## Build and link errors

Errors might occurr when building Dawn or RTC after updating `dawn.lua` on any of the operating systems. Here are some
common problems you might experience.

### C++20 errors

Currently, Dawn's build system uses C++17 while RTC uses C++20. You can build Dawn with the CMake build system with
C++17 and then with C++20 to see if you can reproduce the error.

### Linking erros

`Undefined symbol` errors could suggest that some of Dawn's dependencies also need to be updated, check which library is
causing the error and update it.

### Windows SDK

If there are failures on Windows, it might be due to the Windows SDK. At the time of writing, RTC uses version
`10.0.19041.0` but Dawn requires version `10.0.22621.0`. There could be possible work arounds for errors relating to
this, one example is in `src/dawn/native/d3d12/D3D12Info.cpp`. There is a manual definition of a missing struct at the
top of the file.

### Changes to directories

New directories might be added to Dawn and might need to be explicitly added to the scripts. If you find that Dawn
requires some files that are in a directory not included in `dawn.lua`, in `rtc_dawn_update_tools/file_splitter.py`, add
the path to the `os_includes` dictionary if it is platform specific or into the `include_files` dictionary if it's not.

### New "special" files

When updating `dawn.lua` on the second or third operating system, an error mentioning a not found file could occur. This
could be caused by the previous operating system inserting a file into `dawn.lua` that other operating systems will then
include but shouldn't. Add the special file name to the `special_file_names` list in
`rtc_dawn_update_tools/file_splitter.py`. The script will then add that file to the section marked by
`if enable_"platform_name"` for the corresponding operating system.

### Android

In `dawn.lua` there is a seperate section for Android file includes, the update script does not modify these. If the
Android vTest fails, check the test output to find where the error occurrs and add any necessary file includes into
`dawn.lua` manually.
