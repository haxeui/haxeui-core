# - Config file for the Neko package
# It defines the following variables
#  NEKO_INCLUDE_DIRS    - include directories for Neko
#  NEKO_LIBRARIES       - libraries to link against
#  NEKO_EXECUTABLE      - the Neko VM executable
#  NEKOC_EXECUTABLE     - the Neko compiler executable
#  NEKOML_EXECUTABLE    - the NekoML compiler executable
#  NEKOTOOLS_EXECUTABLE - the nekotools executable


####### Expanded from @PACKAGE_INIT@ by configure_package_config_file() #######
####### Any changes to this file will be overwritten by the next CMake run ####
####### The input file was NekoConfig.cmake.in                            ########

get_filename_component(PACKAGE_PREFIX_DIR "${CMAKE_CURRENT_LIST_DIR}/../" ABSOLUTE)

macro(set_and_check _var _file)
  set(${_var} "${_file}")
  if(NOT EXISTS "${_file}")
    message(FATAL_ERROR "File or directory ${_file} referenced by variable ${_var} does not exist !")
  endif()
endmacro()

macro(check_required_components _NAME)
  foreach(comp ${${_NAME}_FIND_COMPONENTS})
    if(NOT ${_NAME}_${comp}_FOUND)
      if(${_NAME}_FIND_REQUIRED_${comp})
        set(${_NAME}_FOUND FALSE)
      endif()
    endif()
  endforeach()
endmacro()

####################################################################################

# Our library dependencies (contains definitions for IMPORTED targets)
if(NOT TARGET neko)
  include("${PACKAGE_PREFIX_DIR}/CMake/NekoTargets.cmake")
endif()

# Use set instead of set_and_check, which doesn't handle lists properly
# https://gitlab.kitware.com/cmake/cmake/issues/16219
set(NEKO_INCLUDE_DIRS "${PACKAGE_PREFIX_DIR}/include")

# These are IMPORTED targets created by NekoTargets.cmake
set(NEKO_LIBRARIES libneko)
set(NEKO_EXECUTABLE nekovm)
set(NEKOC_EXECUTABLE nekoc)
set(NEKOML_EXECUTABLE nekoml)
set(NEKOTOOLS_EXECUTABLE nekotools)

check_required_components(Neko)
