# $Id: LFLCore.cmake 1335 2014-12-02 04:13:46Z justin $

set(BUILD_SHARED_LIBS OFF)

if(CMAKE_TOOLCHAIN_FILE)
  if(NOT IS_ABSOLUTE ${CMAKE_TOOLCHAIN_FILE})
    get_filename_component(CMAKE_TOOLCHAIN_FILE ${CMAKE_BINARY_DIR}/${CMAKE_TOOLCHAIN_FILE} ABSOLUTE)
  endif()
  if(NOT CMAKE_CROSSCOMPILING)
    include(${CMAKE_TOOLCHAIN_FILE})
  endif()
endif()

if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE "Debug")
endif()

if(CMAKE_BUILD_TYPE MATCHES Debug)
  set(LFL_DEBUG 1)
endif()

if(LFL_IOS OR LFL_ANDROID)
  set(LFL_MOBILE 1)
endif()

if(CMAKE_SYSTEM_NAME MATCHES "Darwin")
  set(LFL_APPLE 1)
endif()
  
if(LFL_EMSCRIPTEN)
  set(LFL_APP_OS app_null_os)
  set(LFL_APP_FRAMEWORK app_sdl_framework)
  set(LFL_APP_TOOLKIT)
  set(LFL_APP_GRAPHICS app_opengl_graphics)
  set(LFL_APP_REGEX app_stdregex_regex)
  set(LFL_APP_AUDIO app_openal_audio)
  set(LFL_APP_CAMERA app_null_camera)
  set(LFL_APP_CONVERT app_null_convert)
  set(LFL_APP_CRYPTO app_null_crypto)
  set(LFL_APP_FONT app_null_ttf)
  set(LFL_APP_GAME_LOADER app_simple_resampler app_simple_loader app_libpng_png app_null_jpeg app_null_gif)
  set(LFL_APP_MATRIX app_null_matrix)
  set(LFL_APP_CONVERT app_null_convert)
  set(LFL_APP_ADVERTISING)
  set(LFL_APP_BILLING)

elseif(LFL_ANDROID)
  set(LFL_APP_OS app_android_os)
  set(LFL_APP_FRAMEWORK app_android_framework)
  set(LFL_APP_TOOLKIT app_android_toolkit)
  set(LFL_APP_GRAPHICS app_opengl_graphics)
  set(LFL_APP_REGEX app_stdregex_regex)
  set(LFL_APP_AUDIO app_android_audio)
  set(LFL_APP_CAMERA app_null_camera)
  set(LFL_APP_CONVERT app_null_convert)
  set(LFL_APP_SSL app_openssl_ssl)
  set(LFL_APP_CRYPTO app_openssl_crypto)
  set(LFL_APP_FONT app_freetype_ttf)
  set(LFL_APP_GAME_LOADER app_simple_resampler app_simple_loader app_libpng_png app_null_jpeg app_null_gif)
  set(LFL_APP_MATRIX app_null_matrix)
  set(LFL_APP_CONVERT app_null_convert)
  set(LFL_APP_ADVERTISING app_android_admob)
  set(LFL_APP_BILLING app_android_billing)

elseif(LFL_IOS)
  set(LFL_APP_OS app_ios_os)
  set(LFL_APP_FRAMEWORK app_ios_framework)
  set(LFL_APP_TOOLKIT app_ios_toolkit)
  set(LFL_APP_GRAPHICS app_opengl_graphics)
  set(LFL_APP_REGEX app_stdregex_regex)
  set(LFL_APP_AUDIO app_ios_audio)
  set(LFL_APP_CAMERA app_avcapture_camera)
  set(LFL_APP_CONVERT app_iconv_convert)
  set(LFL_APP_SSL app_openssl_ssl)
  set(LFL_APP_CRYPTO app_commoncrypto_crypto)
  set(LFL_APP_FONT app_null_ttf)
  set(LFL_APP_GAME_LOADER app_simple_resampler app_simple_loader app_libpng_png app_libjpeg_jpeg app_null_gif)
  set(LFL_APP_MATRIX app_null_matrix)
  set(LFL_APP_CONVERT app_null_convert)
  set(LFL_APP_ADVERTISING app_ios_admob)
  set(LFL_APP_BILLING app_apple_billing)
  set(LFL_APP_NAG app_ios_nag)

