基于RISC-V和Rust语言操作系统的设计与改进
摘要

第1章 绪论
1.1 背景
1.1.1 RISC-V的发展

1.1.2 Rust语言介绍：
Rust是一门新兴的系统编程语言，最初由Mozilla研究院的Graydon Hoare设计创造，致力于成为优雅解决高并发和高安全性系统问题的编程语言[1]。Rust是可以支持函数式、命令式以及泛型等编程范式的多范式语言，其在语法风格和C++类似，但是能够在保证性能的同时提供更好的内存安全。
Rust语言属于静态编译式语言，支持静态编译和动态编译，通过所有权和生命周期机制，使得使用Rust语言编写的程序能够避免空指针、野指针、内存越界、缓冲区溢出、段错误、数据竞争等一系列问题。Rust语言的编译器采用LLVM作为编译后端，使用Rust语言编写并完成自举，说明其实现具有充分的完备性。
1.1.3 FPGA的应用

1.2 研究目标

1.3 论文结构


第2章 研究现状与技术分析
2.1 RISC-V软核picorv32
2.1.1 picorv32概况
	picorv32是由著名IC工程师Clifford开发设计的CPU，其主要专注点在于小体积，高频率与低功率。该项目源码目前开源于GitHub，用户可遵顼ISC开源协议对其进行使用。
picorv32是一个用纯Verilog语言实现的RISC-V软核，其优点是体积小巧，占用资源少，运行频率高，支持多种模块的RISC-V指令集，并且能够通过预留接口对其功能进行拓展。
2.1.2 picorv32的性能分析
（1）CPU时钟周期数
	picorv32中执行每条指令所需的时钟周期数接近4。下表为具体每条指令执行所需的周期数。
Instruction	CPI	CPI(SP)
direct jump (jal)	3	3
ALU reg + immediate	3	3
ALU reg + reg	3	4
branch (not taken)	3	4
memory load	5	5
memory store	5	6
branch (taken)	5	6
indirect jump (jalr)	6	6
shift operations	4~14	4~15
MUL	40	40
MULH[SU|U]	72	72
DIV[U]/REM	72	72
	CPI---执行每条指令的周期数，开启双口读寄存器。
CPI(SP)---执行每条指令的周期数，单口读寄存器。
picorv32在器自搭建的嵌入式SoC系统中运行Dhrystone benchmark 基准测试程序结果为0.516 DMIPS/MHz (908 Dhrystones/Second/MHz)，Dhrystone benchmark 基准测试程序平均CPI 为4.100。
（2）CPU运行频率
	通过在Xlinx系列FPGA芯片上布局布线，分析得到picorv32所能够达到的最高频率如下表所示。
Device   	Device	Speedgrade	Clock Period (Freq.)
Xilinx Kintex-7T	xc7k70t-fbg676-2	-2	2.4 ns (416 MHz)
Xilinx Kintex-7T   	xc7k70t-fbg676-3	-3	2.2 ns (454 MHz)
Xilinx Virtex-7T   	xc7v585t-ffg1761-2	-2	2.3 ns (434 MHz)
Xilinx Virtex-7T   	xc7v585t-ffg1761-3  	-3	2.2 ns (454 MHz)
Xilinx Kintex UltraScale	xcku035-fbva676-2-e	-2	2.0 ns (500 MHz)
Xilinx Kintex UltraScale	xcku035-fbva676-3-e	-3	1.8 ns (555 MHz)
Xilinx Virtex UltraScale	xcvu065-ffvc1517-2-e	-2	2.1 ns (476 MHz) |
Xilinx Virtex UltraScale	xcvu065-ffvc1517-3-e	-3	2.0 ns (500 MHz)
Xilinx Kintex UltraScale+	xcku3p-ffva676-2-e  	-2	1.4 ns (714 MHz)
Xilinx Kintex UltraScale+	xcku3p-ffva676-3-e  	-3	1.3 ns (769 MHz)
Xilinx Virtex UltraScale+	xcvu3p-ffvc1517-2-e	-2	1.5 ns (666 MHz)
Xilinx Virtex UltraScale+	xcvu3p-ffvc1517-3-e	-3	1.4 ns (714 MHz)

（3）CPU体积与占用资源
通过在Xilinx 7-Series FPGA上布局布线得到Picorv3所消耗的资源如下表所示。
Core Variant	Slice LUTs	LUTs as Memory	Slice Registers
PicoRV32 (small)	716	48	442
PicoRV32 (regular)	917	48	583
PicoRV32 (large)	2019	88	1085
- PicoRV32 (small) : 不包含counter 指令、two-stage shifts、mem_radata锁存和未定义指令异常、地址对齐异常配置的picorv32。
- PicoRV32 (regular) : picorv32的默认配置，即所有的parameter参数使用默认值。
- PicoRV32 (large) : 包含PCPI、IRQ、MUL、DIV、 BARREL_SHIFTER、COMPRESSED_ISA的picorv32。
2.2  Rust语言的特点与优势
2.2.1 Rust语言的优势：
由于Rust语言是一个全新开发的高级语言，设计人员在开发过程中，借鉴过去近30年的语言理论研究和实际软件工程的经验进行设计。设计者为了持续追求“更好的设计和实现”，完全无历史包袱、无迁就，只要出现更好的设计或实现，经过深入讨论和评估之后，设计者们不会为了向前兼容而放弃改变。

2.2.2 C++语言的优缺点分析
C++语言是在项目编程领域中应用最为广泛的的语言。C++的应用场景多为编写接近实时高性能，稳健，并有足够开发效率的大程序。C++语言的优势在于：
（1）C++语言是接近底层的语言，具有接近实时且高性能的优点。在高级语言中，若需实现接近实时的性能，便不能存在垃圾回收机制。典型的例子为java、python等语言因为其垃圾回收机制导致其运行时的延迟。一个真实的场景为，若当前存在一个低延时交易程序在进行一个交易机会之后因为某种原因触发长达200ms的垃圾回收，将导致系统效率的低下。
（2）C++多语言范式为开发人员提供一系列基础的组件，如Vector、hashmap或者查找算法。高性能的目标可以用C语言达到，但若需考虑开发效率的问题，C语言的特性缺乏就是一个明显问题，开发者在开发的时候缺少数据结构基础设施。
（3）从开发效率和可读可维护性的层面上来说，高级语言必须具有足够的抽象能力，且抽象是没有运行时开销的。零开销抽象(zero cost abstraction)是C++语言的设计原则之一，inline函数，template等均遵循这一原则。 
（4）稳健的大程序则意味着程序要在进生产环境之前尽量消灭错误，并且为了达到这一目标，必要时可以牺牲一些开发效率。这就意味着高级语言需要具备一个静态类型，最好同时是强类型的语言，这能够使得编译器尽早发现问题。C++语言可通过编程技巧加强类型的检查，比如单参数构造函数最好加explicit。在此基础上，C++11还加入enum class以及各种override，final等，用以加强编译器在编译时查出错误的能力。
从上面的例子可以看出，C++语言从整体上看是一个高性能的静态强类型多范式语言。但在具备以上优点的同时，C++语言也存在这许多的问题。C++语言开发的目标之一是与C语言兼容，为了避免Python 2和Python 3的故事，甚至是IA64和x86_64的错误，设计人员不得不保证C++一直保持向前兼容。这是由于历史原因与设计人员当时抉择所看重的东西所导致的。
2.2.3 Rust语言与C++语言的比较
	Rust语言除具备2.2.2节所阐述的C++语言具备的优势外，还具有如下特点。
（1）无数据竞争的并发。Rust语言使用类似golang的基于通道的并发。在无需释放锁的前提下，开发和运行的逻辑简单且效率高。Rust中提供的函数式语言------pattern matching，可以有效避免数据竞争。此外，Rust还提供非常多的函数式语言特性，比如closure等。
（2）Generics和Trait实现zero cost abstraction，并且统一了编译时和运行时多态性，从而省去了不少程序语义方面的复杂性。因为没有runtime，所以与C语言的互通简单。
（3）Rust语言有灵活的enum系统，以及衍生的错误处理机制。错误通过enum返回，而没有exception。Rust的module系统以及pub和use关键字能使开发者控制所有的访问许可关系。
（4）Rust拥有强大的管理系统Cargo以及中心化的库管理crates.io。Cargo的依赖管理遵循最新的Semantic Versioning。开发者只需要选择适当的库依赖版本，通过cargo update命令即可自动完成所有版本匹配和下载加载。
（5）其它的特性，比如缺省可使用的直接打印数据的内容状态，更漂亮的条件编译，更好用的宏，rustdoc的自动文档生成，语言自带的简单测试系统。
（6）Rust语言最重要的特性是所有权和生命周期。Rust声称"prevents nearly all segfaults，and guarantees thread safety"。Rust里每一个引用和指针都有一个生命周期，对象不允许在同一作用范围内有两个可变引用。并且编译器在编译时就会禁止其被使用。
举例说明，C++中的to_string().c_str()方法会导致导致crash的严重后果，但是这种bug在Rust语言中能够被编译器识别并无法编译通过。正是源于这一特性，使得原本在C++里无法使用的优化做法变得具有可行性。比如若要将字符串分割成不同部分，并在不同的地方使用，当项目较大时，为了保障安全性，通常的做法是把分割的结果拷贝一份单独处理，这样便可避免在处理分割的字符串的时候原本的字符串已经不存在的问题。但是当我们使用Rust进程程序编写是，便可舍弃拷贝的环节，直接使用原来的字符串而不用担心出现野指针的情况，生命周期的设定可以让编译器完成这一繁琐的检查，如果有任何的字符串在处理分割结果之前被使用，编译器将会检查出此种错误。
由于Rust没有垃圾回收的控制，且其实现接近底层。在达到同样安全性的前提下，Rust并不会比C++慢。Rust拥有足够多的语言特性来保证开发的效率，并且比C++语言吸收了更多的现代优秀的语言特性。与C++一致的零抽象消耗。杀手级的所有权和生命周期机制，加上现代语言的类型系统。
总之，在语言层面上来说，Rust语言无疑是比C++优秀的一个高性能静态强类型多范式语言。
2.3 rCore教学操作系统
	rCore是基于清华大学教学操作系统uCore操作系统的Rust移植版本，致力于使用现代编程语言，以提升操作系统的开发体验和质量，并进一步探索未来操作系统的设计实现方式。目前rCore具有基本的内存管理、进程管理、文件系统功能，支持多种目标机器架构，如x86_64、RISCV32/64、AArch64指令集，能够在QEMU、Labeled-RISCV、K210开发板、树莓派3B+等多种平台上运行。
	本毕设实验将参考rCore操作系统的开发流程对其进行移植适配。
