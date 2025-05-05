# Updating the Dawn third party library

In this folder, are some tools to automate some of the process of updating the Dawn library. They should help you update `dawn.lua` and create shim files needed by Windows. There could be some extra steps needed that will be explained further down.

## Pre checks

Before running the script, check that all rtc dependencies are up to date in `variables.sh`. These are copied from runtimecore so may need updating.

## Usage

The `update_lua_file.sh` script does most of the work. You will have to manually run it on each OS: Windows, MacOS and Linux. The order of operating systems does not matter. 

The 1st time you run the script, run these commands:

```
cd ~/"your_development_directory/3rdparty/dawn/dawn_update_tools/
./update_lua_file.sh -o
```

Note the `-o` flag. This removes all the current file includes from the main files includes and some of the platform specific includes. This allows the script to remove any stale includes that are not needed anymore.

This script will do the following:

1) Remove all shim files (files with _rtc_shim_some_number in the file name) and rename any file names in `dawn.lua` that include the shim name to their original file names.
2) Create a temporary folder where we will create the build files using Dawn's CMake build system. This allows it to create the `compile_commands.json` file that lists the files that need to be included in `dawn.lua`.
3) Use the `compile_commands.json` file to populate the includes in `dawn.lua`.
4) Run `shim_script.sh` to find all files in `dawn.lua` that have the same name and add the rtc_shim_number ending to them. The create those files and add an include to the original file.
5) Remove all temporary files and directories.

Now run these commands to check if there are any build failures:
```
cd ~/"your_development_directory/runtimecore/runtimecore_scripts/scripts
./create_build.sh -3 -f & ./build.sh -3 -c
```
If this build try building a project that uses dawn.
Once Dawn and runtimecore builds, commit the changes and push them up to origin. Move to the next operating system and get the updated branch and run these slightly different commands:
```
cd ~/"your_development_directory/3rdparty/dawn/dawn_update_tools/
./update_lua_file.sh
```

These are the same commands as before but without the -o flag. Running without this flag keeps all previous includes in `dawn.lua` and only adds any extra ones that are needed. This exists as some platforms share file includes, this stops one operating system removing a file that is needed by another platform.

## Fixing build and linking errors

There might be build or link erros, these could be to a wide range of reasons:

### C++20 errors
Currently, Dawn uses C++17 in its build system but runtimecore uses c++20. If there are build errors that is a possible reason why.

### Linking failures
If there are missing symbol errors, this could be due to Dawn's dependencies also needing to be updated. Look at what library is causing that error and try updating that first and then try building Dawn again.

### Windows SDK 
If there are failures on Windows or in the D3D12 or D3D folders, it might be due to the Windows SDK. Runtimecore is currently using version ... but Dawn requires version ... . This has been ok so far as a possible work around could be to define the value that is missing manually. See ...the name of the struct thing... for previous work arounds.

### New include directories / changes to directories
If dawn added new folders they might need to be included in the scripts. If you find that dawn requires some files that are in a directory not in cluded in `dawn.lua` add the path files to the `os_includes` if platform specific or `include_files` dictionaries in the `file_splitter.py` python script.

### New "special" files
This build error could occur when running the script on the next OS. The previous OS adds a file to the includes shared by other operating systems but it is only found on the first. To fix this, add the special file name to the the `special_file_names` list in `file_splitter.py`. This will cause the script to only add this file only to the includes of the operating systems that have it.