elseif(CMAKE_SYSTEM_NAME MATCHES "Darwin")
  set(LFL_OSX 1)
  if(LFL_FLATBUFFERS)
    set(LFL_IPC 1)
  endif()
  set(LFL_APP_OS app_osx_os)
  set(LFL_APP_FRAMEWORK app_osx_framework)
  set(LFL_APP_TOOLKIT app_osx_toolkit)
  set(LFL_APP_GRAPHICS app_opengl_graphics)
  set(LFL_APP_REGEX app_stdregex_regex)
  set(LFL_APP_AUDIO app_openal_audio)
  set(LFL_APP_CAMERA app_null_camera)
  set(LFL_APP_CONVERT app_iconv_convert)
  set(LFL_APP_SSL app_securetransport_ssl)
  set(LFL_APP_CRYPTO app_commoncrypto_crypto)
  set(LFL_APP_FONT app_null_ttf)
  set(LFL_APP_GAME_LOADER app_ffmpeg_resampler app_ffmpeg_loader app_libpng_png app_libjpeg_jpeg app_null_gif)
  set(LFL_APP_MATRIX app_opencv_matrix)
  set(LFL_APP_CONVERT app_iconv_convert)
  set(LFL_APP_ADVERTISING)
  set(LFL_APP_BILLING)

elseif(WIN32 OR WIN64)
  set(LFL_WINDOWS 1)
  if(LFL_FLATBUFFERS)
    set(LFL_IPC 1)
  endif()
  set(LFL_APP_OS app_windows_os)
  set(LFL_APP_FRAMEWORK app_windows_framework)
  set(LFL_APP_TOOLKIT app_windows_toolkit)
  set(LFL_APP_GRAPHICS app_opengl_graphics)
  set(LFL_APP_REGEX app_stdregex_regex)
  set(LFL_APP_AUDIO app_openal_audio)
  set(LFL_APP_CAMERA app_directshow_camera)
  set(LFL_APP_CONVERT app_null_convert)
  set(LFL_APP_SSL app_openssl_ssl)
  set(LFL_APP_CRYPTO app_openssl_crypto)
  set(LFL_APP_FONT app_null_ttf)
  set(LFL_APP_GAME_LOADER app_ffmpeg_resampler app_ffmpeg_loader app_libpng_png app_libjpeg_jpeg app_null_gif)
  set(LFL_APP_MATRIX app_opencv_matrix)
  set(LFL_APP_CONVERT app_null_convert)
  set(LFL_APP_ADVERTISING)
  set(LFL_APP_BILLING)

elseif(CMAKE_SYSTEM_NAME MATCHES "Linux")
  set(LFL_LINUX 1)
  if(LFL_FLATBUFFERS)
    set(LFL_IPC 1)
  endif()
  set(LFL_APP_OS app_linux_os)
  set(LFL_APP_FRAMEWORK app_x11_framework)
  set(LFL_APP_TOOLKIT app_null_toolkit)
  set(LFL_APP_GRAPHICS app_opengl_graphics)
  set(LFL_APP_REGEX app_stdregex_regex)
  set(LFL_APP_AUDIO app_openal_audio)
  set(LFL_APP_CAMERA app_ffmpeg_camera)
  set(LFL_APP_CONVERT app_iconv_convert)
  set(LFL_APP_SSL app_openssl_ssl)
  set(LFL_APP_CRYPTO app_openssl_crypto)
  set(LFL_APP_FONT app_freetype_ttf)
  set(LFL_APP_GAME_LOADER app_ffmpeg_resampler app_ffmpeg_loader app_libpng_png app_libjpeg_jpeg app_null_gif)
  set(LFL_APP_MATRIX app_opencv_matrix)
  set(LFL_APP_CONVERT app_iconv_convert)
  set(LFL_APP_ADVERTISING)
  set(LFL_APP_BILLING)
