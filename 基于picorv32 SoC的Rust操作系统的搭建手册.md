运行环境
Picorv32 搭建的SoC。
可用的外设，48KB ROM, 4KB RAM，UART，GPIO。

编程语言：
C语言，Riscv 汇编语言，Rust语言

编程环境：
Ubuntu 16.04

环境搭建：
由于实验所编写的软件将会运行于自行搭建的平台上，即bare-mental的环境中。若直接使用本地编译的方式，程序将无法适配平台并正常运行，故无法使用本地编译环境对程序进行直接的编译。为此，在正式开始软件开发之前，需要为本地机器安装交叉编译环境，使编译出来的的程序能够运行于另一种体系结构的不同目标平台之下。

Riscv交叉编译工具链介绍
https://github.com/riscv

Riscv-gnu-toolchain:：
Riscv 编译工具链系列，包括将源程序编译、汇编、链接为可执行文件的一系列工具。

riscv-gcc:
GCC为gnu compiler colloction的缩写，即由GNU开发的一系列编译器集合，支持将多种高级语言编译为可执行文件的工具，riscv-gcc即将高级语言程序或者riscv汇编程序编译为riscv架构的ELF文件。

现列出部分实验所用到的工具并加以介绍
riscv-binutils: 包括链接器、汇编器和其他用于目标文件和档案的工具，它是二进制代码的处理维护工具。
as：GNU汇编器, 将汇编源代码，编译为机器代码。
ld： GNU链接器，将多个目标文件，链接为可执行文件。
ar：用于创建、修改库。
addr2line： 将ELF特定指令地址定位至源文件行号。
objcopy：用于从ELF文件中提取或翻译特定内容，可用于不同格式二进制文件的转换。
objdump：用与查看ELF文件信息，反汇编为汇编文件等
readelf：显示ELF文件的信息。
strip：用于将可执行文件中的部分信息去除，如debug信息，可在不影响程序正常运行的前提下减小可执行文件的大小以节约空间。

riscv-gdb：用于调试riscv程序的调试工具。

riscv-glibc: Linux系统下的riscv架构gnu C函数库。

riscv-newlib: 面向嵌入式系统的C语言库。

riscv-qemu：
riscv架构的机器仿真器和虚拟化器，可在其模拟的硬件机器上运行操作系统。

Riscv-isa-sim：Spike模拟器 RISCV ISA 的仿真器，类似于qemu。

Riscv-pk：运行于本地机器上的代理内核，是一个轻量级的应用程序执行环境，可直接运行与spike模拟器之中，然后加载运行静态链接的riscv ELF程序。

bbl：Berkeley Boot Loader，此引导程序可用于在真实环境下加载操作系统内核。
Riscv-test：riscv官方的测试程序。


交叉编译的难点分析	
当前大多数机器编译主要针对x86架构和硬件平台作为开发环境，因此多为本地编译。
交叉编译的难点主要体现在如下两个方面。
机器特性不同
字大小：字大小决定相关数据类型的位宽，如指针、整型数据等。
大小端：分为大端和小端，决定数据和地址的对应关系。
对齐方式：不同平台读取数据的方式不同，有些只能读取或写入对齐地址中的数据，否则将会出现访存异常。因此编译器会通过补齐结构的方式来对齐变量。
默认符号类型：不同平台对于某些数据类型默认是有符号还是无符号有不同的规定，如“char" 数据类型，解决方法是提供一个编译器参数, 如 "-funsigned-char", 以强制默认值为已知值。

编译时的主机环境与目标环境不同
编译器运行的计算机称为host, 运行的新程序所使用的计算机称为target。当host和target是相同类型的计算机时, 编译器是本机编译。当host和targt不同时, 编译器是交叉编译。
	库支持：程序在交叉编译时，动态链接的程序必须在编译时访问相应的共享库。目标系统中的共享库需要添加到跨编译工具链中, 以便程序可以针对它们进行链接。对于特定平台下运行的程序，难以找到能够契合其硬件的库支持，因此需要根据现有库进行改写或自行编写简易库支持。

安装方式：
下载源码
git clone --recursive https://github.com/riscv/riscv-gnu-toolchain

安装依赖项：
sudo apt-get install autoconf automake autotools-dev curl libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev


编译工具链
cd riscv-gnu-toolchain

./configure --prefix=/opt/riscv --with-arch=rv32gc --with-abi=ilp32d
--prefix= 指定安装路径，若不指定则默认安装在当前路径。
--with-arch= 指定安装模块，rv32代表32位交叉编译工具链、rv64代表64位交叉编译工具链。riscv的子模块包括I、M、A、D、F、C，其中G模块为包含I、M、A、D、F的集合，若不指定则默认安装全部模块。
--with-abi= 指定abi，riscv的abi调用模式参考XXX节，若不指定则默认安装全部模式。

make -j$(nproc)
执行make命令安装newlib作为C语言函数库的交叉编译工具链。
执行make linux命令安装glibc作为C语言运行库的交叉编译工具链。

安装完成后可在指定的路径中找到工具链的可执行文件。
将该路径下的bin目录路径加入至PATH，以便在Terminal中直接执行。
查看该bin目录下的程序，可以看到程序均具有相同的前缀。

不同工具链前缀不同，其区别如下：
riscv32-unknown-elf-gcc：针对于riscv32架构的编译器，使用的C运行库为newlib。
riscv64-unknown-elf-gcc：针对于riscv64架构的编译器，使用的C运行库为newlib。
riscv32-unknown-linux-gnu-gcc 针对于riscv32架构的编译器，使用的C运行库为linux中的标准glibc


安装spike和riscv-pk
下载源码
$ git submodule update --init --recursive 
下载依赖
sudo apt-get install autoconf automake autotools-dev curl libmpc-dev libmpfr-dev libgmp-dev libusb-1

导出变量
$ export RISCV=riscv安装路径

$ ./build-rv32ima.sh

安装完成后,终端出现提示信息"RISC-V Toolchain installation completed!"

Riscv程序编写，以Hello World程序为例，创建HelloWorld.c文件，其内容如下：
#incldue<stdio.io>
Int main() {
	Printf(“Hello World!\n”);
	Return 0;
}
创建makefile脚本，内容如下：
TOOL_CHAIN = riscv交叉编译工具链安装路径bin目录
CROSS_COMPILE = $(TOOL_CHAIN)/riscv32-unknown-elf-  //工具链前缀
WARM = -Wall -Werror W

HelloWorld: HelloWorld.c
	$(CROSS_COMPILE)gcc -march=rv32i -mabi -mcmodel=medlow $(WARM) $< -o $@ 
clean:
	rm HelloWorld

编译源码脚本：
编译参数如下
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
目标代码模型指示对符号的约束, 编译器可以利用这些约束来生成更高效的代码。
RISC-V目前定义以下两个代码模型:
-mcmodel = medlow
程序及其静态定义的符号必须位于一个2GB 地址范围内, 介于绝对地址-2 GB 和 + 2GB 之间。lui 和 addi 共同使用生成地址。
使用方式：

-mcmodel = medany
程序及其静态定义的符号必须位于单个4GB 地址范围内。auipc 和addi共同使用生成地址。

若不指定如上参数，编译器将使用默认值，默认值待后期再查看XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

通过riscv仿真模拟器spike和代理内核pk，即可在本地机器上运行riscv程序。
执行如下命令运行HelloWorld程序
Spike pk HelloWorld
可见程序运行并打印出 “Hello World!”


