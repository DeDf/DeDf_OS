
I/O PORTS : http://stanislavs.org/helppc/ports.html

http://www.nasm.us/pub/nasm/releasebuilds/2.12.02/win32/nasm-2.12.02-win32.zip

nasm boot\boot.asm
nasm boot\setup.asm 

kernel 编译选项选 x64

关闭GS开关: 项目属性->C/C++->代码生成->缓冲区安全检查（否）
忽略所有默认库: 项目属性->链接器->输入->忽略所有默认库（是）
修改入口点:     项目属性->链接器->高级->入口点（输入自定义函数名称 main）
修改image基址:  项目属性->链接器->高级->基址（0xffff800000000000）
固定基址:       项目属性->链接器->高级->固定基址（/FIXED）
合并数据段:     项目属性->链接器->高级->合并区（.rdata=.data）
//合并数据段:     #pragma comment(linker, "/MERGE:.rdata=.data")
//去除调试信息:   项目属性->链接器->调试->生成调试信息（否）

嵌入汇编:
右键项目->添加->xxx.asm文件
右键xxx.asm，属性
自定义生成步骤->常规:
  命令行(ml64 /c xxx.asm)
  输出(xxx.obj)

Debug版：
项目属性->基本运行时检查（默认值）

dedf_os.img 用winhex编辑的话，需要去掉img后缀名。

bochsdbg.exe->DeDf_OS.bxrc,
调试命令：
断点：b 0x7c00
运行：c
步入：s
步过：p
输入trace-reg on, 再执行单步调试的时候都会显示寄存器的当前状态了.