第3章 环境搭建与工具介绍
3.1 实验硬件平台
3.1.1 STEP FPGA开发板介绍
	STEP FPGA开发板，即小脚丫系列FPGA开发板，是由国内硬件平台设计开发公司------思得普信息科技有限公司发布的系列开发板。本实验主要使用其MAX10系列FPGA开发板作为硬件平台。STEP-MAX10是基于Altera公司芯片开发的FPGA开发板，板卡集成下载器，使用MicroUSB数据线可完成开发板的供电与下载。
其核心器件为Altera 10M08SAM153，板载资源如下表所示。
LE资源	80000个	RGB LED	2路
用户闪存	172KB	用户LED	8路
Block Memory	378Kbit	拨码开关	4路
PLL	2路	按键开关	4路
硬件乘法器	24路	用户可拓展IO	36个
GPIO接口	112个	Micro USB接口	1路
供电电压	3.3.V	JTAG编程接口	10pin
	
STEP MAX10 FPGA开发板实际图片如下所示。
 


 

3.1.2 开发环境搭建平台
	开发环境搭建系统为Ubuntu16.04和Windows10操作系统。
3.2 Verilog综合与仿真工具
3.2.1 Quartus
	Quartus为Intel公司发布的针对其旗下FPGA芯片Alteral进行综合实现的硬件开发软件。本实验采用Quartus Lite 18.1版本，并安装在Windows10操作系统中。
3.2.2 iverilog
	iverilog为可通过Linux终端运行的Verilog 模拟和合成工具。虽然可直接使用apt安装，但由于实验中需使用到与该源软件不兼容的Verilog特性，故需要自行下载iverilog 源代码编译安装。
3.2.3 gtkwave
	gtkwave是一个使用GTK的WAV文件波形察看工具，支持Verilog VCD/EVCD文件格式。通过在Ubuntu16.04终端中输入如下命令安装
	sudo apt-get install gtkwave
3.3 RISC-V交叉编译工具链	
3.3.1 交叉编译的难点分析
编译器运行的计算机环境称为host, 运行的新程序所使用的计算机称为target。当host和target是相同类型的计算机时, 编译方式是本机编译。当host和targt不同时, 编译方式是交叉编译。当前大多数机器编译主要针对x86架构和硬件平台作为开发环境，因此多为本地编译。
交叉编译的难点主要体现在如下两个方面。
（1）机器特性不同
字大小：字大小决定相关数据类型的位宽，如指针、整型数据等。
大小端：分为大端和小端，决定数据和地址的对应关系。
对齐方式：不同平台读取数据的方式不同，有些只能读取或写入对齐地址中的数据，否则将会出现访存异常。因此编译器会通过补齐结构的方式来对齐变量。
默认符号类型：不同平台对于某些数据类型默认是有符号还是无符号有不同的规定，如“char" 数据类型，解决方法是提供一个编译器参数, 如 "-funsigned-char", 以强制默认值为已知值。
（2）编译时的主机环境与目标环境不同
库支持：程序在交叉编译时，动态链接的程序必须在编译时访问相应的共享库。目标系统中的共享库需要添加到跨编译工具链中, 以便程序可以针对它们进行链接。对于特定平台下运行的程序，难以找到能够契合其硬件的库支持，因此需要根据现有库进行改写或自行编写简易库支持。
	由于实验所编写的软件将会运行于自行搭建的平台，即bare-mental的环境中。若直接使用本地编译的方式，程序将无法适配平台并正常运行，故无法使用本地编译环境对程序进行直接的编译。为此，在正式开始软件开发之前，需要为本地机器安装交叉编译环境，使编译出来的的程序能够运行于另一种体系结构的不同目标平台之下。
3.3.2 RISC-V交叉编译工具链介绍
riscv-gnu-toolchain:：RISC-V编译工具链，包括将源程序编译、汇编、链接为可执行文件的一系列工具。
riscv-gcc：GCC为gnu compiler colloction的缩写，即由GNU开发的一系列编译器集合，支持将多种高级语言编译为可执行文件的工具，riscv-gcc为高级语言程序或者RISC-V汇编程序编译为RISC-V架构的ELF文件的编译器。
实验中所用到的工具如下表所示。
名称	功能
as	GNU汇编器, 将汇编源代码，编译为机器代码
ld	GNU链接器，将多个目标文件，链接为可执行文件
ar	用于创建、修改库
addr2line	将ELF特定指令地址定位至源文件行号
objcopy	用于从ELF文件中提取或翻译特定内容，可用于不同格式二进制文件的转换。
objdump	用与查看ELF文件信息，反汇编为汇编文件等
readelf	显示ELF文件的信息
strip	用于将可执行文件中的部分信息去除，如debug信息，可在不影响程序正常运行的前提下减小可执行文件的大小以节约空间
riscv-gdb	用于调试RISC-V程序的调试工具
riscv-glibc	Linux系统下的RISC-V架构GNU C函数库
riscv-newlib	面向嵌入式系统的C语言库
riscv-qemu	RISC-V架构的机器仿真器和虚拟化器，可在其模拟的硬件机器上运行操作系统
riscv-isa-sim	spike模拟器 RISC-V ISA 的仿真器，功能类似于qemu
riscv-pk	运行于本地机器上的代理内核，是一个轻量级的应用程序执行环境，可直接运行与spike模拟器之中，然后加载运行静态链接的RISC-V ELF程序
bbl	Berkeley Boot Loader，此引导程序可用于在真实环境下加载操作系统内核
riscv-test	RISC-V官方的测试程序

3.3.3 RISC-V交叉编译工具链的安装
	RISC-V交叉编译工具链由RISC-V基金会进行维护，其源码托管于GitHub平台，通过下载源代码在Ubuntu中进行本地编译即可使用。
	执行如下命令安装本地编译所需依赖项
		$ sudo apt-get install autoconf automake autotools-dev curl libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev
	（1）下载GNU编译工具链源代码
		$ git clone --recursive https://github.com/riscv/riscv-gnu-toolchain
	（2）指定编译参数
		$ cd riscv-gnu-toolchain
		$ ./configure --prefix=/opt/riscv --with-arch=rv32gc --with-abi=ilp32d
	其中，configure脚本的各参数可选项如下：
	--prefix= 指定安装路径，若不指定则默认安装在当前路径。
--with-arch= 指定安装模块，rv32代表32位交叉编译工具链、rv64代表64位交叉编译工具链。RISC-V的子模块包括I、M、A、D、F、C，其中G模块为包含I、M、A、D、F的集合，若不指定则默认安装全部模块。
--with-abi= 指定abi，RISC-V的abi调用模式参考3.3.4节，若不指定则默认安装全部模式。
	（3）编译工具链源码
		$ make -j$(nproc)
执行make命令安装newlib作为C语言函数库的交叉编译工具链。
执行make linux命令安装glibc作为C语言运行库的交叉编译工具链。
安装完成后可在指定的路径中找到工具链的可执行文件。将该路径下的bin目录路径加入至PATH，以便在Terminal中直接通过工具链名称执行该程序。
查看该bin目录下的程序，可以看到程序均具有相同的前缀。不同工具链前缀不同，其区别如下：
riscv32-unknown-elf-gcc：针对于RISC-V32架构的编译器，使用的C运行库为newlib。
riscv64-unknown-elf-gcc：针对于RISC-V64架构的编译器，使用的C运行库为newlib。
riscv32-unknown-linux-gnu-gcc 针对于RISC-V32架构的编译器，使用的C运行库为linux中的标准glibc。
（4）下载spike和riscv-pk源码
		$ git submodule update --init --recursive
（5）导出变量
	$ export RISCV=riscv安装路径
（6）执行脚本编译
	$ ./build-rv32ima.sh
安装完成后,终端出现提示信息"RISC-V Toolchain installation completed!"
3.3.4 交叉编译工具链的测试
	（1）以Hello World程序为例，创建HelloWorld.c文件，其内容如下：
#incldue<stdio.io>
Int main() {
	Printf(“Hello World!\n”);
	Return 0;
}
通过如下命令编译文件。
		$ riscv32-unknown-elf-gcc -march=rv32i -mabi -mcmodel=medlow HelloWorld.c -o HelloWorld
	（2）编译参数含义如下
-march 指定编译的目标架构模块。
32位交叉编译工具链支持如下目标架构rv32gc (g = i[mafd])，
64位交叉编译工具链支持如下目标架构rv32(64) gc (g = i[mafd])
-mabi 指定编译的目标架构abi
32位交叉编译工具链支持以下 abi
ilp32:int, log, 指针是32 bits。GPRs 和堆栈用于参数传递。
ilp32f: int, long, 指针是32bits。GPRs、32位 FPRs 和堆栈用于参数传递。
ilp32d: int, long, 指针是32bits。GPRs、64位 FPRs 和堆栈用于参数传递。
64位交叉编译工具链在32位的基础上增加以下 abi
lp64: long, 指针是64bits。GPRs 和堆栈用于参数传递。
lp64f: long, 指针是64bits。GPRs、32位 FPRs 和堆栈用于参数传递。
lp64d: long, 指针是64bits。GPRs、64位 FPRs 和堆栈用于参数传递。
-mcmodel 指定目标代码模型。
目标代码模型指示对符号的约束, 编译器可以利用这些约束来生成更高效的代码。RISC-V目前定义以下两个代码模型:
-mcmodel = medlow：程序及其静态定义的符号必须位于一个2GB 地址范围内, 介于绝对地址-2 GB 和 + 2GB 之间。lui 和 addi 共同使用生成地址。
使用方式：
-mcmodel = medany：程序及其静态定义的符号必须位于单个4GB 地址范围内。auipc 和addi共同使用生成地址。
若不指定以上参数，编译器将使用默认值
虽然本地机器不能够直接运行该RISC-V程序，但通过RISC-V仿真模拟器spike和代理内核pk，即可在本地机器上运行riscv程序。
执行如下命令运行HelloWorld程序
$ spike pk HelloWorld
程序运行将执行并在终端输出信息 “Hello World!”。

3.4 Rust工具链的安装
	rustup工具是管理安装Rust官方版本工具链的二进制程序，可用于配置基于目录的 Rust 工具链。
	Cargo 是 Rust用于构建系统和进行包管理的工具，可实现构建项目，下载依赖，编译源码和包的三大功能。
	通过在Ubuntu终端执行如下命令即可安装。
		$ curl -sSf https://static.rust-lang.org/rustup.sh | sh
	选择自定义安装，并使用nightly版本，软件将默认安装到 $HOME/.cargo/bin 目录。
