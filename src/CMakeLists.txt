set(Boost_USE_STATIC_LIBS ON)
set(BUILD_SHARED_LIBS OFF)
set_property(GLOBAL PROPERTY USE_FOLDERS ON)

cmake_minimum_required(VERSION 3.11)
project(constant_rebuilds)

set(CMAKE_CXX_STANDARD 14)

include(external_boost.cmake)

add_subdirectory(main)