endif()

set(LFL_APP_SIMPLE_LOADER app_simple_resampler app_simple_loader app_libpng_png app_null_jpeg app_null_gif)

if(CMAKE_SIZEOF_VOID_P EQUAL 8)
  set(LFL64 1)
elseif(CMAKE_SIZEOF_VOID_P EQUAL 4)
  set(LFL32 1)
else()
  message(FATAL_ERROR "Pointer size ${CMAKE_SIZEOF_VOID_P}")
endif()

include(ExternalProject)
include(BundleUtilities)
enable_testing()

set(PCH_PROJECT_SOURCE_DIR ${LFL_SOURCE_DIR})
set(PCH_PROJECT_BINARY_DIR ${LFL_BINARY_DIR})
include(${LFL_SOURCE_DIR}/core/imports/cmake-precompiled-header/PrecompiledHeader.cmake)

if(LFL_CCACHE AND NOT CCACHE_PROGRAM)
  if(LFL_WINDOWS)
    find_program(CCACHE_PROGRAM clcache)
  else()
    find_program(CCACHE_PROGRAM ccache)
  endif()
endif()

if(LFL_CACHE AND CCACHE_PROGRAM AND NOT LFL_WINDOWS)
  if(CMAKE_VERSION VERSION_LESS 3.4)
    set_property(GLOBAL PROPERTY RULE_LAUNCH_COMPILE "${CCACHE_PROGRAM}")
    set_property(GLOBAL PROPERTY RULE_LAUNCH_LINK "${CCACHE_PROGRAM}")
  else()
    set(CMAKE_C_COMPILER_LAUNCHER "${CCACHE_PROGRAM}")
    set(CMAKE_CXX_COMPILER_LAUNCHER "${CCACHE_PROGRAM}")
  endif()
endif()

if(LFL_CPACK)
  if(LFL_LINUX)
    if("$ENV{OS}" STREQUAL "ubuntu" OR "$ENV{OS}" STREQUAL "debian")
      set(CPACK_GENERATOR DEB)
    endif()
  endif()
  include(CPack)
endif()

list(APPEND CMAKE_MODULE_PATH ${LFL_SOURCE_DIR}/core/CMake)
include(LFLTarget)
include(LFLPackage)

if(LFL_IOS_SIM)
  add_custom_target(sim_start COMMAND nohup /Applications/Xcode.app/Contents/Developer/Applications/iOS\ Simulator.app/Contents/MacOS/iOS\ Simulator &)
endif()

if(LFL_WINDOWS)
  link_directories("")
  set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /SAFESEH:NO")
  FOREACH(flag CMAKE_C_FLAGS_RELEASE CMAKE_C_FLAGS_RELWITHDEBINFO CMAKE_C_FLAGS_DEBUG CMAKE_C_FLAGS_DEBUG_INIT
    CMAKE_CXX_FLAGS_RELEASE CMAKE_CXX_FLAGS_RELWITHDEBINFO CMAKE_CXX_FLAGS_DEBUG  CMAKE_CXX_FLAGS_DEBUG_INIT)
    STRING(REPLACE "/MD"  "/MT"  "${flag}" "${${flag}}")
    STRING(REPLACE "/MDd" "/MTd" "${flag}" "${${flag}}")
    SET("${flag}" "${${flag}} /EHsc /wd4244 /wd4018 /wd4305")
  ENDFOREACH()
else()
  if(LFL_CPP98)
  elseif(LFL_CPP11)
    set(CMAKE_CXX_STANDARD 11)
    set(CMAKE_CXX_STANDARD_REQUIRED ON)
    set(CMAKE_CXX_EXTENSIONS OFF)
    if(NOT LFL_ANDROID)
      set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -std=c++11")
      set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -std=c++11")
    endif()
  else()
    set(CMAKE_CXX_STANDARD 14)
    set(CMAKE_CXX_STANDARD_REQUIRED ON)
    set(CMAKE_CXX_EXTENSIONS OFF)
    if(NOT LFL_ANDROID)
      set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -std=c++14")
      set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -std=c++14")
    endif()
  endif()
  if(LFL_USE_LIBCPP)
    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -stdlib=libc++")
    set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -stdlib=libc++")
    #set(CMAKE_EXE_LINKER_FLAGS "-stdlib=libc++")
    #set(CMAKE_SHARED_LINKER_FLAGS "-stdlib=libc++")
    #set(CMAKE_MODULE_LINKER_FLAGS "-stdlib=libc++")
  endif()
  if(LFL_PIC)
    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -fPIC")
    set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -fPIC")
  endif()