安装完成后，输入如下命令查看版本。
$ rustc –verison
出现如下带nightly后缀的版本即为安装成功。
rustc 1.0.0-nightly (f11f3e7ba 2015-01-04) (built 2015-01-06)
	使用nightly版本的原因为Rust语言有三种发布版本：nightly、beta、stable。nightly为每天发布的新版本特性，其功能不稳定、且可能在未来时间内被移除。beta为测试版本，定期从nightly版本中合并产生。stable为稳定版本，定期从beta版本中合并产生。因此，nightly版本代表当前Rust开发功能的前沿，具有很多stable版本无法使用的特性，而在编写操作系统等无需依赖标准库，故需要和汇编、C语言结合的底层软件时，使用nightly版本无疑是正确的选择。
	对Rust工具链进行测试，使用cargo构建项目，通过如下命令构建helloworld可执行文件项目。
$ Cargo new helloworld
其创建的目录结构如下
$ cd hello_world
    $ tree
    ├── Cargo.toml
    └── src
        └── main.rs
1 directory, 2 files
Cargo.toml文件为整个项目的信息，包括名称、使用的外部库依赖等信息
[package]
    name = "hello_world"
    version = "0.0.1"
authors = ["Your Name <you@example.com>"]
src/main.rs文件为项目主函数，项目将从此处开始运行，默认创建项目的main函数内容如下。
fn main() {
        println!("Hello, world!");
}
通过如下命名编译运行项目。
$ cargo run
       Compiling hello_world v0.0.1 
         Running `target/debug/hello_world`
Hello, world!
第4章 基于picorv32软核的SoC硬件平台搭建
4.1 picorv32实验复现
	下载picorv32仓库源代码
		$ git clone https://github.com/cliffordwolf/picorv32
	该仓库目录如下表所示。 
dhrystone	dhrystone是测量处理器运算能力的最常见基准程序之一，常用于处理器的整型运算性能的测量，此处为适配后的程序并用于测试picorv32。
firmware	firmware目录通过使用官网提供的测试用例tests搭建测试环境，主要针对picorv32指令的实现的正确性进行测试，其测试范围包括所有RISC-V整数模块和乘除法模块，也包括对中断异常，梅森素数C程序进行的测试，自行实现printf等输出库函数。
picosoc	针对Lattice系列型号开发板所开发的SoC，通过该SoC及配套程序测试对不同SPI读写模式下读取Flash数据的性能。
scripts	使用picorv32 CPU针对不同厂商，不同型号搭建的SoC
tests	RISC-V官方测试程序的移植
Makefile	运行测试的脚本
picorv32.v	该模块即为picorv32 CPU的所有verilog源码实现。其中包含多个模块，主要是在picorv32模块的基础上增添对外接口拓展，如AXI-Lite,WISHBONE等接口。
testbench.v   	对AXI 版本的picorv32进行测试，包括了SoC的实现源码。运行的程序是firmware。输入make test即可运行，其余参数可参考Makefle。
testbench_ez.v	对原生SRAM接口的picorv32进行测试。运行的程序是为简单的循环示例。输入make test_ez即可运行。
	
对运行firmware测试程序的SoC进行复现测试，该项目SoC布局如下图所示。
 
确保iverilog安装完成后，在根目录下运行如下指令。
$ make test
	复现结果如下图所示。

4.2 picorv32 CPU接口介绍
picorv32访存接口包括SRAM接口，AXI-Lite接口，WISHBONE接口等。所有接口CPU均为以原生访存接口CPU作为核心，再增加相应接口转换模块生成。使用者可以通过配置参数实现对CPU部件和功能的选择。

4.2.1 picorv32 SRAM接口
（1）SRAM接口信号定义如下表所示。
方向	宽度	名称
output	1	mem_valid
output	1	mem_instr
input	1	mem_ready
output	32	mem_addr
output	32	mem_wdata
output	4	mem_wstrb
input	32	mem_rdata

（2）SRAM接口时序
SRAM接口时序为CPU通过mem_valid启动数据传输。mem_valid信号一直保持高直到接收方将mem_ready信号置高，其余信号输出在mem_valid为高期间保持稳定。如果是指令访存，则将mem_instr置高。
在读取数据时，mem_wstrb值为0，mem_wdata 未使用。访存地址为mem_addr，当 mem_ready置高时，mem_rdata的数据有效。CPU可在给出mem_valid的在同一周期内，读取返回的数据。
在写入数据时，mem_wstrb为字节选择信号，mem_rdata 不使用。CPU将mem_wdata 的数据写入地址mem_addr。写入成功后，内存将mem_ready置高。
4.2.2 look ahead接口
look ahead接口提供比正常接口更早的内存传输信息，lookahead接口信号定义如下表所示。
方向	宽度	名称
output	1	mem_la_read
output	1	mem_la_write
output	32	mem_la_addr
output	32	mem_la_wdata
output	4	mem_la_wstrb

在mem_valid的置高的上一个时钟周期之前，该接口将会将mem_la_read或者 mem_la_write置高一个时钟周期，提前向内存指示下一个时钟周期的读写信息。

4.2.3 AXI-Lite接口
picorv32_axi_adapter 模块定义于picorv32.v 文件中，遵循AMBA AXI-Lite接口信号定义和使用标准，能够将picorv32原生SRAM访存接口转换为AXI-Lite接口。picorv32.v 文件将picorv32模块与picorv32_axi_adapter 模块封装为picorv32_axi模块。
4.2.4 WISHBONE接口
picorv32.v中的picorv32_wb模块对picorv32模块进行封装，并将其接口转换为WISHBONE接口。

4.2.5 PCPI接口
PCPI接口为picorv32的拓展接口。出于对小体积的追求，picorv32尽可能缩减了CPU的功能，同时通过提供拓展的形式使得用户能自行添加新功能。picorv32使用 Pico协处理器接口( PCPI ) 来实现用户自定义指令（分支指令类型除外）。
PCPI接口信号定义如下表所示
方向	宽度	名称
output	1	pcpi_valid
output	32	pcpi_insn
output	32	pcpi_rs1
output	32	pcpi_rs2
input	1	pcpi_wr
input	32	pcpi_rd
input	1	pcpi_wait
input	1	pcpi_ready

当遇到CPU内部不支持的指令时，若ENABEL_PCPI参数设置为1，则开启Pico协处理器模式。CPU将pcpi_valid信号置高，同时将该非法指令通过pcpi_insn输出，CPU将在内部对指令进行译码，并读取rs1和rs2寄存器的值输出至pcpi_rs1 和 pcpi_rs2 上。当协处理器执行指令完成时，将pcpi_ready信号置高，若需写入rd寄存器，则将结果写入pcpi_rd ，并将pcpi_wr信号置高，然后CPU将解析指令的rd字段，并将 pcpi_rd的值从写入对应的寄存器。当协处理器在16个时钟周期内没有给出pcpi_ready信号时，将触发非法指令异常，CPU将跳转至相应的中断处理程序。若协处理器需要多于16个时钟周期，则应提前将pcpi_wait信号置高，以避免引发非法指令异常。
4.3 SoC硬件平台功能的设计
4.3.1 外设功能的选择
	基于3.1.1节对STEP MAX10系列FPGA硬件平台资源的分析可知，SoC现有可用外设为LED、数码管、拨码开关和按键开关。可见SoC仍缺少可以直接用于与上位机进行交互和显示的外设。在众多的通信外设中，较为简单实用的设备为UART，为此，本次实验利用开发板中的36个用户可拓展IO口实现简易的UART设备接口，即选取2个IO口分别作为rx和tx信号接口，再加上板载5V VBus供电与GND接口，通过杜邦线与3.3V TTL转USB设备连接转换后，便可实现UART功能。
UART设备实际效果如下图所示。


4.3.2 地址空间的设计与分配
	基于picorv32搭建的SoC硬件平台地址空间分配如下表所示。
外设	地址分配	大小
ROM	0x0000_0000~0x0000_afff	44 KB
RAM	0x0001_0000~0x00010_fff	4 KB
UART	0x0200_0000~0x0200_001f	32 B
LED	0x0300_0000~0x0300_000f	16 B
Segment	0x0400_0000~0x0400_000f	16 B
SW	0x0500_0000~0x0500_000f	16 B


 



4.4 picorv32 IP核的封装
	Quartus软件为用户提供了系统集成工具Platform Designer（Qsys），用以自动生成互连逻辑来连接IP核和子系统。为方便使用Platform designer进行系统构建，并进一步拓展各部件的功能与实用性，可选择对picorv32封装为IP核，用以直接与SoC其余部件连接。Platform Designer官方IP核所定义的接口为Avolon接口，但同时也能够兼容AXI，AXI-Lite，AXI-Stream等一系列总线协议，使用以上总线接口的IP核皆可在Platform Designer中直接相互连接，由工具对部件各接口进行转换连接。
	使用Platform Designer中的new component功能建立新的AXI-Lite IP核。一般情况下，Platform Designer并不能直接认识所有信号定义，也无法将AXI-Lite总线中的信号与其余信号进行分类。根据Quartus Platform Degsigner用户手册[3]可知，Platform Degsigner可识别具有特定前缀的信号，并将其进行归类。各类别前缀对应的接口类型如下图所示。
 

	实验中主要使用的接口类型为AXI master，Conduit，Clock Sink，Interrupt receiver，Reset sink。可见，接口类型中并未对AXI-Lite接口前缀进行定义，所有使用AXI master前缀作为替代，也可实现信号分类功能，但仍需手动更改识别的接口类型并对齐接口中的每个信号。
为了让Platform Degsigner能够直接识别接口类型和自动分类，需要在picorv32-axi模块的基础上进行封装，将其接口名称按照Qsys对于AXI类型接口的命名规范进行命名，
其次可以去除picorv-axi中一些不必要的接口，仅留下时钟，复位，中断，AXI-Lite接口，其实现为picorv32_axi_wrapper.v文件。
添加对picorv32封装的picorv32_axi_wrapper.v和picorv32.v，此时需要将picorv32_axi_wrapper作为Top-level File，添加完成后综合文件。
 

系统无法自动对齐信号，需要自行选择接口和信号。
 

reset的signal type设置为reset_n，保证复位信号为低电平有效。
 

4.5 picorv32 CPU参数的配置
	picorv32可通过多个parameter参数配置其功能。
