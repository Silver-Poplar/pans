cmake_minimum_required(VERSION 3.31)
# 在 CMake 配置阶段，把 C 编译器和 C++ 编译器强制指定为
# /usr/bin/gcc 和 /usr/bin/g++，并写入 CMake 缓存
set(CMAKE_C_COMPILER "/usr/bin/gcc" CACHE FILEPATH "C compiler" FORCE)
set(CMAKE_CXX_COMPILER "/usr/bin/g++" CACHE FILEPATH "C++ compiler" FORCE)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS ON)

project(pans VERSION 0.1.0 LANGUAGES CXX C)
# 加载 GNUInstallDirs 模块，它会定义一套符合 GNU 习惯的标准安装目录变量
include(GNUInstallDirs)
# 加载 CMakePackageConfigHelpers 模块。它提供了一些辅助函数，
# 主要用来生成 CMake 包配置文件，让其他项目可以通过 find_package(MyLib) 找到你的库
include(CMakePackageConfigHelpers)

# option(<变量名> "<帮助文本>" [默认值])
option(PANS_BUILD_EXAMPLES "Build examples" on)
option(PANS_BUILD_TESTS "Build tests" on)
option(PANS_BUILD_TOOLS "Build tools" on)

if(NOT CMAKE_CONFIGURATION_TYPES AND NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Debug CACHE STRING "Choose the type of build." FORCE)
endif()
set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS Debug Release RelWithDebInfo MinSizeRel)
message(STATUS "Build Type: ${CMAKE_BUILD_TYPE}")

# 查询当前机器的逻辑 CPU 核心数，按核心数的 1.5 倍计算并行编译任务数，
# 并把它设置为 CMake 的 CMAKE_BUILD_PARALLEL_LEVEL 缓存变量，从而让后续构建自动并行编译
cmake_host_system_information(RESULT CPU_NUMS QUERY NUMBER_OF_LOGICAL_CORES)
message(STATUS "CPU NUMS on current server is: ${CPU_NUMS}")
math(EXPR JOBS "${CPU_NUMS} + ${CPU_NUMS} / 2")
set(CMAKE_BUILD_PARALLEL_LEVEL ${JOBS} CACHE STRING "并行编译线程数")
message(STATUS "Compiler default work jobs: ${CMAKE_BUILD_PARALLEL_LEVEL}")

include(cmake/pansOptions.cmake)
add_subdirectory(pans)
if(PANS_BUILD_TESTS)
    enable_testing()
    add_subdirectory(tests)
endif()
if(PANS_BUILD_TOOLS)
    add_subdirectory(tools)
endif()