Rust语言介绍：
Rust是一门系统编程语言，其优点是注重安全，尤其是并发安全，可以支持函数式、命令式以及泛型等编程范式的多范式语言。其在语法风格和C++类似，但是能够在保证性能的同时提供更好的内存安全。
Rust语言是一种静态编译式语言，支持静态编译和动态编译，其语言特性包括泛型、面向对象、模式匹配、闭包(Closures)等，Rust没有虚拟机(VM)、没有垃圾收集器(GC)、没有运行时(Runtime)，由于所有权和生命周期机制，使得Rust编写的程序能够避免空指针、野指针、内存越界、缓冲区溢出、段错误、数据竞争等一系列问题。Rust语言的编译器使用Rust语言重写，完成自举，并采用LLVM作为编译后端，说明其实现的完备性。

Rust优势分析：
与C++语言的比较
首先说明如今C++的应用广泛的原因。C++的应用场景多为编写接近实时高性能，稳健，并有足够开发效率的大程序。C++语言的优势在于：
1.高级语言若需实现接近实时的性能，便不能存在垃圾回收机制。垃圾回收机制导致了java、python等语言的延迟。一个比较真实的场景为，若存在一个低延时交易程序在进行一个交易机会之后因为某种原因触发长达200ms的垃圾回收，必然导致系统效率的低下。所以，若要达到接近实时且高性能的目的，就需要语言本身能够接近底层，即bare-metal。

2.高性能的目标可以用C语言达到，但考虑到开发效率的问题，C语言的特性缺乏就是一个明显问题-----开发者在开发的时候缺少数据结构基础设施。C++的多语言范式为开发人员提供一系列基础的组件，如Vector、hashmap或者查找算法。

3.从开发效率和可读可维护性的层面上来说，高级语言必须具有足够的抽象能力，且抽象是没有运行时开销的。零开销抽象(zero cost abstraction)是C++语言的设计原则之一------inline函数，template等均遵循这一原则。 

4.稳健的大程序则意味着程序要在进生产环境之前尽量消灭错误。为了达到这一目标，可以牺牲一些开发效率。这就意味着高级语言需要具备一个静态类型，最好同时是强类型的语言，这能够使得编译器尽早发现问题。<Effective C++>给出一些"技巧"来加强类型检查，比如单参数构造函数最好加explicit。C++11在此基础上加入enum class以及各种override，final等，用以加强编译器在编译时查出错误的能力。

从上面的例子可以看出，C++语言从整体上看是一个高性能的静态强类型多范式语言。

C++语言的问题
历史原因与设计人员当时抉择所看重的东西导致C++语言的问题。C++语言开发的目标之一是与C语言兼容，为了避免Python 2和Python 3的故事，甚至是IA64和x86_64的错误，设计人员不得不保证C++一直保持向前兼容。C语言的野指针，和线程安全问题会导致很多极难发现，诊断和修复的bug。

Rust语言的优势：
由于Rust语言是一个全新开发的高级语言，设计人员在开发过程中，借鉴过去近30年的语言理论研究和实际软件工程的经验进行设计。
设计者为了持续追求“更好的设计和实现”，完全无历史包袱、无迁就，只要出现更好的设计或实现，经过深入讨论和评估之后，设计者们不会为了向前兼容而放弃改变。


XXXXXXXXXXXXX此处应该加入数据和表格，文献引用XXXXXXXXXXXXX
Rust语言相对C++语言的优势：
1.无数据竞争的并发。Rust语言使用类似golang的基于通道的并发。在无需释放锁的前提下，开发和运行的逻辑简单且效率高。Rust中提供的函数式语言------pattern matching，可以有效避免数据竞争。此外，Rust还提供非常多的函数式语言特性，比如closure等。

2.Generics和Trait实现zero cost abstraction，并且统一了编译时和运行时多态性，从而省去了不少程序语义方面的复杂性。因为没有runtime，所以与C语言的互通简单。

3.Rust语言有灵活的enum系统，以及衍生的错误处理机制。错误通过enum返回，而没有exception。Rust的module系统以及pub和use关键字能使开发者控制所有的访问许可关系。
6.Rust拥有强大的管理系统Cargo以及中心化的库管理crates.io。Cargo的依赖管理遵循最新的Semantic Versioning。开发者只需要选择适当的库依赖版本，通过cargo update命令即可自动完成所有版本匹配和下载加载。

7.其它的特性，比如缺省可使用的直接打印数据的内容状态，更漂亮的条件编译，更好用的宏，rustdoc的自动文档生成，语言自带的简单测试系统。

8.Rust语言最重要的特性是所有权和生命周期。Rust声称"prevents nearly all segfaults，and guarantees thread safety"。Rust里每一个引用和指针都有一个生命周期，对象不允许在同一作用范围内有两个可变引用。并且编译器在编译时就会禁止其被使用。
举例说明，C++中的to_string().c_str()方法会导致导致crash的严重后果，但是这种bug在Rust语言中能够被编译器识别并无法编译通过。正是源于这一特性，使得原本在C++里无法使用的优化做法变得具有可行性。比如若要将字符串分割成不同部分，并在不同的地方使用，当项目较大时，为了保障安全性，通常的做法是把分割的结果拷贝一份单独处理，这样便可避免在处理分割的字符串的时候原本的字符串已经不存在的问题。但是当我们使用Rust进程程序编写是，便可舍弃拷贝的环节，直接使用原来的字符串而不用担心出现野指针的情况，生命周期的设定可以让编译器完成这一繁琐的检查，如果有任何的字符串在处理分割结果之前被使用，编译器将会检查出此种错误。

9.由于Rust没有垃圾回收的控制，且其实现接近底层。在达到同样安全性的前提下，Rust并不会比C++慢。Rust拥有足够多的语言特性来保证开发的效率，并且比C++语言吸收了更多的现代优秀的语言特性。与C++一致的零抽象消耗。杀手级的所有权和生命周期机制，加上现代语言的类型系统。总之，在语言层面上来说，Rust语言无疑是比C++优秀的一个高性能静态强类型多范式语言。


安装Rust工具链
Linux系统或Mac系统
curl -sSf https://static.rust-lang.org/rustup.sh | sh


可通过配置代理服务器加快配置速度
export RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static
export RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup



选择自定义安装，并使用nightly版本，软件将默认安装到 $HOME/.cargo/bin 目录。
安装完成后，输入如下命令查看版本。
rustc –verison
出现如下带nightly后缀的版本即可。
rustc 1.0.0-nightly (f11f3e7ba 2015-01-04) (built 2015-01-06)
说明使用nightly版本的原因：
Rust语言有三种发布版本：nightly、beta、stable。
nightly为每天发布的新版本特性，其功能不稳定、且可能在未来时间内被移除。
Beta为测试版本，定期从nightly版本中合并产生。Nightly为稳定版本，定期从beta版本中合并产生。
因此，nightly版本代表当前Rust开发功能的前沿，具有很多stable版本无法使用的特性，而在编写操作系统等无需依赖标准库，前需要和汇编、C语言结合的底层软件时，使用nightly版本无疑是正确的选择。

Rustup能够管理安装多个官方版本的 Rust 二进制程序，配置基于目录的 Rust 工具链，安装和更新来自 Rust 的发布通道: nightly, beta 和 stable。

可通过如下命令配置多种版本rust工具链
Rustup toolchain install <toochain>(stable\nightly\beta)
使用如下命令配置默认编译器
Rustup default <toolchain>(stable\nightly\beta)

在VS-Code IDE中进行代码开发，安装VS-Code之后，

下载rust源码
rustup component add rust-src

下载rust 语言支持rls和分析工具rust-analysis
rustup component add rls
rustup component add rust-analysis

使用Cargo包管理器安装 
Cargo 是 Rust的构建系统和包管理工具，实现构建项目，下载依赖，编译源码和包的三大功能。

安装rust自动补齐和语法分析工具racer
cargo install racer 
安装代码美化插件rustfmt
cargo install rustfmt 