4.5.1指令集模块的配置
picorv32实现RISC-V IMC三个模块的指令，其中I模块为标准配置。
（1）M模块配置方式如下
ENABLE_MUL 默认值为0，需要使用乘法指令时则应将该参数设置为1。
ENABLE_DIV 默认值为0，需要使用除法指令时则应将该参数设置为1。
（2）C模块配置方式如下
COMPRESS_ISA 默认值为0，需要使用压缩指令集时则应将该参数设置为1。
4.5.2 中断支持的配置
ENABLE_IRQ 默认值为0，当需要支持中断处理时则应将该参数设置为1。
ENABLE_IRQ_QREGS  默认值为1，当不需要使用q0~q3寄存器时则应将该参数设置为0。若关闭IRQ_QREGS，则在处理中断时，根据RISC-V abi的规定，一般的C语言程序编译时将不会使用到global pointer 寄存器和thread pointer寄存器，故可将返回地址存储在x3（gp），中断掩码存储在x4（tp）之中。当ENABLE_IRQ的值为0时，q0~q3寄存器也无法使用。
ENABLE_IRQ_TIMER  默认值为1，当不需要时钟中断时则应将该参数设置为0。当ENABLE_IRQ的值为0时，时钟中断也无法使用。
MASKED_IRQ 默认值为32'h 0000_0000，其值对应需要屏蔽的IRQ掩码，需要和irq_mask寄存器中的值做与操作决定最终屏蔽的IRQ掩码。
LATCHED_IRQ 默认值为32'h ffff_ffff，当对应位为1时，表明与该位对应的irq外部输入信号将被锁存直至中断处理触发。
PROGADDR_RESET 默认值为32'h 0000_0000，其值为CPU启动时所执行的初始地址。
PROGADDR_IRQ 默认值为32'h 0000_0010，其值为CPU在发生中断时需跳转的地址。
STACKADDR 默认值为32'h ffff_ffff，其值与默认值不同时，将被设置为堆栈寄存器x2（sp）初始地址。RISC-V函数调用转换要求sp寄存器的值必须为16字节对齐。
ENABLE_PCPI 默认值为0，当需要支持外部协处理器时则应将该参数设置为1。
4.6 外设的添加
4.6.1 ROM 
	ROM模块用于存储运行程序，直接使用ROM IP核即可。位数选择32bits，大小选择11264 words。主要参数为无需锁存输出值，并使用Intel Hex格式文件对ROM IP和进行初始化。
4.6.2 RAM
	RAM模块作为数据的存储和堆栈区域，直接使用RAM IP核即可。位数选择32bits，大小选择1024 words。主要参数为不锁存数据，加如byteenable，当CPU同时读写同一地址时，返回新的数据，无需初始化。
4.6.3 UART
UART使用RS-232 IP核实现。主要参数为波特率115200，去掉Fixed baud rate的选项。根据Quartus IP核用户手册[4]可知，UART RS-232 IP核内部寄存器分配如下。
 

波特率的计算方法：
Divisor=(clock frequency)/(baund rate)-1
根据项目经验，若PLL IP核 input clock为12Mhz，output clock为50Mhz，baud rate为115200， 则
Divisor=12Mhz/115200=104

此时需要在程序中再次设置Divisor的值，而不是使用IP根据默认公式计算的Divisor值才能够让串口正常工作。
若pll 时钟IP核 input clock为50Mhz，output clock为50Mhz，baud rate为115200， 则
Divisor=50Mhz/115200=434

此时运行程序无需额外写Divisor，串口即可按照预先设定的波特率正常工作。
4.6.3 数码管
	数码管没有可直接使用的IP核，需使用PIO IP核输出需要数码管显示的二进制数值，然后使用Verilog编写Segment驱动模块，读取PIO 输出的二进制数值，并相应地将其译码为数码管显示所需的电平。
4.6.4 GPIO
	GPIO模块用于控制包括LED，按键开关，拨码开关等设备，可直接选择PIO IP核进行控制。LED的参数选择为输出8位。按键开关和拨码开关的参数选择输入8位。
4.6.7 PLL
	PLL IP核将输入时钟分频为所需的频率，此实验中输入频率为板载晶振频率12Mhz，选择输出的频率为50Mhz。
4.7 设备连接与地址分配
使用Platform Designer System Content连接各部件，按照4.3.2节的设计更改外设地址，更改外设名称，并添加对外接口。点击finish，并生成qsys文件。
4.8 顶层模块的设计
	将Platform Designer中生成pico_axi.qsys文件加入项目工程，并在顶层模块中对该文件进行例化，其例化示例在pico_axi_inst.v文件中，同时加入对数码管译码模块Segment的例化。
4.9 引脚与约束文件
	对项目进行综合后便需对引脚进行配置，根据STEP-MAX10 硬件手册[5]可知，数码管为共阴极数码管，LED为低电平点亮，各设备的引脚分配均可由手册查询，将rx和tx接入任意的GPIO引脚即可。
增加时钟约束，新建Synnopsys Design Constraint File，写入clock源时钟约束，其中12Mhz时钟的周期为83.33ns
4.10 编译下板
	编译前对启动方式进行配置，STEP MAX10开发板的Configuration Mode需选择带 With Memory Initialization的启动方式。
	对项目进行全编译，编译完成后，选择sof格式文件下板。用杜邦线将MAX10和3.3.V TTL转USB设备接口相连，并将TTLB转USB设备连接至电脑。打开串口助手，设置波特率为115200，即可看到程序运行的打印信息。
第5章 SoC硬件平台功能的测试
5.1 外设基本功能的测试
5.1.1 ROM功能的测试
	本实验使用ROM IP核作为SoC运行程序的存储部件。在项目中使用该IP核之前，需要确保ROM IP核能够在STEP MAX10开发板中正常工作，同时也需了解掌握程序的存放格式、初始化方法和读取方式。为此，在搭建基于picorv32的SoC之前，需额外搭建一个用于验证ROM IP核的项目，并对其功能进行测试。
	新建项目rom_test，该项目的主要内容为读取当前ROM IP核的输入字地址并显示于LED灯，读取对应地址的4字节指令，由于仅有两个数码管，最多可显示两个16进制数字即1个字节，所以使数码管将指令低字节显示出来。增加复位按键，复位时使输入ROM IP核的字地址初始化为0，同时增加按键检测，每当检测到另一按键的一次按动，则将字地址自增1。由于使用组合逻辑实现数码管译码功能，ROM IP核内部亦采用组合逻辑实现数据读取，所以下板后每当按动一次按键，则代表指令字地址值的LED灯二进制数加1，同时数码管显示ROM中该地址对于的指令字最低字节。
	使用自行编写的Hex格式对ROM IP核进行初始化，则在项目下板后即可通过比对Hex文件内容与数码管显示内容判断当前ROM IP核是否正常工作。
5.1.2 UART功能的测试
	本实验采用RS-232 IP核实现串口功能，并与上位机进行交互。在搭建完成SoC后，首先对UART功能进行测试，即编写运行于SoC的裸机程序，使其能够通过串口收发数据。首先编写简单的串口测试程序，主要功能为设置UART的Divisor数值，然后读取divisor并将其显示至数码管，循环往串口写入同一字符，同时判断status寄存器，是否从上位机接收到数据，若检测到数据则将该字符回显至终端。与此同时需要让LED在一段时间后不断变化，以判断下板后程序是否一直在运行。
5.2 RISC-V 官方测试的移植
为了确保SoC搭建的正确性，尤其是CPU功能的正确性，需要使用RISC-V官网测试用例对SoC功能进行验证。当前存在两种方式对RISC-V官方测试程序进行移植，第一种方式为直接下载RISC-V测试用例在GitHub仓库中的riscv-test项目，但此时需要搭建执行测试用例的执行代码环境。第二种方式是使用picorv32仓库中firmware作为执行测试用例的代码环境故，但需要根据平台差异对firmware进行移植适配。通过对工作量的权衡比较，选择采用第二种方式进行移植------以firmware目录下的测试程序为基准，对自行搭建的SoC进行适配。
主要修改内容包括根据外设地址（UART）进行修改，并将数据段复制至RAM中进行初始化。根据4.1节对firmware所运行的SoC平台的描述可知，该firmware程序的地址空间为64KB的RAM，UART地址为0x1000_0000。由于MAX10中的内存容量较小，无法将编译出来的firmware程序完全放置在ROM之中，故仍需firmware程序作出适当的剪裁。
首先去掉firmware目录下的所有C语言文件，即去除print功能，去除查找梅森素数的C语言程序sieve.c，去除对中断，异常进行处理的irq.c，去除multest.c，stats.c，同时在Makefile中将firmware目录下C文件生成的目标文件链接至ELF文件的代码去除。
其次，需要在start.S中去除调用这部分功能的代码（将文件开头ENABLE XXX的宏注释）。更改start.S中输出“DONE”信息部分代码的UART地址，即将0x10000000改为0x02000004；此外还需更改tests/riscvtest.h文件中输出TEST FUNC NAME处的串口地址和对于单条指令运行成功或失败时执行的代码部分。在原项目中，作者将RVTEST PASS宏和RVTEST FAIL宏设置为往串口输出“OK”，“ERROR“信息，故相应更改串口地址即可。出更改串口地址外，还需在每次写串口之前加入判断status寄存器trdy位的代码。
对firmware目录下sections.lds文件进行修改，可以看出该链接脚本直接将所有程序段放置在0x0000_0000 ~ 0x0000_c000的地址空间内。根据SoC地址空间分布，需将程序的可执行代码段和只读数据放置在 0x00000000 ~ 0x0000afff处 的ROM处，将数据段放置在 0x0001_0000 ~ 0x0001_0fff 处的RAM段。
此外，因为在对访存指令的测试中需要对内存段进行初始化，故需要将数据段的加载地址LMA放置在输出文件的text段中，即使用AT(ADDRESS)属性定义该.data程序段的加载位置。最后，在start.s文件开头读取ROM中内存数据并初始化至RAM中。
使用Makefile对程序进行编译，输入make firmware/firmware.bin文件生成二进制文件。此时仍可能出现如下错误，segmentation fault，提示信息为程序过大，无法完全放入ROM空间中。故说明无法一次性运行所有官方测试用例，此时可分四个批次对TEST的代码分别运行。通过更改根目录下的Makefile文件，将tests目录下的目标文件部分链接至firmware可执行文件中。此时执行make命令即可生成bin文件。
5.3 Intel Hex格式文件的生成方式
	Intel Hex文件可用于初始化ROM IP核，文件格式详见附录A，其本质为可执行程序代码段提取后加入地址、校验码并按照给定格式进行排列的文件。
