# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 3.8

# Delete rule output on recipe failure.
.DELETE_ON_ERROR:


#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:


# Remove some rules from gmake that .SUFFIXES does not remove.
SUFFIXES =

.SUFFIXES: .hpux_make_needs_suffix_list


# Suppress display of executed commands.
$(VERBOSE).SILENT:


# A target that is always out of date.
cmake_force:

.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /Applications/CMake.app/Contents/bin/cmake

# The command to remove a file.
RM = /Applications/CMake.app/Contents/bin/cmake -E remove -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /Users/francisco/GitHub/vessel-detection-project/labeling_tool_v0.1.2

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /Users/francisco/GitHub/vessel-detection-project/labeling_tool_v0.1.2/build_osx

# Include any dependencies generated for this target.
include CMakeFiles/labeling_tool.dir/depend.make

# Include the progress variables for this target.
include CMakeFiles/labeling_tool.dir/progress.make

# Include the compile flags for this target's objects.
include CMakeFiles/labeling_tool.dir/flags.make

CMakeFiles/labeling_tool.dir/labeling_tool.cpp.o: CMakeFiles/labeling_tool.dir/flags.make
CMakeFiles/labeling_tool.dir/labeling_tool.cpp.o: ../labeling_tool.cpp
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/Users/francisco/GitHub/vessel-detection-project/labeling_tool_v0.1.2/build_osx/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Building CXX object CMakeFiles/labeling_tool.dir/labeling_tool.cpp.o"
	/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/c++  $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -o CMakeFiles/labeling_tool.dir/labeling_tool.cpp.o -c /Users/francisco/GitHub/vessel-detection-project/labeling_tool_v0.1.2/labeling_tool.cpp

CMakeFiles/labeling_tool.dir/labeling_tool.cpp.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/labeling_tool.dir/labeling_tool.cpp.i"
	/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -E /Users/francisco/GitHub/vessel-detection-project/labeling_tool_v0.1.2/labeling_tool.cpp > CMakeFiles/labeling_tool.dir/labeling_tool.cpp.i

CMakeFiles/labeling_tool.dir/labeling_tool.cpp.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/labeling_tool.dir/labeling_tool.cpp.s"
	/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -S /Users/francisco/GitHub/vessel-detection-project/labeling_tool_v0.1.2/labeling_tool.cpp -o CMakeFiles/labeling_tool.dir/labeling_tool.cpp.s

CMakeFiles/labeling_tool.dir/labeling_tool.cpp.o.requires:

.PHONY : CMakeFiles/labeling_tool.dir/labeling_tool.cpp.o.requires

CMakeFiles/labeling_tool.dir/labeling_tool.cpp.o.provides: CMakeFiles/labeling_tool.dir/labeling_tool.cpp.o.requires
	$(MAKE) -f CMakeFiles/labeling_tool.dir/build.make CMakeFiles/labeling_tool.dir/labeling_tool.cpp.o.provides.build
.PHONY : CMakeFiles/labeling_tool.dir/labeling_tool.cpp.o.provides

CMakeFiles/labeling_tool.dir/labeling_tool.cpp.o.provides.build: CMakeFiles/labeling_tool.dir/labeling_tool.cpp.o


# Object files for target labeling_tool
labeling_tool_OBJECTS = \
"CMakeFiles/labeling_tool.dir/labeling_tool.cpp.o"

# External object files for target labeling_tool
labeling_tool_EXTERNAL_OBJECTS =

labeling_tool: CMakeFiles/labeling_tool.dir/labeling_tool.cpp.o
labeling_tool: CMakeFiles/labeling_tool.dir/build.make
labeling_tool: /usr/local/lib/libopencv_videostab.2.4.13.dylib
labeling_tool: /usr/local/lib/libopencv_ts.a
labeling_tool: /usr/local/lib/libopencv_superres.2.4.13.dylib
labeling_tool: /usr/local/lib/libopencv_stitching.2.4.13.dylib
labeling_tool: /usr/local/lib/libopencv_contrib.2.4.13.dylib
labeling_tool: /usr/local/lib/libopencv_nonfree.2.4.13.dylib
labeling_tool: /usr/local/lib/libopencv_ocl.2.4.13.dylib
labeling_tool: /usr/local/lib/libopencv_gpu.2.4.13.dylib
labeling_tool: /usr/local/lib/libopencv_photo.2.4.13.dylib
labeling_tool: /usr/local/lib/libopencv_objdetect.2.4.13.dylib
labeling_tool: /usr/local/lib/libopencv_legacy.2.4.13.dylib
labeling_tool: /usr/local/lib/libopencv_video.2.4.13.dylib
labeling_tool: /usr/local/lib/libopencv_ml.2.4.13.dylib
labeling_tool: /usr/local/lib/libopencv_calib3d.2.4.13.dylib
labeling_tool: /usr/local/lib/libopencv_features2d.2.4.13.dylib
labeling_tool: /usr/local/lib/libopencv_highgui.2.4.13.dylib
labeling_tool: /usr/local/lib/libopencv_imgproc.2.4.13.dylib
labeling_tool: /usr/local/lib/libopencv_flann.2.4.13.dylib
labeling_tool: /usr/local/lib/libopencv_core.2.4.13.dylib
labeling_tool: CMakeFiles/labeling_tool.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --bold --progress-dir=/Users/francisco/GitHub/vessel-detection-project/labeling_tool_v0.1.2/build_osx/CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Linking CXX executable labeling_tool"
	$(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/labeling_tool.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
CMakeFiles/labeling_tool.dir/build: labeling_tool

.PHONY : CMakeFiles/labeling_tool.dir/build

CMakeFiles/labeling_tool.dir/requires: CMakeFiles/labeling_tool.dir/labeling_tool.cpp.o.requires

.PHONY : CMakeFiles/labeling_tool.dir/requires

CMakeFiles/labeling_tool.dir/clean:
	$(CMAKE_COMMAND) -P CMakeFiles/labeling_tool.dir/cmake_clean.cmake
.PHONY : CMakeFiles/labeling_tool.dir/clean

CMakeFiles/labeling_tool.dir/depend:
	cd /Users/francisco/GitHub/vessel-detection-project/labeling_tool_v0.1.2/build_osx && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /Users/francisco/GitHub/vessel-detection-project/labeling_tool_v0.1.2 /Users/francisco/GitHub/vessel-detection-project/labeling_tool_v0.1.2 /Users/francisco/GitHub/vessel-detection-project/labeling_tool_v0.1.2/build_osx /Users/francisco/GitHub/vessel-detection-project/labeling_tool_v0.1.2/build_osx /Users/francisco/GitHub/vessel-detection-project/labeling_tool_v0.1.2/build_osx/CMakeFiles/labeling_tool.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : CMakeFiles/labeling_tool.dir/depend