endif()

if(LFL_XCODE)
  set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${LFL_BINARY_DIR}/out/library)
  set(CMAKE_XCODE_ATTRIBUTE_SKIP_INSTALL YES)
  set(CMAKE_XCODE_ATTRIBUTE_GCC_GENERATE_DEBUGGING_SYMBOLS YES)
  set(CMAKE_XCODE_ATTRIBUTE_GCC_WARN_64_TO_32_BIT_CONVERSION NO)
  set(CMAKE_XCODE_ATTRIBUTE_WARNING_CFLAGS "-Wno-overloaded-virtual -Wno-shorten-64-to-32 -Wno-unused-variable")
  if(LFL_DEBUG)
    set(CMAKE_XCODE_ATTRIBUTE_GCC_OPTIMIZATION_LEVEL "0")
  else()
    set(CMAKE_XCODE_ATTRIBUTE_GCC_OPTIMIZATION_LEVEL "2")
  endif()
  if(LFL_IOS)
    set(CMAKE_XCODE_ATTRIBUTE_SDKROOT iphoneos)
    set(CMAKE_XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET "${IOS_VERSION_MIN}")
  else()
    set(CMAKE_XCODE_ATTRIBUTE_MACOSX_DEPLOYMENT_TARGET "${OSX_VERSION_MIN}")
  endif()
endif()

# utility macros
macro(list_find_match _list _regex _out)
  set(${_out} -1)
  set(_ind 0)
  foreach(_current ${_list})
    if(_current MATCHES ${_regex})
      set(${_out} ${_ind})
      break()
    endif()
    MATH(EXPR _ind "${_ind}+1")
  endforeach()
endmacro()

macro(list_append_kv _list _key _val)
  list_find_match("${${_list}}" ^${_key}= ind)
  if (ind EQUAL -1)
    list(APPEND ${_list} "${_key}=${_val}")
  else()
    list(GET ${_list} ${ind} elm)
    list(REMOVE_AT ${_list} ${ind})
    list(APPEND ${_list} "${elm} ${_val}")
  endif()
endmacro()

macro(list_add_def _list _def)
  if(${_def})
    set(${_list} ${${_list}} -D${_def})
  endif(${_def})
endmacro()

macro(list_add_lib _deflist _inclist _def _inc)
  if(${_def})
    set(${_deflist} ${${_deflist}} -D${_def})
    set(${_inclist} ${${_inclist}} ${_inc})
  endif(${_def})
endmacro()

# proto vars
if(LFL_PROTOBUF)
  set(PROTOBUF_INCLUDE_DIR ${LFL_SOURCE_DIR}/core/imports/protobuf/src)
  if(NOT PROTOBUF_PROTOC_EXECUTABLE AND LFL_OS_CORE_BINARY_DIR)
    set(PROTOBUF_PROTOC_EXECUTABLE ${LFL_OS_CORE_BINARY_DIR}/imports/protobuf/protoc)
  endif()
endif()

if(LFL_FLATBUFFERS AND LFL_XCODE)
  set(FLATBUFFERS_BUILD_FLATC FALSE)
  set(FLATBUFFERS_BUILD_FLATHASH FALSE)
endif()

# imports
add_subdirectory(${LFL_SOURCE_DIR}/core/imports ${LFL_CORE_BINARY_DIR}/imports)

# proto macros
if(LFL_PROTOBUF)
  include(FindProtoBuf)
else()
  macro(PROTOBUF_GENERATE_CPP _s _h _f)
  endmacro()
endif()

