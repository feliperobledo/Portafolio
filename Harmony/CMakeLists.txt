# This is an example of a comment

# Tell CMake he minimum version required
cmake_minimum_required(VERSION 3.2.2)

# Tell CMake what's the project's name
project(Harmony)

# The version number.
set (Tutorial_VERSION_MAJOR 1)
set (Tutorial_VERSION_MINOR 0)

# Create an arbitrary subdirectory (project). This does not actually cause
# another cmake executable to run. The same process will walk through
# the project's entire directory structure.
add_subdirectory(Core)

#===============================================================================

# The following will create a library called "Hello" which will include
# "hello.cxx". Any number of sources could be listed here
add_library(Core Component.cxx Entity.cxx)

# The following will make sure the compiler can find the include files for Hello
# library when other libraries or executable link to Hello.
target_include_directories (Core PUBLIC $(CMAKE_CURRENT_SOURCE_DIR))

#===============================================================================