若要将运行于SoC的源程序变为Hex文件，首先需使用RISC-V工具链可将汇编源文件和C语言等高级语言文件编译链接为ELF可执行文件。
对于汇编文件，使用如下命令将其编译为目标文件。
		$ riscv32-unknown-elf-gcc -c 汇编文件名 -o 输出文件名 -march=rv32im 
	对于C语言文件，使用如下命令将其编译为目标文件。
		$ riscv32-unknown-elf-gcc -c 输入文件名 -o 输出文件名 -march=rv32im -ffreestanding -nostdlib
	将所有目标文件同链接脚本编译为ELF文件，命令如下。
		$ riscv32-unknown-elf-gcc -c 输入文件名 -o 输出文件名 -march=rv32im -ffreestanding -nostdlib -Wl,-Bstatic,-T,链接脚本文件 -lgcc
	通过RISC-V工具链中的objdump提取ELF文件中的代码段数据，命令如下。
		$ riscv32-unknown-elf-objcopy -O binary -j .text ELF文件名 输出文件名。 
参数 -O用以指定输出文件的格式，binary表示输出文件为二进制文件。objcopy中自带的BFD库中支持Intel Hex格式，可通过-O参数指定，格式名称为ihex。但根据实际使用情况，当直接使用ihex格式时，输出文件的数据为小端序，若用于初始化以32bits字为单位的ROM IP核，则从ROM IP核中读取出来的数据的大小端则会相反。此外，其地址字段以字节为单位进行编址，若ROM IP指定为32bits的，则用于初始化的hex格式地址也应按字编址，而不是按字节编址。
因此需要自行编写软件将bin文件转换为hex格式，本实验通过两个程序对bin文件进行转换，其中bin2coe.py程序能将bin文件读入，然后转换为以32位指令为一行的data，并加入Start code，byte count，address，record type，命名为coe文件（不是标准coe）。coe2hex.c程序------将coe文件读入，然后计算并加入checksum。
5.4 调试的方法
在实际环境中，不管是硬件平台还是软件的功能实现都不可能一蹴而就。当程序运行时没有达到预期要求，便须对其进行调试。现将本实验过程中，对串口功能的调试方法介绍如下。
5.4.1 仿真环境下的调试
根据5.1.2 节UART的测试程序的功能设计可知，程序若正常运行，其预期效果应为数码管显示此时RS-232 IP核内部Divisor寄存器的值，LED灯循环发生变化，串口不断向上位机发送数据，上位机设置相应的波特率后可接收到预定的字符串。
首先在仿真环境下对该功能进行验证，编写testbench给SoC各接口激励信号。在testbench文件中设置输入时钟为12Mhz，即与STEP FPGA MAX10实验板上的晶振频率相同。若使用UART RS-232 IP核搭建环境，则其在仿真环境下默认的divisor为4，在程序中写入divisor后会变成设置的数值。在testbench中模拟上位机给rx接口发送数据，每一位符号的持续时间为 divisor*cycle。运行后，首先观察tx和led是否有变化，波形是否与预期的效果相同。若不相同，则检查此时程序运行的状态，若是程序的逻辑问题，如程序运行至地址范围之外或者陷入循环，则可使用objdump工具反编译ELF文件或者使用addr2line工具查看相应地址对应的源代码，以排除程序的问题。若程序能够正常运行，但是相应接口却没有输出信号或者信号值不对，则根据问题可以定位相应的硬件设备问题，比如tx的宽度与rx接收的宽度不相符，则是Divisor寄存器的问题。
5.4.2 真实环境下的调试
在仿真环境下程序能够正常运行并得到预期效果，下板后在真实环境下却未出现预期效果，则需考虑仿真和下板环境下可能出现的不同点在于何处。如程序下板后LED正常运行，且数码管显示的数值为按照手册公式计算的数值，但是上位机按照设置波特率接收数据时却显示为乱码。此时，可通过示波器查看引脚tx的信号波形，同时也可将其余信号如时钟接入预留IO口，引出至板外然后使用示波器查看。
若SoC中运行的程序在相同时间间隔内往tx引脚发送同样的数据，则示波器能够明显接收到稳定的信号波形。亦或者通过Trigger设置低电平触发，则运行后若有数据发送至tx，则示波器将捕捉此处发送的数据。tx引脚发送的高电平为3.3v，使用示波器对每一位符号的发送位宽进行测量，若tx每位信号位宽度为∆x，则串口发送的波特率计算公式为
baund rate=1/∆x
在真实环境中也可利用Quartus 自带的工具Signal Trap Logic Analyzer，下板后捕捉SoC内部的信号进行调试。
第6章 rCore操作系统的移植
	rCore操作系统RISC-V架构版本下的开发所针对的平台为Sifive公司发布的HiFive Unleashed开发板。若需将rCore移植至本实验所搭建的SoC硬件平台，则需要对操作系统中硬件支持部分进行更改。
6.1 picorv32的特权极架构
picorv32的特权级架构并未参照RISC-V Privilige ISA Specification中的规范进行实现。
为了使用尽可能少的硬件资源，作者通过实现自定义的指令集和CSR寄存器集对中断进行处理。
6.1.1 CSR寄存器
	CSR寄存器即控制状态寄存器，用于配置或记录CPU的运行状态。picorv332中定义的CSR寄存器如下表所示。
CSR	功能
q0	存储中断或异常返回地址，对应RISC-V标准CSR中的epc寄存器
q1
(irq_pending)	存储当前准备处理的中断号，当某位置为1时，表明与该位下标对应的中断触发，对应RISC-V标准CSR中的ip寄存器
q2	作为临时寄存器保存中间值，对应RISC-V标准CSR中的scratch
q3	作为临时寄存器保存中间值，对应RISC-V标准CSR中的scratch
irq_mask	中断屏蔽掩码，当某位置1时，表明与该位下标对应的中断将被屏蔽，不对其进行处理
timer	时钟计数器，每个时钟周期自减1，当其值变为0后触发时钟中断。若需重新触发，需要重新赋值
counter_cycle	周期计数器，每个时钟周期自增1
counter_insr	指令计数器，每执行一条指令自增1

6.1.2 特权极指令
	picorv32通过自定义指令方式对CSR寄存器进行访问或对中断进行处理。
（1）getq rd, qs
编码方式：0000000 ----- 000XX --- XXXXX 0001011
f7     rs2   qs    f3   rd   opcode
功能：该指令将通用寄存器中的值赋给qn 寄存器。
示例：getq x5, q2
（2）setq qd, rs
编码方式：0000001 ----- XXXXX --- 000XX 0001011
f7      rs2   rs    f3  qd    opcode
功能：该指令将qn 寄存器中的值赋给通用寄存器。
示例： setq q2, x5
（3）retirq
编码方式：0000010 ----- 00000 --- 00000 0001011
f7      rs2   rs    f3  rd    opcode
功能：该指令使程序从中断处理中返回，即将q0寄存器中的值赋给PC寄存器，同时重新开启中断。
示例： retirq
（4）maskirq
编码方式：0000011 ----- XXXXX --- XXXXX 0001011
f7      rs2   rs    f3  rd    opcode
功能：该指令将rs寄存器中的值写入irq_mask寄存器，同时将irq_mask的旧值返回至rd寄存器。
示例：maskirq x1, x2
（5）waitirq
编码方式：0000100 ----- 00000 --- XXXXX 0001011
f7      rs2   rs    f3  rd    opcode
功能：CPU暂停执行等待中断被挂起，当有中断触发时才会使CPU继续运行，无论该中断是否被处理。irq_pending的值将被写入rd寄存器。
示例：waitirq x1
（6）timer
编码方式：0000101 ----- XXXXX --- XXXXX 0001011
f7      rs2   rs    f3  rd    opcode
功能：设置timer寄存器的值，将rs的值赋给timer，同时将timer的旧值赋给rd。
示例：timer x1, x2
6.1.3 自定义指令的使用：
由于自定义类型指令无法通过GNU汇编器as进行编译，故需要通过宏定义方式对自定义类型指令进行编译。各自定义指令的宏定义如下表所示。
 


6.1.4 中断信号
	picorv32 CPU实现简易的内部中断控制器，该控制器接口如下表所示。
名称	方向	位宽	功能
irq	input	32	接入外部中断源
eoi	output	32	当进入CPU进入中断处理时，若将此次需处理的
中断号所对应的位置高，直到中断处理结束
trap	output	1	当CPU进入中断处理状态时，该位置为高
picorv32可处理32种中断，irq接口输入的每一位对应一种类型的中断。其中0-2 号中断能够被CPU内部所触发，其中断控制类型如下表所示。
IRQ	Interrupt Source
0	Timer Interrupt
1	EBREAK/ECALL or Illegal Instruction
2	BUS Error (Unalign Memory Access)

其余中断可由用户自定义。CPU一次可处理多个中断，CPU复位后所有中断将被默认关闭，timer寄存器也被默认清理。若在1~2号中断被屏蔽的情况下出现非法指令或者访存地址错误，将导致CPU停止运行。CPU在进入中断处理的过程中将自动关闭中断，直到执行irqret指令后自动开启中断。发生中断时，处理器需要跳转的地址为固定值，可通过参数PROGADDR_IRQ配置，其默认值为0x10,一旦配置成功便无法再此更改，除非重新综合布局SoC。
6.2 移植rCore操作系统的可行性分析
	目前硬件平台上所搭建的SoC可用的硬件资源包括378Kbit 的Block Memory，UART，GPIO, 数码管等。操作系统代码可存储至布局为ROM资源的Block Memory中，使得系统能够被CPU正常加载执行。与此同时，UART设备保证了操作系统基本的输入输出功能，便于用户与系统进行交互。最后，利用布局为RAM资源的Block  Memory保证了操作系统在运行时能够加载数据和设置堆栈等程序运行所必须的资源支持。
考虑到目前所持有的硬件资源较少，尤其是用于存储和加载程序的存储设备的局限性，无法支持将操作系统加载至RAM中进行运行，故将操作系统固化至ROM中，由CPU直接读取存储在ROM中的操作系统并直接运行，RAM资源则完全留作数据加载区域与堆栈分配区域，即硬件资源仅支持将rCore移植为嵌入式操作系统。对该嵌入式操作系统的功能设计如下：
（1）实现对硬件资源的抽象，通过编写驱动程序对基本输入输出设备进行管理。
（2）实现对中断和异常的处理。
（3）实现对存储资源的管理分配。
（4）实现对ELF格式的可执行用户程序进行解析和执行。
6.3 引导程序的设计
6.3.1 引导程序功能分析
	一般的引导程序功能为对硬件进行基本的初始化，并解析并加载操作系统内核至内存指定位置后跳转执行操作系统。由于本实验中引导程序的设计受如下两个基本限制：
