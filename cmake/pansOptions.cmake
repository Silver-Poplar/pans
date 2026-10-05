# 创建一个接口库
add_library(pans_options INTERFACE)

target_compile_options(pans_options INTERFACE
    # GCC/Clang 通用选项
    $<$<OR:$<CXX_COMPILER_ID:GNU>,$<CXX_COMPILER_ID:Clang>>:
        -Wall
        -Wextra           # 额外警告（比 -Wall 更严格）
        -Wpedantic        # 严格遵循标准
        -fno-strict-aliasing
        -Wno-builtin-macro-redefined # 消除__FILE__重定义告警
    >
)

target_compile_options(pans_options INTERFACE
    $<$<AND:$<PLATFORM_ID:Linux>,$<OR:$<CXX_COMPILER_ID:GNU>,$<CXX_COMPILER_ID:Clang>>>:
        -fPIC       # 编译位置无关代码
    >
)

# 在链接可执行文件时，把所有符号（包括未使用的）加入动态符号表
# 这样程序在运行时进行栈回溯（backtrace）时，能通过符号名显示函数名，而不是只有地址
# 常用于需要打印调用栈的程序，比如崩溃处理、日志调试
target_link_options(pans_options INTERFACE
    $<$<AND:$<PLATFORM_ID:Linux>,$<OR:$<CXX_COMPILER_ID:GNU>,$<CXX_COMPILER_ID:Clang>>>:
        -rdynamic         # 栈回溯需要
    >
)

target_compile_definitions(pans_options INTERFACE
    $<$<CONFIG:Debug>:PANS_DEBUG>
)

target_compile_options(pans_options INTERFACE
    $<$<CONFIG:Debug>:-O0> # 关闭优化，编译最快，调试体验最好
    $<$<CONFIG:Debug>:-g3> # 生成最详细的调试信息，包括宏定义等
    $<$<CONFIG:Debug>:-ggdb> # 生成针对 GDB 的调试信息，通常与 -g 配合使用，让 GDB 体验更好
)

# ===== Release/RelWithDebInfo 共用选项 =====
target_compile_options(pans_options INTERFACE
    $<$<CONFIG:Release>:-DNDEBUG># 关闭断言
    $<$<CONFIG:Release>:-O2>
    $<$<CONFIG:Release>:-fno-omit-frame-pointer>

    $<$<CONFIG:RelWithDebInfo>:-DNDEBUG>
    $<$<CONFIG:RelWithDebInfo>:-O2>
    $<$<CONFIG:RelWithDebInfo>:-g> # 生成调试信息
    $<$<CONFIG:RelWithDebInfo>:-fno-omit-frame-pointer>
)

# ===== 覆盖率选项（默认关闭） =====
# 定义一个默认关闭的覆盖率开关 ENABLE_COVERAGE，当它开启时，
# 在 Debug 配置下为 pans_options 接口库添加覆盖率编译和链接选项
option(ENABLE_COVERAGE "Enable code coverage instrumentation" OFF)
if(ENABLE_COVERAGE)
    target_compile_options(pans_options INTERFACE
        # 在每个函数中插入计数代码，记录该函数/分支是否被执行。
        # 生成 .gcno 文件（编译时），记录基本块和跳转信息。
        $<$<CONFIG:Debug>:--coverage>
    )
    target_link_options(pans_options INTERFACE
        $<$<CONFIG:Debug>:--coverage>
    )
endif()