以上所有工具安装完成后，都会别自动添加至环境变量之中，无需额外配置，IDE可以直接使用。

使用cargo构建项目
通过如下命令构建helloworld可执行文件项目
Cargo new helloworld

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

src/main.rs
fn main() {
        println!("Hello, world!");
}

通过如下命名运行整个系统
$ cargo run
       Compiling hello_world v0.0.1 
         Running `target/debug/hello_world`
Hello, world!




对picorv32 CPU的分析
Picorv32是一个用Verilog语言实现的RISCV软核，其特点是体积小巧，占用资源少，运行频率高，支持多种模块的RISCV指令集，并且能够通过其预留接口拓展多个功能模块。

	Picorv32使用的性能和资源分析

Picorv32中执行每条指令所需的时钟周期数接近4。下表为具体每条指令执行所需的周期数。
CPI---执行每条指令的周期数，开启双口读寄存器，即ENABLE_ REGS_DUALPORT=1，
CPI(SP)---执行每条指令的周期数，单口读寄存器，即ENABLE_ REGS_DUALPORT=0，

| Instruction          |  CPI | CPI (SP) |
| ---------------------| ----:| --------:|
| direct jump (jal)    |    3 |        3 |
| ALU reg + immediate  |    3 |        3 |
| ALU reg + reg        |    3 |        4 |
| branch (not taken)   |    3 |        4 |
| memory load          |    5 |        5 |
| memory store         |    5 |        6 |
| branch (taken)       |    5 |        6 |
| indirect jump (jalr) |    6 |        6 |
| shift operations     | 4-14 |     4-15 |
| MUL | 40| 40|
| MULH[SU|U] |  72 | 72 |
| DIV[U]/REM[U] | 40 | 40 |

Dhrystone benchmark 基准测试程序结果 0.516 DMIPS/MHz (908 Dhrystones/Second/MHz)

Dhrystone benchmark 基准测试程序平均CPI 为4.100.


Picorv32在Xlinx系列FPGA芯片上布局布线所能够达到的最高频率。
| Device                    | Device               | Speedgrade | Clock Period (Freq.) |
|:------------------------- |:---------------------|:----------:| --------------------:|
| Xilinx Kintex-7T          | xc7k70t-fbg676-2     | -2         |     2.4 ns (416 MHz) |
| Xilinx Kintex-7T          | xc7k70t-fbg676-3     | -3         |     2.2 ns (454 MHz) |
| Xilinx Virtex-7T          | xc7v585t-ffg1761-2   | -2         |     2.3 ns (434 MHz) |
| Xilinx Virtex-7T          | xc7v585t-ffg1761-3   | -3         |     2.2 ns (454 MHz) |
| Xilinx Kintex UltraScale  | xcku035-fbva676-2-e  | -2         |     2.0 ns (500 MHz) |
| Xilinx Kintex UltraScale  | xcku035-fbva676-3-e  | -3         |     1.8 ns (555 MHz) |
| Xilinx Virtex UltraScale  | xcvu065-ffvc1517-2-e | -2         |     2.1 ns (476 MHz) |
| Xilinx Virtex UltraScale  | xcvu065-ffvc1517-3-e | -3         |     2.0 ns (500 MHz) |
| Xilinx Kintex UltraScale+ | xcku3p-ffva676-2-e   | -2         |     1.4 ns (714 MHz) |
| Xilinx Kintex UltraScale+ | xcku3p-ffva676-3-e   | -3         |     1.3 ns (769 MHz) |
| Xilinx Virtex UltraScale+ | xcvu3p-ffvc1517-2-e  | -2         |     1.5 ns (666 MHz) |
| Xilinx Virtex UltraScale+ | xcvu3p-ffvc1517-3-e  | -3         |     1.4 ns (714 MHz) |


Picorv32在Xilinx 7-Series FPGA上布局布线所消耗的资源

- PicoRV32 (small):不包含counter 指令、two-stage shifts、mem_radata锁存和未定义指令异常、地址对齐异常配置的picorv32

- PicoRV32 (regular): picorv32的默认配置，即所有的parameter参数使用默认值。

- PicoRV32 (large): 包含PCPI、IRQ、MUL、DIV、 BARREL_SHIFTER、COMPRESSED_ISA的picorv32

| Core Variant       | Slice LUTs | LUTs as Memory | Slice Registers |
|:------------------ | ----------:| --------------:| ---------------:|
| PicoRV32 (small)   |        761 |             48 |             442 |
| PicoRV32 (regular) |        917 |             48 |             583 |
| PicoRV32 (large)   |       2019 |             88 |            1085 |


Picovr32的接口
Picorv32包括访存接口，如SRAM接口，AXILITE接口，WISHBONE接口等。不同接口CPU的内部实现逻辑相同，均为以原生访存接口CPU作为核心，再增加相应接口转换模块。使用者可以通过配置参数实现对CPU部件和功能的选择。

Picorv32原生SRAM接口信号定义如下
    output        mem_valid
    output        mem_instr
    input         mem_ready

    output [31:0] mem_addr
    output [31:0] mem_wdata
    output [ 3:0] mem_wstrb
input  [31:0] mem_rdata

该接口时序为
CPU通过mem_valid启动数据传输。valid信号一直保持高直到接收方将ready置高。 其余信号输出在mem_valid 为高期间保持稳定。如果是指令访存，则将mem_instr置高。

读取数据
在读取数据时，mem_wstrb值为0，mem_wdata 未使用。访存地址为mem_addr，当 mem_ready置高时，mem_rdata的数据有效。CPU可在给出valid的在同一周期内，读取返回的数据。
 
写入数据
写入数据时，mem_wstrb为字节选择信号，mem_rdata 不使用。CPU将mem_wdata 的数据写入地址mem_addr。写入成功后，内存将mem_ready置高。


look ahead接口提供了有关下一个时钟周期比正常接口更早的内存传输信息。
output        mem_la_read
output        mem_la_write
    output [31:0] mem_la_addr
    output [31:0] mem_la_wdata
output [ 3:0] mem_la_wstrb

在mem_valid的置高的上一个时钟周期之前，该接口将会将mem_la_read或者 mem_la_write置高一个时钟周期，提前向内存指示下一个时钟周期的读写信息。


AXI-lite接口
picorv32_axi_adapter 模块定义于picorv32.v 文件中，
遵循标准AMBA AXI-lite接口信号模式，能够将picorv32原生SRAM访存接口转换为AXI-lite接口，并在picorv32.v 文件中将picorv32模块与picorv32_axi_adapter 模块封装为picorv32_axi模块。

WISHBONE接口
Picorv32.v中的picorv32_wb模块封装picorv32模块，并将其接口转换为wishbone接口。

Picorv32的特权模式
	Picorv32的特权模式并未参照RISC-V Privilige ISA specification规范进行实现。
为了使用尽可能少的硬件资源，开发者实现一个自定义的指令集和CSR寄存器集合对中断进行处理。

CSR寄存器
q0：存储异常中断返回地址，对应标准CSR中的epc。
q1(irq_pending)：表示当前准备处理的中断，当某位置为1时，表明与该位下标对应的中断触发，对应标准CSR中的ip。
q2、q3：作为临时寄存器保存中断处理中的中间值，对应标准CSR中的scratch。
irq_mask：中断屏蔽掩码，当某位置1时，表明与该位下标对应的中断将被屏蔽，不对其进行处理。
timer：时钟计数器，每个时钟周期自减1，当其值变为0后触发时钟中断。若需重新触发，需要重新赋值。
counter_cycle：周期计数器，每个时钟周期自增1。
counter_instr：指令计数器，每执行一条指令自增1。