if(LFL_FLATBUFFERS)
  set(FLATBUFFERS_INCLUDE_DIR ${LFL_SOURCE_DIR}/core/imports/flatbuffers/include)
  if(NOT FLATBUFFERS_FLATC_EXECUTABLE AND LFL_OS_CORE_BINARY_DIR)
    if(LFL_WINDOWS)
      set(FLATBUFFERS_FLATC_EXECUTABLE ${LFL_OS_CORE_BINARY_DIR}/imports/flatbuffers/${CMAKE_BUILD_TYPE}/flatc.exe)
    elseif(LFL_OSX AND LFL_XCODE)
      set(FLATBUFFERS_FLATC_EXECUTABLE ${LFL_OS_CORE_BINARY_DIR}/imports/flatbuffers/${CMAKE_BUILD_TYPE}/flatc)
    else()
      set(FLATBUFFERS_FLATC_EXECUTABLE ${LFL_OS_CORE_BINARY_DIR}/imports/flatbuffers/flatc)
    endif()
  endif()
  include(${LFL_SOURCE_DIR}/core/imports/flatbuffers/CMake/FindFlatBuffers.cmake)
  if(NOT FLATBUFFERS_FOUND)
    message(FATAL_ERROR "Missing flatbuffers")
  endif()
endif()

if(LFL_CAPNPROTO)
  set(CAPNP_LIB_KJ          ${LFL_CORE_BINARY_DIR}/imports/capnproto/lib/libkj.a)
  set(CAPNP_LIB_KJ-ASYNC    ${LFL_CORE_BINARY_DIR}/imports/capnproto/lib/libkj-async.a)
  set(CAPNP_LIB_CAPNP       ${LFL_CORE_BINARY_DIR}/imports/capnproto/lib/libcapnp.a)
  set(CAPNP_LIB_CAPNP-RPC   ${LFL_CORE_BINARY_DIR}/imports/capnproto/lib/libcapnp-rpc.a)
  set(CAPNP_INCLUDE_DIRS    ${LFL_CORE_BINARY_DIR}/imports/capnproto/include)
  if(NOT CAPNP_EXECUTABLE AND LFL_OS_CORE_BINARY_DIR)
    set(CAPNP_EXECUTABLE ${LFL_OS_CORE_BINARY_DIR}/imports/capnproto/bin/capnp)
  endif()
  if(NOT CAPNPC_CXX_EXECUTABLE AND LFL_OS_CORE_BINARY_DIR)
    set(CAPNPC_CXX_EXECUTABLE ${LFL_OS_CORE_BINARY_DIR}/imports/capnproto/bin/capnpc-c++)
  endif()
  include(FindCapnProto)
endif(LFL_CAPNPROTO)

# platform macros
macro(lfl_enable_qt)
  find_package(Qt5OpenGL REQUIRED)
  foreach(_current ${Qt5OpenGL_COMPILE_DEFINITIONS})
    set(QT_DEF ${QT_DEF} "-D${_current}")
  endforeach()
  set(QT_INCLUDE ${Qt5OpenGL_INCLUDE_DIRS})
  set(QT_LIB ${Qt5OpenGL_LIBRARIES})
endmacro()

macro(lfl_set_qt_toolkit _prefix)
  set(${_prefix}_GRAPHICS app_qt_graphics)
  set(${_prefix}_FRAMEWORK app_qt_framework)
  set(${_prefix}_TOOLKIT app_qt_toolkit)
endmacro()

macro(lfl_set_os_toolkit _prefix)
  if(LFL_LINUX AND LFL_QT)
    lfl_set_qt_toolkit(${_prefix})
  else()
    set(${_prefix}_GRAPHICS ${LFL_APP_GRAPHICS})
    set(${_prefix}_FRAMEWORK ${LFL_APP_FRAMEWORK})
    set(${_prefix}_TOOLKIT ${LFL_APP_TOOLKIT})
  endif()
endmacro()

# app
add_subdirectory(${LFL_SOURCE_DIR}/core/app ${LFL_CORE_BINARY_DIR}/app)
