# Locate and configure the Google Protocol Buffers library.
# Defines the following variables:
#
#   PROTOBUF_FOUND - Found the Google Protocol Buffers library
#   PROTOBUF_INCLUDE_DIRS - Include directories for Google Protocol Buffers
#   PROTOBUF_LIBRARIES - The protobuf library
#
# The following cache variables are also defined:
#   PROTOBUF_LIBRARY - The protobuf library
#   PROTOBUF_PROTOC_LIBRARY   - The protoc library
#   PROTOBUF_INCLUDE_DIR - The include directory for protocol buffers
#   PROTOBUF_PROTOC_EXECUTABLE - The protoc compiler
#
# Esben Mose Hansen <[EMAIL PROTECTED]>, (c) Ange Optimization ApS 2008
# Adapted by Philip Lowman <philip at yhbt.com> (c) 2009
#
# Redistribution and use is allowed according to the terms of the BSD license.
# For details see the accompanying COPYING-CMAKE-SCRIPTS file.
#
#====================================================================
# Example:
#
# find_package(Protobuf REQUIRED)
# include_directories(${PROTOBUF_INCLUDE_DIRS})
#
# include_directories(${CMAKE_CURRENT_BINARY_DIR})
# PROTOBUF_GENERATE_CPP(PROTO_SRCS PROTO_HDRS foo.proto)
# add_executable(bar bar.cc ${PROTO_SRCS} ${PROTO_HDRS})
# target_link_libraries(bar ${PROTOBUF_LIBRARY})
#
# NOTE: You may need to link against pthreads as well depending
# on the platform.
#====================================================================

IF (PROTOBUF_LIBRARY AND PROTOBUF_INCLUDE_DIR AND PROTOBUF_PROTOC_EXECUTABLE)
  # in cache already
  SET(PROTOBUF_FOUND TRUE)
ELSE (PROTOBUF_LIBRARY AND PROTOBUF_INCLUDE_DIR AND PROTOBUF_PROTOC_EXECUTABLE)

  FIND_PATH(PROTOBUF_INCLUDE_DIR stubs/common.h
    /usr/include/google/protobuf
  )

  FIND_LIBRARY(PROTOBUF_LIBRARY NAMES protobuf
    PATHS
    ${GNUWIN32_DIR}/lib
  )

  FIND_PROGRAM(PROTOBUF_PROTOC_EXECUTABLE protoc)

  INCLUDE(FindPackageHandleStandardArgs)
  FIND_PACKAGE_HANDLE_STANDARD_ARGS(protobuf DEFAULT_MSG PROTOBUF_INCLUDE_DIR PROTOBUF_LIBRARY PROTOBUF_PROTOC_EXECUTABLE)

  # ensure that they are cached
  SET(PROTOBUF_INCLUDE_DIR ${PROTOBUF_INCLUDE_DIR} CACHE INTERNAL "The protocol buffers include path")
  SET(PROTOBUF_LIBRARY ${PROTOBUF_LIBRARY} CACHE INTERNAL "The libraries needed to use protocol buffers library")
  SET(PROTOBUF_PROTOC_EXECUTABLE ${PROTOBUF_PROTOC_EXECUTABLE} CACHE INTERNAL "The protocol buffers compiler")

ENDIF (PROTOBUF_LIBRARY AND PROTOBUF_INCLUDE_DIR AND PROTOBUF_PROTOC_EXECUTABLE)

IF (PROTOBUF_FOUND)
#==================================================
# PROTOBUF_GENERATE_CPP (public function)
#   SRCS = Variable to define with autogenerated
#          source files
#   HDRS = Variable to define with autogenerated
#          header files
#   ARGN = proto files
#==================================================
function(PROTOBUF_GENERATE_CPP SRCS HDRS)
  if(NOT ARGN)
    message(SEND_ERROR "Error: PROTOBUF_GENERATE_CPP() called without any proto files")
    return()
  endif(NOT ARGN)

  set(${SRCS})
  set(${HDRS})
  foreach(FIL ${ARGN})
    get_filename_component(ABS_FIL ${FIL} ABSOLUTE)
    get_filename_component(FIL_WE ${FIL} NAME_WE)
   
    set(SRCI "${CMAKE_CURRENT_BINARY_DIR}/${FIL_WE}.pb.cc")
    set(HDRI "${CMAKE_CURRENT_BINARY_DIR}/${FIL_WE}.pb.h")

    list(APPEND ${SRCS} "${SRCI}")
    list(APPEND ${HDRS} "${HDRI}")

    if (NOT EXISTS "${SRCI}")
        file(WRITE "${SRCI}" "")
    endif()
    if (NOT EXISTS "${HDRI}")
        file(WRITE "${HDRI}" "")
    endif()

    add_custom_command(
      OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/${FIL_WE}.pb.cc"
             "${CMAKE_CURRENT_BINARY_DIR}/${FIL_WE}.pb.h"
      COMMAND ${PROTOBUF_PROTOC_EXECUTABLE}
      ARGS --cpp_out ${CMAKE_CURRENT_BINARY_DIR} --proto_path ${CMAKE_CURRENT_SOURCE_DIR} ${ABS_FIL}
      WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
      DEPENDS ${ABS_FIL}
      COMMENT "Running C++ protocol buffer compiler on ${FIL}"
      VERBATIM )
  endforeach()

  set_source_files_properties(${${SRCS}} ${${HDRS}} PROPERTIES GENERATED TRUE)
  set(${SRCS} ${${SRCS}} PARENT_SCOPE)
  set(${HDRS} ${${HDRS}} PARENT_SCOPE)
endfunction()
ENDIF(PROTOBUF_FOUND)

