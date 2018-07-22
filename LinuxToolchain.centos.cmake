set(LLVM_DIR /opt/rh/llvm-toolset-7/root/usr)

set(CMAKE_C_COMPILER ${LLVM_DIR}/bin/clang)
set(CMAKE_CXX_COMPILER ${LLVM_DIR}/bin/clang++)
set(CMAKE_AR ${LLVM_DIR}/bin/llvm-ar CACHE PATH "llvm archive")
set(CMAKE_RANLIB ${LLVM_DIR}/bin/llvm-ranlib CACHE PATH "llvm ranlib")
set(CMAKE_SIZEOF_VOID_P 8)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(USE_PRECOMPILED_HEADERS ON)
set(LFL_PIC ON)

set(ENV{CC} "${LLVM_DIR}/bin/clang")
set(ENV{CXX} "${LLVM_DIR}/bin/clang++")
set(ENV{CPP} "${LLVM_DIR}/bin/clang -E")
set(ENV{CXXCPP} "${LLVM_DIR}/bin/clang++ -E")
set(ENV{AR} "${LLVM_DIR}/bin/llvm-ar")
set(ENV{RANLIB} "${LLVM_DIR}/bin/llvm-ranlib")