CSR指令
getq rd, qs
0000000 ----- 000XX --- XXXXX 0001011
f7      rs2   qs    f3  rd    opcode
该指令将通用寄存器中的值赋给qn 寄存器。
Example: getq x5, q2

setq qd, rs
0000001 ----- XXXXX --- 000XX 0001011
f7      rs2   rs    f3  qd    opcode
该指令将qn 寄存器中的值赋给通用寄存器。
Example: setq q2, x5

retirq
0000010 ----- 00000 --- 00000 0001011
f7      rs2   rs    f3  rd    opcode
该指令使程序从中断处理中返回，即将q0寄存器中的值赋给PC寄存器，同时重新开启中断。
Example: retirq

maskirq
The "IRQ Mask" register contains a bitmask of masked (disabled) interrupts. This instruction writes a new value to the irq mask register and reads the old value.
0000011 ----- XXXXX --- XXXXX 0001011
f7      rs2   rs    f3  rd    opcode
该指令将rs寄存器中的值写入irq_mask寄存器，同时将irq_mask的旧值返回至rd寄存器。
Example: maskirq x1, x2

waitirq
0000100 ----- 00000 --- XXXXX 0001011
f7      rs2   rs    f3  rd    opcode
CPU暂停执行等待中断被挂起，当有中断触发时才会使CPU继续运行，无论该中断是否被处理。irq_pending的值将被写入rd寄存器。
Example: waitirq x1

timer
0000101 ----- XXXXX --- XXXXX 0001011
f7      rs2   rs    f3  rd    opcode
设置timer寄存器的值，将rs的值赋给timer，同时将timer的旧值赋给rd。
Example: timer x1, x2


中断控制信号：
input [31:0] irq  接入外部中断源。
picorv32可处理32种中断，该输入的每一位对应一种类型的中断。
其中0-2 号中断能够被CPU内部所触发，其中断控制类型如下
IRQ        Interrupt Source
0			Timer Interrupt
1			EBREAK/ECALL or Illegal Instruction
2			BUS Error (Unalign Memory Access)

其余中断可由用户自定义实现。

CPU一次可处理多个中断。
CPU开启或复位后所有中断将被默认关闭，timer寄存器也被默认清理。
若在1~2号中断被屏蔽的情况下出现非法指令或者访存地址错误，将导致CPU停止。
CPU在处理中断程序的过程中将自动关闭中断，直到执行irqret指令。

output [31:0] eoi 当进入CPU进入中断处理时，若将此次需处理的中断号所对应的位置高，直到中断处理结束。
output trap 当CPU进入中断处理状态时，该位置为高。

发生中断时，处理器需要跳转的地址为固定值，可通过参数配置，其默认值为0x10。一旦配置成功便无法再此更改，除非重新综合布局整个CPU下板。

Picorv32的拓展
PCPI模式
出于对小体积的追求，picorv32尽可能缩减了CPU的功能，但是通过提供拓展的形式使得用户能自行添加新功能。picorv32使用 Pico协处理器接口( PCPI ) 来实现用户自定义指令（分支指令类型除外）。
PCPI接口定义如下

output        pcpi_valid
    output [31:0] pcpi_insn
    output [31:0] pcpi_rs1
    output [31:0] pcpi_rs2
    input         pcpi_wr
    input  [31:0] pcpi_rd
    input         pcpi_wait
input         pcpi_ready

当遇到CPU内部不支持的指令时，若ENABEL_PCPI参数设置为1，则开启Pico协处理器模式。CPU将pcpi_valid信号置高，同时将该非法指令通过pcpi_insn输出，CPU将在内部对指令进行译码，并读取rs1和rs2寄存器的值输出至pcpi_rs1 和 pcpi_rs2 上。
当协处理器执行指令完成时，将pcpi_ready信号置高，若需写入rd寄存器，则将结果写入pcpi_rd 并将pcpi_wr信号置高，然后CPU将解析指令的rd字段，并将 pcpi_rd的值从写入对应的寄存器。
当协处理器在16个时钟周期内没有给出pcpi_ready信号时，将触发非法指令异常，CPU将跳转至相应的中断处理程序。 若协处理器需要多于16个时钟周期，则应提前将pcpi_wait信号置高，以避免引发非法指令异常。

Picorv32的配置
Picorv32通过parameter参数设置多个可用来配置其功能的参数。

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



自定义指令的使用：
由于自定义类型指令无法通过GNU汇编器as进行自动编译，故需要通过宏定义方式对自定义类型指令进行编译。如下
#define r_type_insn(_f7, _rs2, _rs1, _f3, _rd, _opc) \
.word (((_f7) << 25) | ((_rs2) << 20) | ((_rs1) << 15) | ((_f3) << 12) | ((_rd) << 7) | ((_opc) << 0))

