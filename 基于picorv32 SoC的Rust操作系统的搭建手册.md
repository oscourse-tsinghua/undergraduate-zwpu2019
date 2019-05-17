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
	STEP FPGA开发板，即小脚丫系类FPGA开发板，是由国内硬件平台设计开发公司------思得普信息科技有限公司发布的系列开发板。本实验主要使用其MAX10系列FPGA开发板作为硬件平台。STEP-MAX10是基于Altera公司芯片开发的FPGA开发板，板卡集成下载器，使用MicroUSB数据线可完成开发板的供电与下载。
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
	配置支持的指令集模块
Picorv32实现RISCV IMC三个模块的指令，其中I模块为标准配置。
M模块配置方式如下
ENABLE_MUL 默认值为0，需要使用乘法指令时则应将该参数设置为1。
ENABLE_DIV 默认值为0，需要使用除法指令时则应将该参数设置为1。

C模块配置方式如下
COMPRESS_ISA 默认值为0，需要使用压缩指令集时则应将该参数设置为1。

ENABLE_IRQ 默认值为0，当需要支持中断处理时则应将该参数设置为1。

ENABLE_IRQ_QREGS  默认值为1，当不需要使用q0~q3寄存器时则应将该参数设置为0。
若关闭IRQ_QREGS，则在处理中断时，根据RISC-V ABI的规定，一般的C语言程序编译时将不会使用到global pointer 寄存器和thread pointer寄存器，故可将返回地址存储在x3（gp），中断掩码存储在x4（tp）之中。当ENABLE_IRQ的值为0时，q0~q3寄存器也无法使用。

ENABLE_IRQ_TIMER  默认值为1，当不需要时钟中断时则应将该参数设置为0。当ENABLE_IRQ的值为0时，时钟中断也无法使用。

MASKED_IRQ 默认值为32'h 0000_0000，其值对应需要屏蔽的IRQ掩码，需要和irq_mask寄存器中的值做与操作决定最终屏蔽的IRQ掩码。

LATCHED_IRQ 默认值为32'h ffff_ffff，当对应位为1时，表明与该位对应的irq外部输入信号将被锁存直至中断处理触发。

PROGADDR_RESET 默认值为32'h 0000_0000，其值为CPU启动时所执行的初始地址。

PROGADDR_IRQ 默认值为32'h 0000_0010，其值为CPU在发生中断时需跳转的地址。

STACKADDR 默认值为32'h ffff_ffff，其值与默认值不同时，将被设置为堆栈寄存器x2（sp）初始地址。RISC-V函数调用转换要求sp寄存器的值必须为16字节对齐。

ENABLE_PCPI 默认值为0，当需要支持外部协处理器时则应将该参数设置为1。


参考文献
[1] Interview on Rust, a Systems Programming Language Developed by Mozilla
(https://www.infoq.com/news/2012/08/Interview-Rust)
[2] Evaluation of performance and productivity metrics of potential programming languages in the HPC environment
(https://octarineparrot.com/assets/mrfloya-thesis-ba.pdf)
[3] Intel® Quartus® Prime Standard Edition User Guide Platform Designer
Updated for Intel® Quartus® Prime Design Suite: 18.1
