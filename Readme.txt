
I/O PORTS : http://stanislavs.org/helppc/ports.html

http://www.nasm.us/pub/nasm/releasebuilds/2.12.02/win32/nasm-2.12.02-win32.zip

nasm boot\boot.asm
nasm boot\setup.asm 

kernel 编译选项选 x64

WDK7.1 ml64 Kernel\regs.asm，拷贝regs.obj到 Kernel 目录下

关闭GS开关: 项目属性->C/C++->代码生成->缓冲区安全检查（否）
忽略所有默认库: 项目属性->链接器->输入->忽略所有默认库（是）
修改入口点:     项目属性->链接器->高级->入口点（输入自定义函数名称 Init）
修改image基址:  项目属性->链接器->高级->基址（0xffff800000000000）
固定基址:       项目属性->链接器->高级->固定基址（/FIXED）
合并数据段:     项目属性->链接器->高级->合并区（.rdata=.data）
//合并数据段:     #pragma comment(linker, "/MERGE:.rdata=.data")
//去除调试信息:   项目属性->链接器->调试->生成调试信息（否）

嵌入汇编:
ml64 xxx.asm
把xxx.obj 拷贝到工程目录下，并加到  项目属性->链接器->输入->附加依赖项

Debug版：
项目属性->基本运行时检查（默认值）