#define picorv32_getq_insn(_rd, _qs) \
r_type_insn(0b0000000, 0, regnum_ ## _qs, 0b100, regnum_ ## _rd, 0b0001011)

#define picorv32_setq_insn(_qd, _rs) \
r_type_insn(0b0000001, 0, regnum_ ## _rs, 0b010, regnum_ ## _qd, 0b0001011)

#define picorv32_retirq_insn() \
r_type_insn(0b0000010, 0, 0, 0b000, 0, 0b0001011)

#define picorv32_maskirq_insn(_rd, _rs) \
r_type_insn(0b0000011, 0, regnum_ ## _rs, 0b110, regnum_ ## _rd, 0b0001011)

#define picorv32_waitirq_insn(_rd) \
r_type_insn(0b0000100, 0, 0, 0b100, regnum_ ## _rd, 0b0001011)

#define picorv32_timer_insn(_rd, _rs) \
r_type_insn(0b0000101, 0, regnum_ ## _rs, 0b110, regnum_ ## _rd, 0b0001011)

基于RISC-V和Rust语言操作系统的设计与改进。

操作系统设计
对在以picorv32 CPU为核心的小脚丫FPGA实验板上进行操作系统设计合理性的分析。
为进一步管理和利用底层硬件资源，需要设计开发操作系统以更好的运行上层软件。目前硬件平台上所搭建的SoC可用的资源为378Kbit 的Block Memory，GPIO, 数码管等设备。
操作系统及引导程序代码可存储至布局为ROM资源的Block Memory中，使得系统能够被CPU正常加载执行。与此同时，GPIO实现的UART设备保证了操作系统基本的输入输出功能，便于用户与系统进行交互。最后，利用布局为RAM资源的Block  Memory保证了操作系统在运行时能够加载数据和设置堆栈等程序运行所必须的资源支持。
考虑到目前所持有的硬件资源较少，尤其是用于存储和加载程序的存储设备的局限性，故需将原有的硬件平台存储资源重新进行分配，其中用于存储的程序的ROM扩大为40KB，用于加载程序和设置堆栈的RAM资源缩减为4KB。
由于RAM资源过于稀缺，无法支持将操作系统加载至RAM中进行运行，故将操作系统固化至ROM中，由CPU直接读取存储在ROM中的操作系统并直接运行，RAM资源则完全留作数据加载区域与堆栈分配区域，即硬件资源仅支持设计实现嵌入式操作系统。

XXXXXXXXXXXXXXX此处应该有布局图XXXXXXXXXXXXXXXXX

对嵌入式操作系统功能的设计
实现对硬件资源的抽象，通过编写驱动程序对基本输入输出设备进行管理。
实现对中断和异常的处理。
实现对存储资源的管理分配。
实现对ELF格式的可执行用户程序进行解析和执行。
引导程序的设计
	一般的引导程序的功能对硬件进行基本的初始化，并解析并加载操作系统内核至内存指定位置后跳转执行操作系统。引导程序的设计遵循如下两个基本限制：
1.硬件存储资源局促，操作系统无法由ROM重新加载至RAM中执行。
2.picorv32 CPU并未按照RISC-V Privilige Specification中对于特权极标准的要求进行实现。

为此引导程序按照如下方案进行设计
1.简化解析加载ELF格式操作系统内核的代码实现，将编译完成的操作系统内核程序的不同代码段转换为不同的二进制文件直接并直接加载至引导程序特定位置，在编译引导程序时再一同编译。

2.提供sbi接口（Supervisor Binary Interface）和中断处理

RISC-V通过各层之间的Binary Interface实现了对下一层的抽象。此次实验所设计的操作系统遵循第二种模式，引导程序在此处充当SEE的角色。

由XXX节可知，CPU在中断跳转时跳转的固定地址无法更改，故在引导程序层完成对于所有系统调用的处理。此外，引导程序将对UART设备进行管理，实现对UART设备的驱动，并通过sbi的形式为操作系统提供基本输入输出功能。

综上，实验中不再严格区分操作系统与引导程序，而将引导程序作为系统内核的一部分，为系统完成初始化部分功能，进行中断处理，抽象和管理基本输入输出设备，并向上层系统提供系统调用。

引导程序运行流程
1. 引导程序代码段作为CPU执行的第一段代码，其起始地址将被放置在CPU启动地址处，即0x0000_0000。由于CPU的中断跳转地址设置在0x10处，引导程序的0x10处开始作为中断处理程序。实验中直接使用无条件跳转指令跳转过中断程序，转入初始化代码。
2.初始化代码需要将32个通用寄存器初值设置为零。其次，加载程序的数据段和bss段至内存中作为内存初始化数据，bss数据段初值全部赋为零。关于数据段的加载方式详见XXX节。
3.设置UART设备的分频系数，其设置方式详见XXX节。
4.初始化引导程序的堆栈寄存器sp、全局寄存器gp和线程寄存器tp。
其中，堆栈寄存器的值设置为RAM物理地址空间所分配的最大值，由于堆栈的增长顺序为自高地址向低地址生长，故可有效避免堆栈溢出。其大小分配详见XXX节。
5.引导程序打印“BOOT”信息，意味着设备初始化完成。
6.引导程序调用picorv32_maskirq_insn自定义指令设置irq_make寄存器的值，等同于开启中断，并通过ecall指令触发异常，进而检验当前中断是否已成功开启。自定义指令的使用方式详见XXX节。
7.引导程序调用picorv32_timer_insn自定义指令，设置时钟计数器的值为10000。
8.引导程序进入循环点亮LED灯，每次循环均调用picorv32_waitirq_insn自定义指令等待时钟中断触发后再继续执行，循环8次后跳转至操作系统代码段开始执行。
9.操作系统代码段通过 .incbin伪指令直接加载到标号为text_payload_start，同时也将该地址设置为引导程序代码段偏移0x1000的地址。操作系统的代码段组织详见XXX节。
10. 引导程序代码段将用户可执行程序文件通过 .incbin伪指令放置在elf_payload_start标号处，其地址的分配与组织形式详见XXX节。
11.引导程序中断处理程序从地址为0x10处开始执行。由于启用了q0~q3
，所以可使用q2 ~q3作为scratch来存储x1、x2寄存器的值，故通过picorv32_setq_insn自定义指令将x1和x2的值设置到q2和q3之中。

保存中断现场
12.中断处理程序将irq_regs赋给x1寄存器，irq_regs即在RAM中分配给中断处理程序的地址，用以存储引发中断时各通用寄存器的值，并将中断返回地址存储在偏移量为0处，其余寄存器按照下标存储在n*4偏移量处。
13.中断处理程序将irq_stack赋给sp寄存器，irq_stack即在RAM中分配给中断处理程序的堆栈地址。
14.中断处理程序将irq_regs和q1寄存器的值作为参数，并调用中断处理函数解析中断类型并做出相应处理。中断处理函数详见XXX节。
15.从中断处理函数返回后，中断处理程序将恢复中断现场，重新设置时钟计数器。
16.调用picorv32_retirq_insn自定义指令返回原程序继续执行。
17.因为CPU进入异常模式时自动屏蔽中断，故无需额外加入代码开关中断，即不允许嵌套中断。


中断处理函数
中断处理函数使用C语言编写，其声明形式在firmware.h头文件中定义，其实现在irq.c文件中。为避免跨平台导致的数据长度冲突，在头文件中加入对stdint.h的引用，则在编写程序时直接使用C99标准库所定义的数据类型，而不使用gnu C标准库。
中断处理函数声明形式为
uint32_t * irq(uint32_t *regs, uint32_t irqs);
可见，irq函数需要传递两个参数，第一个参数为指向存储中断现场通用寄存器的内存指针，第二个参数为中断类型掩码。由XXX节可知，这两个参数分别通过a0和a1寄存器传入。中断处理函数返回值为指向存储通用寄存器的内存指针。
根据XXX节，系统中预设中断信号的定义共有3类，分别对应中断掩码中下标为0~2的比特位，其中0号比特位为时钟中断，1号比特位为异常指令EBREAK、ECALL，同时包括非法指令，2号比特位为访存地址不对齐异常。irq处理函数首先需要根据传入的irq掩码判断出具体的中断类型号，即依次比较判断相应位的值。

对于1号时钟中断，系统设计的处理方式为通过全局静态变量存储时钟中断触发的次数，每次触发时钟中断时，便打印 “[TIMER-IRQ] + 时钟中断次数”字符串至终端。

对于2号异常指令中断，则需要进一步判断引发中断的原因。
根据XXX节可知，存储中断现场通用寄存器的内存指针regs的0地址偏移处存储的值为中断处理程序返回地址，根据对异常的实现可知，对于ECALL、EBREAK一类的触发软中断的异常指令，其返回地址为触发软中断指令的下一条指令地址。故可通过计算得出异常指令地址，其计算方式如下：
uint32_t pc = (reg[0] & 1) ? regs[0] – 3 : regs[0] – 4;
pc的值即为异常指令地址，并确保其以字为单位对齐。

进而访问内存将该地址处的指令读取回来做进一步的判断。
通过如下语句读取中断指令，并存入instr变量中。
uint32_t instr = *(uint32_t *)pc；

此时根据RISC-V指令编码手册，比较instr的值即可判断出异常指令的类型。
若为EBRAK指令，则instr的编码如下
0x001000073。
若为ECALL指令，则instr的编码如下
0x00000073。
否则可以判断该指令为非法指令。

对于3号访存地址不对齐中断，系统设计的处理方式为打印提示信息：“Bus Error“，然后停机等待重启。

中断调试信息的设计。
由于传入的参数包括对存储通用寄存器的内存地址，设计将通过打印由于寄存器的值作为调试信息帮助开发过程中对软件进行调试，在遇到ebreak指令或者非法指令时将打印所有寄存器的值。通过两个循环语句，系统分别用下标访问存储通用寄存器的数组对应值，并将该值以16进制形式打印，4个寄存器为一行打印。

系统调用函数的设计
为实现对上层应用提供服务接口的功能，引导程序通过ecall软中断的形式提供系统调用接口。由于中断处理函数没有预留参数作为系统调用号，设计将自定义系统调用函数的参数传递规则。
系统调用函数的参数传递规则如下：
a0 ~ a3 ------ 系统调用函数参数
a7     ------ 系统调用号
a0     ------ 系统调用函数返回值
故中断处理函数直接读取regs数组中偏移量为10~13（a0~a3）的值即可得到传递的三个参数，通过读取regs数组中偏移量为17（a7）的值即可用于判断系统调用类型。
在中断处理函数中，定义中断类型号的枚举类型如下：
enum sbi_call_t {
	SBI_SET_TIMER = 0,
	SBI_CONSOLE_PUTCHAR = 1,
	SBI_CONSOLE_GETCHAR = 2,
} ;
系统仅实现三种系统调用。
对于SBI_CONSOLE_PUTCHAR系统调用，即向console打印一个字符，其通过将第一个参数a0传入的的值传递给由输入输出驱动提供print_chr函数实现功能，返回值为0。
对于SBI_CONSOLE_GETCHAR系统调用，即向console打印一个字符，其通过调用输入输出驱动提供的getchar函数，对字符进行接收。输入输出驱动的实现详见XXX节。

基本输入输出驱动的设计
运行系统的硬件平台通过UART串口与上位机进行交互，即通过串口向上位机发送数据，上位机接收后，通过串口工具进行显示，反之同样可由串口工具向硬件平台发送数据，进而由系统接收处理。
UART的功能直接通过Quartus IP核RS-232系列实现，其配置和使用方式详见XXX节。
驱动程序主要访问和使用的寄存器包括rxdata、txdata、status寄存器，其偏移量分别为0、1、2，以字为单位。由XXX节可知，UART控制器的基址为0x0200_0000，故分别对三个寄存器的基址的进行宏定义，如下
#define INPORT	 (*(volatile uint32_t*)0x02000000)	 //uart_rx
#define OUTPORT  (*(volatile uint32_t*)0x02000004)   //uart_tx
#define uart_status  (*(volatile uint32_t*)0x02000008)

由于寄存器以字为单位，故使用uint32_t类型的指针指向内存映射的UART设备寄存器。

volatile关键字的使用是为了避免编译器对使用该变量值的地方做过多优化，例如在执行检查status寄存器中的发送允许位trdy时需执行循环等待，如下:
while(!(uart_status & 0x0040));
若未使用volatile关键字，则编译器在进行数据流分析时，将认定该循环中没有任何能够改变uart_status寄存器的语句，则会将该语句优化为
if(!(uart_status & 0x0040)) {
	for(;;);
}
显然此时编译器优化导致代码中循环判断status寄存器值的功能发生改变。
通过volatile关键字即可使编译器在使用该变量时必须每次重新读取其值，而不是直接使用保存在寄存器中的备份。

print_char函数的实现
printf_char函数的功能为向txdata寄存器发送数据，输入参数为需发送的字符，返回值为0。
在发送数据之前，调用trdy函数判断当前UART的状态，若为可发送状态，则向txdata寄存器发送数据。
getchar函数的实现
getchar函数的功能为从rxdata寄存器读取数据，无输入参数，返回值为读取的寄存器数据并将其转换为char类型。在读取数据之前，调用rrdy函数判断当前UART的状态，若为可读取状态，则从rxdata寄存器读取数据。

此外，驱动程序还在print_chr函数的基础上，实现打印字符串的函数print_str，打印十进制数字的函数print_dec以及打印十六进制的函数print_hex。


Rust操作系统的设计
最小化内核
操作系统的本质是一个独立式可执行程序，即裸机程序。这决定了操作系统的编写过程与一般直接在系统中运行的可执行程序不同，其最大的特点是无法使用依赖于某特定平台的函数库。此外，由于编译器没有符合硬件平台的特定目标结构，因此其编译也必须以特殊方式进行。

通过cargo新建系统工程，xy_os。
执行如下命令，默认新建二进制可执行项目
cargo new xy_os 

执行如下命令测试项目是否可以正常运行
cargo run

其运行效果如下
z@z-X555LI:~$ cargo new xy_os
     Created binary (application) `xy_os` package
z@z-X555LI:~$ cd xy_os/
z@z-X555LI:~/xy_os$ cargo run
   Compiling xy_os v0.1.0 (/home/z/xy_os)
    Finished dev [unoptimized + debuginfo] target(s) in 0.34s
     Running `target/debug/xy_os`
Hello, world!

此时该项目为针对x86平台Linux操作系统构建的二进制可执行项目。

更改编译的目标架构
为了让编译器编译出符合目标架构的操作系统，需要根据架构特点进行更改。
Rust使用LLVM作为其编译器后端，首先查看rust支持编译的目标机器架构，执行如下命令：
rustup target list
截取部分输出结果如下：
z@z-X555LI:~$ rustup target list
mips-unknown-linux-gnu
riscv32imac-unknown-none-elf
riscv32imc-unknown-none-elf
riscv64gc-unknown-none-elf
riscv64imac-unknown-none-elf
x86_64-unknown-linux-gnu (default)

target各字段的含义分别为cpu 架构、供应商、操作系统和ABI。可见，当前rust编译器的默认架构为x86_64-unknown-linux-gnu，即为x86_64的CPU，未知厂商，linux操作系统、gnu ABI目标架构。
由输出结果可知rust编译器支持riscv32架构，但无法保证完全与系统兼容，因此需要使用json文件对LLVM的目标三元组进行自定义，并在编译项目时通过 --target json文件名指定。
在项目中新建文件xy_ox.json。
	json文件的内容如下：
{
  "llvm-target": "riscv32",
  "data-layout": "e-m:e-p:32:32-i64:64-n32-S128",
  "target-endian": "little",
  "target-pointer-width": "32",
  "target-c-int-width": "32",
  "os": "none",
  "arch": "riscv32",
  "cpu": "generic-rv32",
  "features": "+m",
  "max-atomic-width": "32",
  "linker": "rust-lld",
  "linker-flavor": "ld.lld",
  "pre-link-args": {
    "ld.lld": ["-Tsrc/boot/linker.ld"]
  },
  "executables": true,
  "panic-strategy": "abort",
  "relocation-model": "static",
  "eliminate-frame-pointer": false
	
选择的llvm目标架构为riscv32，小端序，int类型和指针宽度均为32位，同时指定自定义链接脚本对操作系统进行链接，链接脚本详见XXX节。

去除标准库的引用
	查看项目中main.rs文件内容，如下
fn main() {
    println!("Hello, world!");
}
该文件默认使用标准库中的println!宏进行格式化输出。

需暂时将该宏的使用去除。
在文件中加入如下语句关闭编译器默认链接标准库的功能
#![no_std] 
#![no_main] 

其中，no_main代表不再链接标准库，则程序将不再使用运行时库。no_main代表不再使用Rust默认的函数入口点。

Rust规定当程序发生异常时需要有相应的函数对其进行处理。标准库对应的函数为panic，当关闭对标准库的使用时，该函数便无法被编译器使用，为避免程序出现错误，需要实现与panic同名的函数，其实现如下：
use core::panic::PanicInfo;

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    loop {}
}

Rust语言实现不依赖于平台的core 库，包含基础的 Rust 类型，如 Result、Option 和迭代器等。panic函数使用core库中错误信息类型PanicInfo作为参数。

	标准的Rust程序对于panic的处理为进行堆栈展开，以析构堆栈中的所有生存变量，达到释放内存的目的。此时将使用到'eh_personality'语义项，同样在标准库中被定义，解决方式为将堆栈展开禁用。
	修改Cargo.toml文件，加入如下语句：
[profile.dev]
panic = "abort"

[profile.release]
panic = "abort"

堆栈设置
由XXX节引导程序启动操作系统的方式可知，引导程序并没有为操纵系统设置堆栈，因此在跳转至main函数运行前，需通过手动方式设置堆栈，操作系统堆栈分配详见XXX节。
初始化堆栈的功能可使用汇编指令实现，Rust通过global_asm!宏可使用内嵌汇编指令，同时可通过include_str!将特定文件作为字符串包含到目标文件中。
在main.rs文件中添加如下内容：
#![feature(global_asm)]
#![feature(asm)]
global_asm!(include_str!("boot/entry.asm"));

#![feature(global_asm)]为增加global_asm特征开启对汇编的支持。

entry.asm 内容如下
.section .text
    .global _start
_start:	

    lui sp, %hi(bootstacktop)
    addi sp, sp, %lo(bootstacktop)
    
call main

    .section .data
    .align 4 
    .global bootstack
bootstack:
    .space 2048
    .global bootstacktop
bootstacktop:

在data数据段中从标号bootstack到标号bootstacktop处预留2KB空间作为操作系统的堆栈空间。因为堆栈自地址高处向低处增长，所以将bootstacktop赋值给sp寄存器。堆栈初始化完成后，通过call指令跳转至main函数。

操作系统main函数
在main.rs文件中实现main函数如下：
#[no_mangle]
pub extern "C" fn main(){
  
}

其中#[no_mangle]属性可以防止编译器对函数名称进行优化。
因为由entry.asm跳转至main函数遵循的是C调用规则,extern "C"使编译器在编译此函数时使用 C 调用规则，否则将默认使用Rust调用规则。pub保证该函数名可以被entry.asm访问。

由XXX节可知，Rust编译器在连接时使用rust lld，在禁用标准库后，将出现如下错误
“rust lld: error: undefined symbol: abort”，说明rust lld需要依赖符号abort，因此此处需手动实现abort函数作为标号提供给rust lld，如下
#[no_mangle]
pub extern fn abort() {
    panic!("abort!");
}

sbi支持
引导程序向操作系统提供基本输入输出系统调用，操作系统通过汇编指令ecall，并传入相应参数即可调用。为进一步方便调用，可以通过创建相应的库对系统调用进行封装，操作系统通过导入外部库方式，可通过rust函数调用方式使用系统调用功能。
系统调用库的创建，输入如下指令创建库项目bbl
cargo new --lib bbl
修改lib.rs文件内容为
#![no_std]
#![feature(asm)]
pub mod sbi;
同内核一样不链接标准库，由于需要使用ecall指令进行系统调用，故通过#![feature(asm)]特征开启内联汇编。声明公共子模块sbi。
新建文件sbi.rs实现sbi模块，其功能为对系统调用进行封装，内容如下
pub fn console_putchar(ch: usize) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}

pub fn console_getchar() -> usize {
    sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0)
}

#[inline(always)]
fn sbi_call(which: usize, arg0: usize, arg1: usize, arg2: usize) -> usize {
    let ret;
    unsafe {
        asm!("ecall"
            : "={x10}" (ret)
            : "{x10}" (arg0), "{x11}" (arg1), "{x12}" (arg2), "{x17}" (which)
            : "memory"
            : "volatile");
    }
    ret
}

const SBI_CONSOLE_PUTCHAR: usize = 1;
const SBI_CONSOLE_GETCHAR: usize = 2;

此时，操作系统即可通过调用该库中的console_putchar和console_getchar函数向console输出数据。

库导入
将bbl库复制到xy_os项目根目录中，更改Cargo.toml文件内容：
[dependencies]
bbl = {path = "bbl/"}
将该库以相对路径方式加入到项目的依赖中。

为实现操作系统代码和功能的模块化，创建一个新的模块用于管理 io。
在main.rs文件中加入IO模块的声明如下
pub mod io;

在src目录下新建模块文件io.rs，用于实现输入输出功能，其内容如下：
use bbl::sbi;

pub fn putchar(ch: char) {
    sbi::console_putchar(ch as u8 as usize);
}

pub fn puts(s: &str) {
    for ch in s.chars() {
        putchar(ch);
    }
}

通过使用bbl库实现putchar函数输出单个字符，然后进一步使用putchar函数和循环语句实现puts函数输出字符串。

格式化输出
Rust core库中带有用于格式化和打印字符串的库fmt，该库中包含将消息格式化为数据流所需方法的trait------Write，其简要信息如下。
pub trait Write {
    fn write_str(&mut self, s: &str) -> Result;
    fn write_char(&mut self, c: char) -> Result { ... }
    fn write_fmt(&mut self, args: Arguments) -> Result { ... }
}
其中，仅需为Write trait实现write_str方法即可使用其余下的方法，包括格式化输出方法write_fmt。
write_str方法的功能为，将String Slice作为参数传入，然后将该String Slice输出， 返回Result类型。仅当成功写入整个String Slice时, 此方法返回Ok(()), 在写入所有数据或发生错误之前, 此方法不会返回。
在io模块中实现该fmt trait。

首先引入core::fmt和core::Write。
use core::fmt::{self, Write};
然后定义结构体StdOut用以实现fmt trait
struct StdOut;
impl fmt::Write for StdOut {
    fn write_str(&mut self, s: &str) -> fmt::Result {
        puts(s);
        Ok(())
    }
}
函数体内直接调用XXX节实现的puts函数输出传入的参数String Slice。

格式化输出方法write_fmt
该函数的输入参数为fmt::Arguments结构的变量，可通过core::format_args宏创建。core::format_args宏为Rust core库用于格式化字符串创建和输出的核心宏，通过为传递的每个参数获取包含 {} 的格式字符串文本来发挥作用。

println！宏的实现
查看标准库中println！的实现：
#[macro_export]
macro_rules! println {
    () => (print!("\n"));
    ($($arg:tt)*) => (print!("{}\n", format_args!($($arg)*)));
}

其中包含两条匹配规则，可见其主要在print！宏的基础上加入“\n”输出。
同时加入#[macro_export]将该宏重导出至根目录。
进一步查看标准库print！宏的实现：
#[macro_export]
macro_rules! print {
    ($($arg:tt)*) => ($crate::io::_print(format_args!($($arg)*)));
}

print宏的实现为调用io模块中的_print函数，而_print的参数为format_args宏生成的Arguments变量。此时，io模块仅需实现_print函数即可实现对println宏和print宏的移植。
_print函数的功能与fmt::Write trait 中的write_fmt方法完全相同，所以可将其视为对write_fmt方法的进一步封装。
实现方式为：
pub fn _print(args: fmt::Arguments) {
    StdOut.write_fmt(args).unwrap();
}
_print函数直接将其输入参数作为write_fmt的参数调用该方法。

此时，将标准库中对println！宏和print！宏的实现复制到io模块即可。

ELF解析
操作系统设计的基本功能之一为运行ELF格式用户程序，又由于RAM空间的限制，所以将用户程序同操作系统一同固化至ROM空间中，操作系统仅对ELF文件进行解析，然后跳转至该用户程序执行。
对ELF的解析使用外界提供的Rust库xmas-elf项目。
xmas-elf项目提供对ELF文件结构的解析与提取、转换功能。
新建模块elf以实现对用户程序的解析功能，文件elf.rs内容如下。

use core::mem::transmute;
use core::slice;
use xmas_elf::{header, ElfFile,};

#[no_mangle]
pub fn elf_interpreter() {
    let _elf_payload_start = 0x9000;
    let _elf_payload_end = 0xad64;

    let kernel_size = _elf_payload_end as usize - _elf_payload_start as usize;
    let kernel = unsafe { slice::from_raw_parts(_elf_payload_start as *const u8, kernel_size) };
    let kernel_elf = ElfFile::new(kernel).unwrap();
    header::sanity_check(&kernel_elf).unwrap();

    for program_header in kernel_elf.program_iter() {
	    println!("{:?}", program_header);
    }

    let entry = kernel_elf.header.pt2.entry_point() as u32;
    let kernel_main: extern "C" fn( ) = unsafe { transmute(entry) };

    println!("kernel_main: {:#?}", kernel_main);
    kernel_main( );
}

由XXX节可知，用户程序通过incbin宏指令在被链接进引导程序中，所以可直接查看引导程序编译结果，从而定位_elf_payload_start与_elf_payload_end标号的地址，用户程序地址分配详见XXX节。
紧接着使用slice模块中的from_raw_parts函数截取从_elf_payload_start内存开始处的整个ELF程序，并存储在kernel_elf变量中，然后使用xmas_elf::ElfFile结构体将kernel_elf变量类型强制转换为xmas_elf库中定义的ElfFile结构体类型。
此时，便可依据xmas_elf库中的函数对ELF文件进行解析。
其中header::sanity_check的功能为检查ELF文件头，从而检查ELF文件正确性与完整性。
program_iter的功能为遍历ELF文件中各段信息。
header.pt2.entry_point的功能为取得ELF文件头进而解析出程序入口点。

经过解析，操作系统得到程序入口点地址并存入变量kernel_main中。
为跳转至用户程序开始执行，需要将该地址转换为函数形式。
此处，通过core库mem模块中实现的transmute将该变量类型转换为extern "C" fn函数类型。
最后调用成功转换为函数的kernel_main即可转入用户程序执行。


Hello 程序的编写
为验证操作系统解析运行用户程序的功能，需编写基于该系统的用户程序进行测试。
由于操作系统并未提供编译和库支持，用户程序的编写同操作系统相同，使用bare metal形式编写。
创建用户可执行程序hello。
cargo new hello

	新建json文件，内容与操作系统json文件相同，其链接脚本详见XXX节。
去除标准库链接，使用汇编指令设置堆栈然后跳转至main函数执行，其堆栈的分配设置详见XXX节。
	引入bbl库支持，新建io模块作为输入输出模块，同XXX节所示。
	在main函数中使用println！宏输出字符串“Hello World from user programe!”


文件的链接加载
	picorv32 CPU并未实现虚存管理所需的相关部件，加之内存资源相当局限，所以系统暂时无法实现内存的管理功能。当前运行于硬件平台中的所有程序，其内存地址均为物理地址，各程序的内存分配均由人工进行组织，并在链接脚本中指定。

系统的内存分配
引导程序链接操作系统与用户程序的方式为将其二进制程序通过.incbin伪指令方式直接嵌入至引导程序特定的地址标号处，从本质上来看，即为在引导程序中对全局的地址空间进行分配管理。
	在引入操作系统与用户程序引入之前，先对引导程序进行链接。
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
}

使用‘MEMORY’命令描述目标平台上内存块的位置与长度，ROM用于存储可执行代码段和只读数据，RAM用于存储数据段和bss段，其起始地址硬件平台中ROM和RAM的起始地址，大小则为ROM和RAM的大小。通过’SECTIONS’命令指定编译目标文件的段名。此处，仅需定义text，data，bss三个段即可。
由于RAM在开始时无法进行初始化，且引导程序并没有加载程序能够用来加载其数据段。故将使用‘AT’命令指定data段的本地加载地址LMA为代码段中的_sidata标号。
此时便可通过riscv交叉编译工具对源文件进行编译链接，编译脚本详见XXX节。
首先将汇编文件编译为目标文件
payload.o: payload.S
	$(TOOLCHAIN_PREFIX)gcc -c -march=rv32im -o $@ $<
将C源文件编译为目标文件
%.o: %.c
	$(TOOLCHAIN_PREFIX)gcc -c -march=rv32im -Os --std=c99 $(GCC_WARNS) -ffreestanding -nostdlib -o $@ $<
将所有目标文件同链接脚本一起编译为可执行ELF程序
firmware.elf: $(FIRMWARE_OBJS) sections.lds
	$(TOOLCHAIN_PREFIX)gcc -Os -g -ffreestanding -nostdlib -o $@ \
		-Wl,-Bstatic,-T,sections.lds,-Map,firmware.map \
		$(FIRMWARE_OBJS) -lgcc
通过objcopy工具将其可执行代码段提取为单独的二进制文件
firmware.bin: firmware.elf
	$(TOOLCHAIN_PREFIX)objcopy -O binary $< $@

通过转换工具将二进制文件转换为hex格式文件，即可作为ROM的初始化文件


操作系统的链接
	引导程序在进行寄存器和设备的初始化后直接跳转至链接操作系统可执行代码段标号text_payload_start处运行。引导程序编译为ELF可执行文件后，通过riscv交叉编译工具链反汇编器objdump查看其反汇编代码，指令如下：
riscv-unknown-elf-objdump -d firmware.elf | less

查看text_payload_start的地址，此地址即为作为操作系统链接脚本中可执行代码段的起始地址。
同理可查看操作系统数据段地址data_payload_start。

为了方便地址管理，将text_payload_start与data_payload_start的地址取整，使用汇编伪指令.org为标号起始地址指定偏移量，其中text_payload_start偏移量为0x1000，data_payload_start偏移量为0x300。
此时操作系统代码段和数据段的链接地址便可确定。

在操作系统项目xy_os工程中新建链接脚本linker.ld文件，其内容如下：
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
其结构与引导程序相同，使用‘MEMORY’命令描述目标平台上内存块的位置与长度，ROM用于存储可执行代码段和只读数据，RAM用于存储数据段和bss段，其起始地址即为上述所计算的标号偏移量加上硬件系统中ROM和RAM的起始地址，大小则依据操作系统实际所需分配，可重复调整直至编译成功。

通过objdopy将操作系统的代码段和数据段提取为两个文件，即
	riscv32-unknown-elf-objcopy -O binary -j .text $(kernel) xy_os.text
	riscv32-unknown-elf-objcopy -O binary -j .data $(kernel) xy_os.data
并分别加入至引导程序项目目录下一同编译。

关于为何将操作系统的代码段和数据段分别链接至引导程序不同区域，而不直接链接ELF程序的问题。
首先将代码段与数据段分开，引导程序可以省略解析ELF程序的代码功能，其次由引导程序直接跳转至可执行代码段时，操作系统的链接地址也更容易分配给定，反例参考XXX节对用户程序链接地址的计算。
最后由于引导程序数据段加载的特殊方式，将操作系统数据段单独链接至引导程序也更便于加载数据段。

用户程序的链接
用户程序将直接由ELF格式文件嵌入引导程序_elf_payload_start标号起始处，通过反汇编引导程序可查看_elf_payload_start标号起始地址。
此时，由于_elf_payload_start标号地址与程序可执行代码段起始地址不同，故无法直接将标号地址作为用户程序的链接地址。通过查看反汇编代码的形式比对用户程序起始处代码，即用于设置堆栈的汇编代码可定位到用户程序的可执行代码段起始地址。
但是，此时仍然无法将该地址作为用户程序的链接地址，原因是若此时据此修改用户程序链接脚本，该程序生成的ELF文件结构将发生改变，进而导致重新嵌入至引导程序相同地址时，可执行代码段的偏移量也会随之改变，则操作系统在解析完成该用户程序的entry时，跳转地址为旧的可执行代码段地址，从而无法正常执行。
	此时，解决方法为固定用户程序链接脚本中可执行代码段的位置，并将其取整对齐。
同时也固定_elf_payload_start标号的位置，重新编译。反汇编引导程序代码，查看其可执行代码段地址，此时必然与用户程序链接脚本中的给定地址存在偏移。
假设用户程序链接脚本中可执行代码段地址为 addrld ，引导程序中可执行代码段地址为addr load，则其偏移量offset的计算方式为
offset = addrld - addr load
为使两地址偏移量为零，需要在保证用户程序不变的情况下，修改引导程序中_elf_payload_start标号的地址。
则引导程序中_elf_payload_start标号的地址
addrelf = addrelf + offset
使用.org伪指令设置_elf_payload_start标号的地址值为addrelf。
需保证该地址值比操作系统加载地址加上操作系统可执行代码段大，否则编译器将报错。
