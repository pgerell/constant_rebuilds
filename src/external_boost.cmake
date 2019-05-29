include(ExternalProject)
set(Boost_NO_SYSTEM_PATHS ON)
set(XBOOST_MAJOR 1)
set(XBOOST_MINOR 69)
set(XBOOST_PATCH 0)

set(XBOOST_FILENAME "boost_${XBOOST_MAJOR}_${XBOOST_MINOR}_${XBOOST_PATCH}.tar.gz")
set(XBOOST_URL "https://dl.bintray.com/boostorg/release/${XBOOST_MAJOR}.${XBOOST_MINOR}.${XBOOST_PATCH}/source/${XBOOST_FILENAME}")

set(XBOOST_SHA256 "9a2c2819310839ea373f42d69e733c339b4e9a19deab6bfec448281554aa4dbb") #1.69.0

set(XBOOST_COMPILE_DEFINITIONS BOOST_REGEX_NO_LIB BOOST_CONFIG_SUPPRESS_OUTDATED_MESSAGE BOOST_DATE_TIME_NO_LIB)

# List of boost components that is required
set(BOOST_REQUIRED_COMPONENTS program_options
                              filesystem)

message(STATUS "Boost: using external project")

set(XBOOST_PREFIX "${CMAKE_CURRENT_BINARY_DIR}/external_boost")
set(BOOST_ROOT "${XBOOST_PREFIX}/boost_x")



  # Build arguments
if(MSVC)
  set(TOOLSET msvc)
  set(XBOOST_CONFIGURE_ARGS ./bootstrap.bat --with-toolset=${TOOLSET}
                            )
  set(XBOOST_BUILD_ARGS ./b2 toolset=${TOOLSET} 
                              address-model=64 
                              --prefix=${XBOOST_PREFIX}/boost_x
                              install -j8)
else()

  if ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
    # using Clang
    set(TOOLSET clang)
  elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
    # using GCC
    set(TOOLSET gcc)
  else()
    message( FATAL_ERROR "Unknown boost toolset ${CMAKE_CXX_COMPILER_ID}"  )
  endif()
  set(XBOOST_CONFIGURE_ARGS ./bootstrap.sh
                            --with-toolset=${TOOLSET}
                            --prefix=${XBOOST_PREFIX}/boost_x
                            )
  set(XBOOST_BUILD_ARGS ./b2 toolset=${TOOLSET} install -j8)
endif()

set(XBOOST_LIB_VERSION "${XBOOST_MAJOR}_${XBOOST_MINOR}")
if (NOT ${XBOOST_PATCH} EQUAL "0")
  set(XBOOST_LIB_VERSION "${XBOOST_LIB_VERSION}_${XBOOST_PATCH}")
endif()


foreach(BOOST_REQ_COMP ${BOOST_REQUIRED_COMPONENTS})
  list(APPEND XBOOST_BUILD_ARGS --with-${BOOST_REQ_COMP})
  if (MSVC)
    list(APPEND XBOOST_LIB_FILES ${BOOST_ROOT}/lib/libboost_${BOOST_REQ_COMP}-vc141-mt-gd-x64-${XBOOST_LIB_VERSION}.lib)
    list(APPEND XBOOST_LIB_FILES ${BOOST_ROOT}/lib/libboost_${BOOST_REQ_COMP}-vc141-mt-x64-${XBOOST_LIB_VERSION}.lib)
  else()
    list(APPEND XBOOST_LIB_FILES ${BOOST_ROOT}/lib/libboost_${BOOST_REQ_COMP}.a)
  endif()
endforeach(BOOST_REQ_COMP)


ExternalProject_Add(external_boost
    PREFIX        "${XBOOST_PREFIX}"
    # Download
    URL           ${XBOOST_URL} 
    URL_HASH SHA256=${XBOOST_SHA256}
    DOWNLOAD_DIR  "${CMAKE_SOURCE_DIR}/externals"
    BUILD_BYPRODUCTS ${XBOOST_LIB_FILES}
    # Build & Install
    LOG_BUILD 1
    BUILD_IN_SOURCE 1
    CONFIGURE_COMMAND ${XBOOST_CONFIGURE_ARGS}
    BUILD_COMMAND ${XBOOST_BUILD_ARGS} 
    INSTALL_COMMAND ${CMAKE_COMMAND} -E echo "Skipping cmake external project install step."
)

# Set up different variables that would have been setup by find_package, and
# is used by our build environment.
if(MSVC)
  set(Boost_INCLUDE_DIR ${BOOST_ROOT}/include/boost-${XBOOST_LIB_VERSION})
else()
  set(Boost_INCLUDE_DIR ${BOOST_ROOT}/include)
endif()

if(NOT TARGET Boost::boost)
  add_library(Boost::boost INTERFACE IMPORTED)
  set_target_properties(Boost::boost PROPERTIES
    INTERFACE_COMPILE_DEFINITIONS "${XBOOST_COMPILE_DEFINITIONS}"
  )
  #  target_include_directories(Boost::boost SYSTEM INTERFACE "${Boost_INCLUDE_DIR}")
  set_target_properties(Boost::boost PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${Boost_INCLUDE_DIR}"
    INTERFACE_SYSTEM_INCLUDE_DIRECTORIES "${Boost_INCLUDE_DIR}"
  )
  add_dependencies(Boost::boost external_boost)
endif()

foreach(BOOST_REQ_COMP ${BOOST_REQUIRED_COMPONENTS})
  # Create dependency targets
  add_library(Boost::${BOOST_REQ_COMP} UNKNOWN IMPORTED)
  if(MSVC)
    set_target_properties(
      Boost::${BOOST_REQ_COMP} PROPERTIES 
      IMPORTED_LOCATION_DEBUG ${BOOST_ROOT}/lib/libboost_${BOOST_REQ_COMP}-vc141-mt-gd-x64-${XBOOST_LIB_VERSION}.lib
      IMPORTED_LOCATION_RELEASE ${BOOST_ROOT}/lib/libboost_${BOOST_REQ_COMP}-vc141-mt-x64-${XBOOST_LIB_VERSION}.lib
      IMPORTED_LOCATION_RELWITHDEBINFO ${BOOST_ROOT}/lib/libboost_${BOOST_REQ_COMP}-vc141-mt-x64-${XBOOST_LIB_VERSION}.lib
      IMPORTED_LOCATION_MINSIZEREL ${BOOST_ROOT}/lib/libboost_${BOOST_REQ_COMP}-vc141-mt-x64-${XBOOST_LIB_VERSION}.lib
      INTERFACE_COMPILE_DEFINITIONS "${XBOOST_COMPILE_DEFINITIONS}"
    )
  else()
    set_target_properties(
      Boost::${BOOST_REQ_COMP} PROPERTIES
      IMPORTED_LOCATION ${BOOST_ROOT}/lib/libboost_${BOOST_REQ_COMP}.a
      INTERFACE_COMPILE_DEFINITIONS "${XBOOST_COMPILE_DEFINITIONS}"
    )
  endif()
  #  target_include_directories(Boost::${BOOST_REQ_COMP} SYSTEM INTERFACE "${Boost_INCLUDE_DIR}")
  set_target_properties(Boost::${BOOST_REQ_COMP} PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${Boost_INCLUDE_DIR}"
    INTERFACE_SYSTEM_INCLUDE_DIRECTORIES "${Boost_INCLUDE_DIR}"
  )
  add_dependencies(Boost::${BOOST_REQ_COMP} external_boost) 
endforeach(BOOST_REQ_COMP)

file(MAKE_DIRECTORY ${Boost_INCLUDE_DIR})

