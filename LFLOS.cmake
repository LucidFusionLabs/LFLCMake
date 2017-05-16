# $Id: LFLOS.cmake 1335 2014-12-02 04:13:46Z justin $

if(NOT LFL_OS)
  if(APPLE)
    set(LFL_OS osx)
  elseif(UNIX)
    set(LFL_OS linux)
  elseif(WIN32 OR WIN64)
    set(LFL_OS win32)
  else()
    MESSAGE(FATAL_ERROR "unknown OS")
  endif()
endif()
