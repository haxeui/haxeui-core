#----------------------------------------------------------------
# Generated CMake target import file for configuration "RelWithDebInfo".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "nekovm" for configuration "RelWithDebInfo"
set_property(TARGET nekovm APPEND PROPERTY IMPORTED_CONFIGURATIONS RELWITHDEBINFO)
set_target_properties(nekovm PROPERTIES
  IMPORTED_LOCATION_RELWITHDEBINFO "${_IMPORT_PREFIX}/./neko.exe"
  )

list(APPEND _IMPORT_CHECK_TARGETS nekovm )
list(APPEND _IMPORT_CHECK_FILES_FOR_nekovm "${_IMPORT_PREFIX}/./neko.exe" )

# Import target "nekoc" for configuration "RelWithDebInfo"
set_property(TARGET nekoc APPEND PROPERTY IMPORTED_CONFIGURATIONS RELWITHDEBINFO)
set_target_properties(nekoc PROPERTIES
  IMPORTED_LOCATION_RELWITHDEBINFO "${_IMPORT_PREFIX}/./nekoc.exe"
  )

list(APPEND _IMPORT_CHECK_TARGETS nekoc )
list(APPEND _IMPORT_CHECK_FILES_FOR_nekoc "${_IMPORT_PREFIX}/./nekoc.exe" )

# Import target "nekotools" for configuration "RelWithDebInfo"
set_property(TARGET nekotools APPEND PROPERTY IMPORTED_CONFIGURATIONS RELWITHDEBINFO)
set_target_properties(nekotools PROPERTIES
  IMPORTED_LOCATION_RELWITHDEBINFO "${_IMPORT_PREFIX}/./nekotools.exe"
  )

list(APPEND _IMPORT_CHECK_TARGETS nekotools )
list(APPEND _IMPORT_CHECK_FILES_FOR_nekotools "${_IMPORT_PREFIX}/./nekotools.exe" )

# Import target "libneko" for configuration "RelWithDebInfo"
set_property(TARGET libneko APPEND PROPERTY IMPORTED_CONFIGURATIONS RELWITHDEBINFO)
set_target_properties(libneko PROPERTIES
  IMPORTED_IMPLIB_RELWITHDEBINFO "${_IMPORT_PREFIX}/./neko.lib"
  IMPORTED_LOCATION_RELWITHDEBINFO "${_IMPORT_PREFIX}/./neko.dll"
  )

list(APPEND _IMPORT_CHECK_TARGETS libneko )
list(APPEND _IMPORT_CHECK_FILES_FOR_libneko "${_IMPORT_PREFIX}/./neko.lib" "${_IMPORT_PREFIX}/./neko.dll" )

# Import target "nekoml" for configuration "RelWithDebInfo"
set_property(TARGET nekoml APPEND PROPERTY IMPORTED_CONFIGURATIONS RELWITHDEBINFO)
set_target_properties(nekoml PROPERTIES
  IMPORTED_LOCATION_RELWITHDEBINFO "${_IMPORT_PREFIX}/./nekoml.exe"
  )

list(APPEND _IMPORT_CHECK_TARGETS nekoml )
list(APPEND _IMPORT_CHECK_FILES_FOR_nekoml "${_IMPORT_PREFIX}/./nekoml.exe" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
