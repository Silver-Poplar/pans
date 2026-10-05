# 递归收集当前目录及子目录下的 C/C++ 源文件和头文件
# file(GLOB_RECURSE <变量名> [CONFIGURE_DEPENDS] [<匹配模式>...])
file(GLOB_RECURSE PANS_SOURCES CONFIGURE_DEPENDS *.cpp *.cc *.c)
file(GLOB_RECURSE PANS_HEADERS CONFIGURE_DEPENDS *.h *.hpp)

add_library(pans STATIC ${PANS_SOURCES} ${PANS_HEADERS})


# 公共头文件使用 C++20；让下游目标通过 pans::pans 自动继承该要求，
# 任何链接 pans 的目标也必须使用 C++20。
target_compile_features(pans PUBLIC cxx_std_20)

# 为 pans 库设置了正确的头文件包含路径，公共头文件在构建时用源码树路径、
# 安装后用安装路径，并传递给使用者；私有头文件只在编译库自身时使用，不对外暴露
target_include_directories(pans
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/src
)

# 继承选项接口库pans_options所有编译/链接选项
target_link_libraries(pans PUBLIC pans_options)

target_compile_options(pans PRIVATE
    # 主库可能需要更严格的警告
    $<$<OR:$<CXX_COMPILER_ID:GNU>,$<CXX_COMPILER_ID:Clang>>:
        -Werror          # 将警告视为错误（主库严格要求）
    >
)

# 安装 pans 库文件到 lib（或 bin），并把目标登记到导出集合 pansTargets
install(TARGETS pans
    EXPORT pansTargets
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

install(DIRECTORY include/ DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