（1）硬件存储资源局促，操作系统无法由ROM重新加载至RAM中执行。
（2）picorv32 CPU并未按照RISC-V Privilige Specification中对于特权极架构标准的要求进行实现。
为此引导程序按照如下方案进行设计：
（1）简化解析加载ELF格式操作系统内核的代码实现，将编译完成的操作系统内核程序的不同程序段转换为二进制文件直接并直接加载至引导程序特定位置，在编译引导程序时再一同编译。
（2）提供sbi接口（Supervisor Binary Interface）和中断处理。
6.3.2 RISC-V系统架构
典型的RISCV-系统架构如下图所示。
 

上图中各个英文缩写对应的全称如下：
ABI: Application Binary Interface
AEE: Application Execution Environment
SBI: Supervisor Binary Interface
SEE: Supervisor Execution Environment
HBI: Hypervisor Binary Interface
HEE: Hypervisor Execution Environment
RISC-V通过各层之间的Binary Interface实现了对下一层的抽象。此次实验所设计的操作系统遵循第二种模式，引导程序在此处充当SEE的角色。
6.3.2 引导程序运行流程
（1）引导程序代码段作为CPU执行的第一段代码，其起始地址将被放置在CPU启动地址处，即0x0000_0000。由于CPU的中断跳转地址设置在0x10处，引导程序的0x10处开始作为中断处理程序。本实验中直接使用无条件跳转指令跳过中断处理程序入口，转入初始化代码。
（2）初始化代码需要将32个通用寄存器初值设置为零。其次，加载程序的数据段和bss段至内存中作为内存初始化数据，bss数据段初值全部赋为零。
（3）设置UART设备的分频系数。
（4）初始化引导程序的堆栈寄存器sp、全局寄存器gp和线程寄存器tp。
其中，堆栈寄存器的值设置为RAM物理地址空间的地址最大值，由于堆栈的增长顺序为自高地址向低地址生长，故可有效避免堆栈溢出。
（5）引导程序打印“BOOT”信息，表明设备初始化完成。
（6）引导程序调用picorv32_maskirq_insn自定义指令设置irq_make寄存器的值，等同于开启中断，并通过ecall指令触发异常，进而检验当前中断是否已成功开启。
（7）引导程序调用picorv32_timer_insn自定义指令，设置时钟计数器的值为10000。
（8）引导程序进入循环点亮LED灯，每次循环均调用picorv32_waitirq_insn自定义指令等待时钟中断触发后再继续执行，循环8次后跳转至操作系统代码段开始执行。
（9）通过 .incbin伪指令将操作系统代码段直接加载到标号为text_payload_start处，同时也将该地址设置为引导程序代码段偏移0x1000的地址。
（10）通过 .incbin伪指令将用户可执行程序ELF文件放置在elf_payload_start标号处。
（11）引导程序数据段将预留32个字大小空间作为中断处理程序保存寄存器现场的堆栈，其开始地址为irq_regs标号。
（12）数据段预留128个字大小空间作为中断处理函数堆栈。
6.3.3 中断处理程序入口
（1）中断处理程序入口从地址为0x10处开始。由于启用了q0~q3，所以可使用q2 ~q3作为scratch来存储x1、x2寄存器的值，故通过picorv32_setq_insn自定义指令将x1和x2的值设置到q2和q3之中。
（2）中断处理程序将irq_regs赋给x1寄存器，irq_regs为RAM中分配给中断处理程序的地址，用以存储引发中断时各通用寄存器的值，并将中断返回地址存储在偏移量为0的地址处，其余寄存器按照下标存储在n*4偏移地址处。
（3）中断处理程序将irq_stack赋给sp寄存器，irq_stack为RAM中分配给中断处理程序的堆栈地址。
（4）中断处理程序将irq_regs和q1寄存器的值作为参数，并通过a0，a1寄存器传入，调用中断处理函数irq解析中断类型并做出相应处理。
（5）从中断处理函数irq返回后，中断处理程序将恢复中断现场，重新设置时钟计数器。
（6）调用picorv32_retirq_insn自定义指令返回原程序继续执行。
因为CPU进入异常模式时自动屏蔽中断，即不允许嵌套中断，故无需额外加入代码开关中断。
6.3.4 中断处理函数
中断处理函数使用C语言编写，其声明形式在firmware.h头文件中，实现在irq.c文件中。为避免跨平台导致的数据长度冲突，在头文件中加入对stdint.h的引用，则在编写程序时可直接使用C99标准库所定义的数据类型，而不使用gnu C标准库定义的数据类型。
（1）中断处理函数声明
中断处理函数声明形式为：
uint32_t * irq(uint32_t *regs, uint32_t irqs)
可见，irq函数需要传递两个参数，第一个参数为指向存储中断现场通用寄存器的内存指针，第二个参数为中断类型掩码。由6.3.3节可知，这两个参数分别通过a0和a1寄存器传入。中断处理函数返回值为指向存储通用寄存器的内存指针。
（2）判断中断类型
根据6.1.4节，系统中预设的中断信号类型共有3类，分别对应中断掩码中下标为0~2的位，其中0号位为时钟中断，1号位为异常指令EBREAK、ECALL和非法指令，2号位为访存地址不对齐异常。irq处理函数首先需要根据传入的irq掩码判断出具体的中断类型号，即依次比较判断相应位的值。
（3）时钟中断
对于1号时钟中断，系统设计的处理方式为通过全局静态变量存储时钟中断触发的次数，每次触发时钟中断时，便打印 “[TIMER-IRQ] + 时钟中断次数”字符串至终端。
（4）异常指令中断
对于2号异常指令中断，则需要进一步判断引发中断的原因。根据6.3.3节可知，存储中断现场通用寄存器的内存空间regs的0地址偏移处存储的值为中断处理程序返回地址，根据对异常的实现可知，对于ECALL、EBREAK一类的触发软中断的异常指令，其返回地址为触发软中断指令的下一条指令地址。故可通过计算得出异常指令地址，其计算方式如下：
uint32_t pc = (reg[0] & 1) ? regs[0] – 3 : regs[0] – 4;
pc的值即为异常指令地址，并以字为单位对齐。通过访问内存将该地址处的指令读取回来做进一步的判断。通过如下语句读取引发中断的指令，并存入instr变量中。
uint32_t instr = *(uint32_t *)pc；
此时根据RISC-V指令编码手册，比较instr的值即可判断出异常指令的类型。若为EBRAK指令，则instr的编码为0x001000073。若为ECALL指令，则instr的编码为0x00000073。否则可以判断该指令为非法指令。
（5）访存地址不对齐中断
对于3号访存地址不对齐中断，系统设计的处理方式为打印提示信息：“Bus Error“，然后停机等待重启。
（6）中断调试信息的打印。
由于传入的参数包括对存储通用寄存器的内存地址，可通过打印通用寄存器的值作为调试信息对软件进行调试，在遇到ebreak指令或者非法指令时将打印所有寄存器的值。通过两个循环语句，系统分别用下标访问存储通用寄存器的数组，并将其值以16进制形式打印，4个寄存器为一行打印。
6.3.5 串口驱动程序
操作系统通过串口与上位机进行交互，即通过串口向上位机发送数据，上位机接收后，通过串口工具进行显示，反之也可由串口工具向下位机发送数据，操作系统接收进行处理。串口功能直接通过Quartus RS-232 IP核实现，其配置和使用方式详见4.6.3节。驱动程序需访问和使用的寄存器包括rxdata、txdata、status寄存器，其偏移量分别为0、1、2，以字为单位。因为串口设备的基址为0x0200_0000，故分别对三个寄存器的基址的进行宏定义如下所示：
#define INPORT	 (*(volatile uint32_t*)0x02000000)	 //uart_rx
#define OUTPORT  (*(volatile uint32_t*)0x02000004)   //uart_tx
#define uart_status  (*(volatile uint32_t*)0x02000008)
由于寄存器以字为单位，故使用uint32_t类型的指针指向内存映射的UART设备寄存器。volatile关键字的使用是为了避免编译器对使用该变量值的地方做过多优化，例如在执行检查status寄存器中的发送允许位trdy时需执行循环等待，如下:
while(!(uart_status & 0x0040));
若未使用volatile关键字，则编译器在进行数据流分析时，将认定该循环中没有任何能够改变uart_status寄存器的语句，则会将该语句优化为
if(!(uart_status & 0x0040)) {
	for(;;);
}
显然此时编译器优化导致代码中循环判断status寄存器值的功能发生改变。通过volatile关键字即可使编译器在使用该变量时必须每次重新读取其值，而不是直接使用保存在寄存器中的备份。
（1）print_char函数的实现
printf_char函数的功能为向txdata寄存器发送数据，输入参数为需发送的字符，返回值为0。在发送数据之前，调用trdy函数判断当前UART的状态，若为可发送状态，则向txdata寄存器发送数据。此外，驱动程序还在print_chr函数的基础上，实现打印字符串的函数print_str，打印十进制数字的函数print_dec以及打印十六进制的函数print_hex。
（2）getchar函数的实现
getchar函数的功能为从rxdata寄存器读取数据，无输入参数，返回值为读取的寄存器数据并将其转换为char类型。在读取数据之前，调用rrdy函数判断当前UART的状态，若为可读取状态，则从rxdata寄存器读取数据。
6.3.6 SBI设计
	SBI，即Supervisor Binary Interface。为实现对上层系统提供调用接口的功能，引导程序通过ecall软中断的形式提供系统调用接口。由于中断处理函数没有预留参数作为系统调用号，设计将自定义系统调用函数的参数传递规则。系统调用函数的参数传递规则如下表所示。
寄存器	功能
a0~a3	系统调用函数参数
a7	系统调用号
a0	系统调用函数返回值
在中断处理函数通过读取regs数组中偏移量为10~13（a0~a3）的值即可得到调用函数传递的三个参数，通过读取regs数组中偏移量为17（a7）的值即可得到系统调用类型。
在中断处理函数中，定义系统调用型号的枚举类型如下：
enum sbi_call_t {
	SBI_SET_TIMER = 0,
	SBI_CONSOLE_PUTCHAR = 1,
	SBI_CONSOLE_GETCHAR = 2,
} ;
系统仅实现两种系统调用。
（1）对于SBI_CONSOLE_PUTCHAR系统调用，即向console打印一个字符，其通过将第一个参数a0传入的的值传递给由输入输出驱动提供print_chr函数实现功能，返回值为0。
（2）对于SBI_CONSOLE_GETCHAR系统调用，即向console打印一个字符，其通过调用输入输出驱动提供的getchar函数，对字符进行接收。
第7章 操作系统的设计
7.1 最小化内核
操作系统的本质是一个独立式可执行程序，即裸机程序。这决定了操作系统的编写过程与一般直接在系统中运行的可执行程序不同，其最大的特点是无法使用依赖于某特定平台的函数库。此外，由于编译器没有符合硬件平台的目标结构，因此其编译也必须以特殊方式进行。
（1）通过cargo新建系统工程，xy_os。
执行如下命令，默认新建二进制可执行项目
cargo new xy_os 
执行如下命令测试项目是否可以正常运行
cargo run
其运行效果如下：
 

此时该项目为针对x86平台Linux操作系统构建的二进制可执行项目。
（2）更改编译的目标架构
为了让编译器编译出符合目标架构的操作系统，需要根据架构特点进行更改。Rust使用LLVM作为其编译器后端，首先查看rust支持编译的目标机器架构，执行如下命令：
rustup target list
截取部分输出结果如下：
 

target各字段的含义分别为cpu 架构、供应商、操作系统和ABI。可见，当前rust编译器的默认架构为x86_64-unknown-linux-gnu，即为x86_64的CPU，未知厂商，linux操作系统、gnu ABI目标架构。
由输出结果可知rust编译器支持riscv32架构，但无法保证完全与系统兼容，因此需要使用json文件对LLVM的目标三元组进行自定义，并在编译项目时通过 --target json文件名指定。
在项目中新建文件xy_ox.json，json文件的内容如下：
 
	
选择的llvm目标架构为riscv32，小端序，int类型和指针宽度均为32位，同时指定自定义链接脚本对操作系统进行链接，链接脚本详见7.6节。
（3）去除标准库的引用
	查看项目中main.rs文件内容如下：
 

该文件默认使用标准库中的println!宏进行格式化输出。在7.2节将实现该宏，此时可暂时将该宏的使用去除。
在文件中加入如下语句关闭编译器默认链接标准库的功能
#![no_std] 
#![no_main] 
其中，no_main代表不再链接标准库，则程序将不再使用运行时库。no_main代表不再使用Rust默认的函数入口点。
Rust规定当程序发生异常时需要有相应的函数对其进行处理。标准库对应的函数为panic，当关闭对标准库的使用时，该函数便无法被编译器使用，为避免程序出现错误，需要实现与panic同名的函数，其实现如下：
 

Rust语言中有不依赖于平台的core 库，该库主要包含基础的 Rust 类型，如 Result、Option 和迭代器等。panic函数则使用core库中的错误信息类型PanicInfo作为参数。
	标准的Rust程序在对panic处理时会进行堆栈展开，以析构堆栈中的所有生存变量，达到释放内存的目的。此时将使用到标准库中定义的‘eh_personality’语义项，解决方式为禁用堆栈展开，即修改Cargo.toml文件，加入如下语句：
	    

（4）堆栈设置
由6.3.2节引导程序启动操作系统的方式可知，引导程序并未为操作系统设置堆栈，因此在跳转至操作系统main函数运行前，需手动设置堆栈。初始化堆栈的功能可使用汇编指令实现，Rust语言通过global_asm!宏可使用内嵌汇编指令，同时可通过include_str!将特定文件作为字符串包含到目标文件中。在main.rs文件中添加如下内容：
   
#![feature(global_asm)]可开启Rust编译器对汇编指令的支持。
设置堆栈的entry.asm 内容如下：
 

在data数据段中从标号bootstack到标号bootstacktop处预留2KB空间作为操作系统的堆栈空间。因为堆栈自地址高处向低处增长，所以将bootstacktop赋值给sp寄存器。堆栈初始化完成后，通过call指令跳转至main函数。
（5）操作系统main函数
在main.rs文件中实现main函数如下：
 

其中#[no_mangle]属性可以防止编译器对函数名称进行优化。因为由entry.asm跳转至main函数遵循的是C调用规则，extern "C"关键字使编译器在编译此函数时使用 C 调用规则，否则将默认使用Rust调用规则。pub保证该函数名可以被entry.asm访问。
Rust编译器在连接时使用rust lld，在禁用标准库后，将出现如下错误：
“rust lld: error: undefined symbol: abort”
这说明rust lld需要依赖符号abort，因此需手动实现abort函数作为标号提供给rust lld，其实现如下：
 
7.2 SBI函数封装
	引导程序向操作系统提供基本输入输出系统调用，操作系统可通过汇编指令ecall，并传入相应参数进行调用。为方便使用，可以通过创建相应的库对系统调用进行封装，操作系统通过导入外部库的方式使用系统调用功能。
（1）系统调用库的创建
输入如下命令创建库项目bbl
cargo new --lib bbl
修改lib.rs文件内容为
 

#![no_std]表明不使用标准库。由于需要使用ecall指令进行系统调用，故通过#![feature(asm)]开启内联汇编。然后声明公共子模块sbi。
新建文件sbi.rs实现sbi模块，其功能为对系统调用函数进行封装，内容如下：
 

（2）库导入
将bbl库复制到xy_os项目根目录中，更改Cargo.toml文件内容：
[dependencies]
bbl = {path = "bbl/"}
将该库以相对路径方式加入到项目的依赖中。此时，操作系统即可通过调用该库中的console_putchar和console_getchar函数进行数据输入输出。
7.3 格式化输出
（1）IO模块
为实现操作系统代码和功能的模块化，在xy_ox项目中创建一个新的模块用于管理 io。在main.rs文件中加入IO模块的声明如下
pub mod io;
在src目录下新建模块文件io.rs，用于实现输入输出功能，其内容如下：
 

通过使用bbl库中putchar函数可输出单个字符，然后使用putchar函数和循环语句实现puts函数以输出字符串。
（2）Write trait的实现
Rust core库中带有用于格式化和打印字符串的库fmt，该库中包含将消息格式化为数据流所需方法的trait------Write，其简要信息如下：
 
根据trait的特性，仅需为Write trait实现write_str方法即可使用该trait中其余的方法，包括格式化输出方法write_fmt。write_str方法的功能为，将String Slice作为参数传入，然后将该String Slice输出，返回Result类型。仅当成功写入整个String Slice时, 此方法返回Ok(()), 在写入所有数据或发生错误之前, 此方法不会返回。
在IO模块中实现该fmt trait。首先引入core::fmt和core::Write。
use core::fmt::{self, Write};
然后定义结构体StdOut用以实现fmt trait。
 
函数的实现直接调用自实现的puts函数输出传入的参数String Slice。
格式化输出方法write_fmt的输入参数为fmt::Arguments结构的变量，可通过core::format_args宏创建。core::format_args宏为Rust core库用于格式化字符串创建和输出的核心宏，通过为传递的每个参数获取包含 {} 的格式字符串文本来发挥作用。
（3）println！宏
查看标准库中println！的实现方式：
 

其中包含两条匹配规则，均为在print！宏的基础上加入“\n”输出。#[macro_export]用以将该宏重导出至根目录。
进一步查看标准库中print！宏的实现方式：
 
print宏的实现为调用IO模块中的_print函数，而_print的参数为format_args宏生成的Arguments变量。此时，IO模块仅需实现_print函数即可实现对println宏和print宏的移植。
易见_print函数的功能与fmt::Write trait 中的write_fmt方法完全相同，所以可将其视为对write_fmt方法的封装。其实现方式为：
 
_print函数直接将其输入参数作为write_fmt的参数调用该方法。
此时，将标准库中对println！宏和print！宏的实现复制到IO模块即可使用。
7.4 ELF解析
操作系统设计的基本功能之一为运行ELF格式用户程序，由于RAM空间的限制，所以将用户程序与操作系统一同固化至ROM中，操作系统仅对ELF文件进行解析，而不对其进行加载，便跳转至该用户程序执行。
对ELF的解析使用外界提供的xmas-elf项目[6]。xmas-elf项目提供对ELF文件结构的解析与提取、转换功能。新建模块elf以实现对用户程序的解析功能。
解析ELF需提供ELF存储地址_elf_payload_start与_elf_payload_end。由于用户程序通过incbin宏指令嵌入至引导程序中，所以可直接查看引导程序的反编译结果，从而定位_elf_payload_start与_elf_payload_end标号的地址。
使用Rust core库slice模块中的from_raw_parts函数截取从_elf_payload_start内存开始处的整个ELF程序，并存储在kernel_elf变量中，然后使用xmas_elf::ElfFile结构体将kernel_elf变量类型强制转换为xmas_elf库中定义的ElfFile结构体类型。此时，便可依据xmas_elf库中的函数对ELF文件进行解析。
header::sanity_check函数的功能为检查ELF文件头，从而检查ELF文件正确性与完整性。program_iter函数的功能为遍历ELF文件中各段信息。header.pt2.entry_point函数的功能为取得ELF文件头进而解析出程序入口点。
解析过后，操作系统将得到程序入口点地址并存入变量kernel_main中。为跳转至用户程序开始执行，需要将该地址转换为函数形式。本实验通过core库mem模块中实现的transmute函数将该变量类型转换为extern "C" fn函数类型。最后调用转换为函数的kernel_main即可转入用户程序执行。
7.5 用户程序的编写
为验证操作系统解析运行用户程序的功能，需编写基于该系统的用户程序进行测试。
由于操作系统并未提供编译和库支持，用户程序的编写同操作系统相同，使用bare metal形式编写。创建用户可执行程序hello。
cargo new hello
	新建json文件，内容与操作系统json文件相同，其链接脚本详见7.6节。
去除标准库链接，使用汇编指令设置堆栈然后跳转至main函数执行。	引入bbl库支持，新建io模块作为输入输出模块，同7.3节所示。在main函数中使用println！宏输出字符串“Hello World from user programe!”
7.6 程序的链接与加载
picorv32 CPU并未实现MMU，即内存管理单元，加之内存资源相当局限，所以操作系统无法实现内存的管理功能。本实验中的所有程序，使用的内存地址均为物理地址，内存空间则组织分配均手动进行，并在链接脚本中指定。
（1）引导程序的内存分配
操作系统与用户程序最终都将嵌入至引导程序特定的地址标号处，故从本质上看，对引导程序的地址空间分配即为对全局的地址空间进行分配管理。
	在引入操作系统与用户程序之前，先对引导程序进行链接，链接脚本内容详见附录B。在链接脚本中使用‘MEMORY’命令描述目标平台上内存块的位置与长度，ROM用于存储可执行代码段和只读数据，RAM用于存储数据段和bss段，其起始地址硬件平台中ROM和RAM的起始地址，大小则为ROM和RAM的大小。通过’SECTIONS’命令指定编译目标文件的段名。此处，仅需定义text，data，bss三个段即可。由于RAM在开始时无法进行初始化，且引导程序并没有加载程序能够用来加载其数据段。故将使用‘AT’命令指定data段的本地加载地址LMA为代码段中的_sidata标号。
（2）操作系统的链接
	引导程序在进行寄存器和设备的初始化后直接跳转至加载操作系统可执行代码段的标号text_payload_start处运行。引导程序编译为ELF可执行文件后，通过RISC-V交叉编译工具链反汇编工具objdump查看其反汇编代码，指令如下：
riscv-unknown-elf-objdump -d firmware.elf | less
查看text_payload_start的地址，此地址即为操作系统链接脚本中可执行代码段的起始地址。同理可查看操作系统数据段地址起始地址data_payload_start。
为了方便地址管理，将text_payload_start与data_payload_start的地址取整，使用汇编伪指令.org为标号起始地址指定偏移量，其中text_payload_start偏移量为0x1000，data_payload_start偏移量为0x300。此时便可确定操作系统代码段和数据段的链接地址。
在操作系统项目xy_os工程中新建链接脚本linker.ld文件，其内容详见附录C。该脚本ROM用于存储可执行代码段和只读数据，RAM用于存储数据段和bss段，其起始地址即为所计算的标号偏移量加上ROM和RAM的起始地址，大小则依据操作系统实际所需分配，可重复调整直至编译成功。
通过objdopy将操作系统的代码段和数据段提取为两个文件，即
		riscv32-unknown-elf-objcopy -O binary -j .text $(kernel) xy_os.text
		riscv32-unknown-elf-objcopy -O binary -j .data $(kernel) xy_os.data
并分别复制到引导程序项目目录下一同编译。

关于为何将操作系统的代码段和数据段分别链接至引导程序不同区域，而不直接链接ELF程序的解释。首先将代码段与数据段分开，引导程序可以省略解析ELF程序的代码功能，其次由引导程序直接跳转至可执行代码段时，操作系统的链接地址也更容易分配给定，反例参考对用户程序链接地址的计算。最后由于引导程序数据段加载的特殊方式，将操作系统数据段单独链接至引导程序也更便于加载数据段。
（3）用户程序的链接
用户程序直接通过ELF格式文件嵌入引导程序_elf_payload_start标号起始处，通过反汇编引导程序可查看_elf_payload_start标号起始地址。
此时，由于_elf_payload_start标号地址与程序可执行代码段起始地址不同，故无法直接将标号地址作为用户程序的链接地址。通过查看反汇编代码与用户程序用汇编指令初始化堆栈的代码进行对比，也可定位到用户程序可执行代码段在引导程序中起始地址。
但是此时仍然无法将该地址作为用户程序的链接地址，原因是若据此修改用户程序链接脚本，该程序生成的ELF文件结构将发生改变，进而导致重新嵌入至引导程序相同地址时，可执行代码段的偏移量也会随之改变，则操作系统在解析完成该用户程序的entry时，跳转的地址为旧的可执行代码段地址，从而无法正常执行。
	解决方法为固定用户程序中链接脚本可执行代码段的位置，并将其取整对齐。同时也固定_elf_payload_start标号的位置，重新编译。反汇编引导程序代码，查看其可执行代码段地址。引导程序中用户程序的可执行代码段地址必然与链接脚本中的给定地址存在偏移。
假设用户程序链接脚本中可执行代码段地址为addrld ，引导程序中可执行代码段地址为addr load，则其偏移量offset的计算方式为：
offset=〖addr〗_ld-addr_load
为使两地址偏移量为零，需要在保证用户程序不变的情况下，修改引导程序中_elf_payload_start标号的地址。引导程序中_elf_payload_start标号地址的计算方式为
〖addr〗_elf= 〖addr〗_elf+offset
使用 .org伪指令设置_elf_payload_start标号的地址值为addrelf 。
（4）地址空间布局
	结合以上对于整个系统地址空间的分配管理可得到布局如下图所示
 


第8章
8.1 实验成果展示

8.2 工作总结

8.3 未来展望










参考文献
[1] Interview on Rust, a Systems Programming Language Developed by Mozilla
(https://www.infoq.com/news/2012/08/Interview-Rust)
[2] Evaluation of performance and productivity metrics of potential programming languages in the HPC environment
(https://octarineparrot.com/assets/mrfloya-thesis-ba.pdf)
[3] Intel® Quartus® Prime Standard Edition User Guide Platform Designer
Updated for Intel® Quartus® Prime Design Suite: 18.1
[4] Embedded Peripherals IP User Guide
[5] STEP-MAX10 硬件手册
[6] https://github.com/nrc/xmas-elf



附录A
Intel HEX 格式
Intel HEX 格式文件是遵循 Intel HEX 文件格式的 ASCII 文本文件。在 Intel HEX 文件的每一行都包含了一个 HEX 记录。Intel HEX由任意数量的十六进制记录组成。每个记录包含5个域，它们按以下格式排列：
 

Start Code 每个 Intel HEX 记录都由冒号开头
Byte count 是数据长度域，它代表记录当中数据字节的数量
Address 是地址域，它代表记录当中数据的起始地址
Record type 是代表HEX记录类型的域，它可能是以下数据当中的一个：
　　00-数据记录
　　01-文件结束记录
　　02-扩展段地址记录
　　03-开始段地址记录
　　04-扩展线性地址记录
　　05-开始线性地址记录
Data 是数据域，一个记录可以有许多数据字节.记录当中数据字节的数量必须和数据长度域中指定的数字相符
Checksum 是校验和域，它表示这个记录的校验和.校验和的计算是通过将记录当中所有十六进制编码数字对的值相加，以256为模进行以下补足。

附录B
引导程序链接脚本
ENTRY(reset_vec)
MEMORY
{
    ROM (rx)      : ORIGIN = 0x00000000, LENGTH = 0xc000 /* entire ROM, 48KB */
    RAM (xrw)       : ORIGIN = 0x00010000, LENGTH = 0x1000 /* 4 KB */
}
SECTIONS {
    /* The program code and other data goes into ROM */
    .text :
    {
        . = ALIGN(4);
        *(.text)           /* .text sections (code) */
        *(.text*)          /* .text* sections (code) */
        *(.rodata)         /* .rodata sections (constants, strings, etc.) */
        *(.rodata*)        /* .rodata* sections (constants, strings, etc.) */
        *(.srodata)        /* .rodata sections (constants, strings, etc.) */
        *(.srodata*)       /* .rodata* sections (constants, strings, etc.) */
        . = ALIGN(4);
        _etext = .;        /* define a global symbol at end of code */
        _sidata = _etext;  /* This is used by the startup in order to initialize the .data secion */
    } >ROM
    .data : AT ( _sidata )
    {
        . = ALIGN(4);
        _sdata = .;        /* create a global symbol at data start; used by startup code in order to initialise the .data section in RAM */
        _ram_start = .;    /* create a global symbol at ram start for garbage collector */
        . = ALIGN(4);
        *(.data)           /* .data sections */
        *(.data*)          /* .data* sections */
        *(.sdata)           /* .sdata sections */
        *(.sdata*)          /* .sdata* sections */
        . = ALIGN(4);
        _edata = .;        /* define a global symbol at data end; used by startup code in order to initialise the .data section in RAM */
    } >RAM
    /* Uninitialized data section */
    .bss :
    {
        . = ALIGN(4);
        _sbss = .;         /* define a global symbol at bss start; used by startup code */
        *(.bss)
        *(.bss*)
        *(.sbss)
        *(.sbss*)
        *(COMMON)

        . = ALIGN(4);
        _ebss = .;         /* define a global symbol at bss end; used by startup code */
    } >RAM
}

附录C 操作系统链接脚本
ENTRY(_start)
MEMORY
{
    ROM (rx)      : ORIGIN = 0x00001000, LENGTH = 0x8000 /* entire ROM, KB */
    RAM (xrw)       : ORIGIN = 0x00010300, LENGTH = 0x800 /* 2KB */
}


SECTIONS {
    /* The program code and other data goes into ROM */
    .text :
    {
        . = ALIGN(4);
        *(.text)           /* .text sections (code) */
        *(.text*)          /* .text* sections (code) */
        *(.rodata)         /* .rodata sections (constants, strings, etc.) */
        *(.rodata*)        /* .rodata* sections (constants, strings, etc.) */
        *(.srodata)        /* .rodata sections (constants, strings, etc.) */
        *(.srodata*)       /* .rodata* sections (constants, strings, etc.) */
        . = ALIGN(4);
        _etext = .;        /* define a global symbol at end of code */
        _sidata = _etext;  /* This is used by the startup in order to initialize the .data secion */
    } >ROM


    /* This is the initialized data section
    The program executes knowing that the data is in the RAM
    but the loader puts the initial values in the ROM (inidata).
    It is one task of the startup to copy the initial values from ROM to RAM. */
    .data : AT ( _sidata )
    {
        . = ALIGN(4);
        _sdata = .;        /* create a global symbol at data start; used by startup code in order to initialise the .data section in RAM */
        _ram_start = .;    /* create a global symbol at ram start for garbage collector */
        . = ALIGN(4);
        *(.data)           /* .data sections */
        *(.data*)          /* .data* sections */
        *(.sdata)           /* .sdata sections */
        *(.sdata*)          /* .sdata* sections */
        . = ALIGN(4);
        _edata = .;        /* define a global symbol at data end; used by startup code in order to initialise the .data section in RAM */
    } >RAM

    /* Uninitialized data section */
    .bss :
    {
        . = ALIGN(4);
        _sbss = .;         /* define a global symbol at bss start; used by startup code */
        *(.bss)
        *(.bss*)
        *(.sbss)
        *(.sbss*)
        *(COMMON)

        . = ALIGN(4);
        _ebss = .;         /* define a global symbol at bss end; used by startup code */
    } >RAM

    /* this is to define the start of the heap, and make sure we have a minimum size */
    .heap :
    {
        . = ALIGN(4);
        _heap_start = .;    /* define a global symbol at heap start */
    } >RAM
}

