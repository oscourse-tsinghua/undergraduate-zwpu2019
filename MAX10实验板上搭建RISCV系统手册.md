# 基于小脚丫MAX10开发板的RISCV SoC搭建手册

## 硬件平台
	小脚丫MAX10开发板。STEP-MAX10是小脚丫平台基于Altera公司芯片开发的FPGA开发板。板卡集成下载器，使用MicroUSB数据线可完成开发板的供电与下载。

- 核心器件：Altera 10M08SAM153
o	8000个LE资源， 最大172KB 用户闪存，378Kbit RAM；
o	2路PLL；
o	24路硬件乘法器；
o	支持DDR2/DDR3L/DDR3/LPDDR2存储器；
o	112个用户GPIO；
o	3.3V电压供电；
o	板载资源：
	两个RGB三色LED；
	8路用户LED；
	2路RGB LED；
	4路拨码开关；
	4路按键；
	36个用户可扩展I/O； 
- 支持的开发工具Altera QuartusII； 
- 一路Micro USB接口； 
- 一个10pin的JTAG编程接口； 

![开发板正面](IMG/)

![开发板背面]()

## 环境搭建
### 通过脚本安装
执行在下载的工程根目录下执行nix-shell命令即可按照引导安装环境。（需要Nix Package Manager）将会安装
 - Synthesis: Recent Yosys and SymbiYosys
 - Place and Route: arachne-pnr and nextpnr (ICE40, ECP5, Python, no GUI)  # - Packing: Project IceStorm (Trellis tools may be included later?)   
 - SMT Solvers: Z3 4.7.x, Yices 2.6.x, and Boolector 3.0.x 
 - Verification: Recent Verilator, Recent (unreleased) Icarus Verilog 
 - A bare-metal RISC-V cross compiler toolchain, based on GCC 8.2.x
等一系列工具

### 通过源码安装
#### RISCV交叉编译工具链
##### 安装依赖性
对于 Ubuntu 用户：

	$ sudo apt-get install autoconf automake autotools-dev curl libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev

对于 Fedora/CentOS/RHEL 用户：

	$ sudo yum install autoconf automake libmpc-devel mpfr-devel gmp-devel gawk  bison flex texinfo patchutils gcc gcc-c++ zlib-devel
    
对于 MacOS 用户：

	$ brew install gawk gnu-sed gmp mpfr libmpc isl zlib
    
##### 下载源码

通过命令架构仓库克隆至本地
	
    git clone https://github.com/cliffordwolf/picorv32.git

进入根目录，执行

	make download-tools 
    
    sudo make -j$(nproc) build-tools
    
  通过以上两条命令可以自动下载Riscv源码并安装riscvi[m][c] 编译链至/opt目录下，若需自定义安装可以更改Makefile文件，或直接参照Riscv官方安装教程。

  安装完成后，进入/opt目录下任意一个riscv目录中的bin，执行riscv32-unknown-gcc，以确定是否完成安装，最后将bin目录添加至环境变量中。
  
#### 安装gtkwave

对于Ubuntu用户：

	sudo apt-get install gtkwave
    
对于Centos用户：

	sudo yum install gtkwave
    
#### 安装iverilog

对于Ubuntu用户：

  直接使用apt-get安装的iverilog与项目本身的verilog代码不兼容，故需要自行下载iverilog 源代码并安装。

[官网教程](https://iverilog.fandom.com/wiki/Installation_Guide)

对于Centos用户:

	sudo yum install iverilog
    
### 安装Quartus

  下载Quartus Lite版本，建议在windows环境下安装，因为64位 Linux环境对Modelsim的库支持不当，配置过程繁琐复杂，所以可能导致仿真环境无法使用。
根据安装的Quartus更改Makefile中的Quartus版本和路径。

## Picorv32
	Picorv32是由著名IC工程师Clifford开发设计的开源RISCV软核，主要专注于小体积，高频率，低功率的功能。

### CPU 接口
  Picorv32包括多种对外接口的CPU，如SRAM接口，AXILITE接口，WISHBONE接口等。不同接口CPU的内部实现逻辑相同，均为以SRAM接口CPU作为核心，再增加相应接口转换模块。使用者可以通过配置参数实现对CPU部件和功能的选择。

### 仓库源码分析
     
![项目根目录]()
    
#### Dhrystone
   Dhrystone是测量处理器运算能力的最常见基准程序之一，常用于处理器的整型运算性能的测量。
 
  此处，引入Dhrystone对SRAM接口的CPU进行测试，其中有两个testbench，分别针对是否使用look-ahead接口进行访存的CPU性能进行比较评测。“Look-Ahead Memory”接口即提前一个时钟周期给内存发送读取信息的信号接口。Testbench对picorv32进行例化，实现256KB大小的memory，并增加虚拟UART，使其能够在仿真环境下输出信息。

  通过对stdlib.c syscall.c等库函数的实现，达到库移植的效果。程序由start.S开始执行，在sections.lds指定可执行代码段和数据段等放置在0x10000处，同时将启动地址0x10000作为CPU参数传递给picorv core，地址空间低64KB作为堆栈空间。

该测试环境的SoC布局如下：

![Dhrystone]()

![Dhrystone测试SoC布局]()

执行

在此目录下执行make test 可对不带look-ahead功能的cpu进行测试，执行make test_nola 可对带look-ahead功能的cpu进行测试。具体测试方法及参数可参照该目录下的Makefile。

#### Firmware、tesets
  
  Firmware目录通过使用官网提供的测试用例tests搭建测试环境，主要针对picorv32指令的实现的正确性进行测试，其测试范围包括所有Riscv 整数模块和乘除法模块，也包括对中断异常，梅森素数C程序进行的测试，自行实现printf等输出库函数。

  
  tests目录为官网提供的所有单条指令测试用例，Clifford通过riscv_test.h文件指定输出单条指令测试执行完毕后输出的信息。

该测试的SoC布局为

![firmware测试SoC布局]()

#### Picosoc

  该目录为针对Lattice系列型号开发板所开发的SoC，通过该SoC及配套程序测试对不同SPI读写模式下读取Flash数据的性能。该SoC包含Flash读写控制器，SRAM读写控制器，UART模块等等外设。程序存储在SPI Flash中，并在初始化后将Flash中的数据拷贝至SRAM中。
  
  该测试的SoC布局如下
 
 ![picosoc测试SoC布局1]()
 
 ![picosoc内存布局]()
 
 #### Scripts
 
   使用Picorv32 CPU针对不同厂商，不同型号搭建的SoC，用于测试不同芯片型号下该CPU所占用的资源和能够达到的最高的频率。若需运行则需要安装不同厂商配套的开发环境套件，并指定至相应目录中的Makefile中。

#### picorv32.v

  该模块即为Picorv32 CPU的所有verilog源码实现。其中包含多个模块，主要是在Picorv32模块的基础上增添对外接口拓展，如AXI-LITE,WISHBONE等接口。
  
![picorv32.v模块]()

#### testbench.v

  对AXI 版本的picorv32进行测试，包括了SoC的实现源码。运行的程序是Firmware。输入make test即可运行，其余参数可参考Makefle。

#### Testbench_ez.v
  
  对原生SRAM接口的picorv32进行测试。运行的程序是为简单的循环示例。输入make test_ez即可运行。

#### Testbench_wb.v

  对WISHBONE版本的picorv32进行测试，运行的程序是firmware。输入test_wb即可运行。

## STEP MAX10开发板  SoC设计

![MAX10SOC]()

地址映射

| 部件名称 | 起址地址 | 大小 |
| ----------| --------- | ----- |
| ROM      |  0x0000_0000 ~ 0x0000_3fff  | 16KB |
| RAM      |  0x0000_4000 ~ 0x0000_77fff  | 16KB |
| UART      |  0x0000_0000 ~ 0x0000_3fff  | 32 Bytes |
| LED      |  0x0200_0000 ~ 0x0200_01f  | 16 Bytes |
| SW      |  0x0300_0010 ~ 0x0300_001f  | 16 Bytes |
| SEG1      |  0x0400_0000 ~ 0x0400_000f  | 16 Bytes |
| SEG2      |  0x0400_0010 ~ 0x0400_001f | 16 Bytes |

### 使用原生SRAM接口picorv32搭建

#### 新建工程
  打开Quartus，新建工程，芯片型号选择10M08SAM153。
  
  将picorv32.v加入至项目。
  
#### UART
   部分IP核如UART RS-232为Avolon接口，故无法直接使用这类IP核。UART模块使用picosoc目录下的simpleuart.v文件。
  
  Simleuart模块包括一个分频系数寄存器，用于配置波特率，一个数据收发存储寄存器。 对于分频系数寄存器和数据寄存器的读写采用分开的SRAM接口，可直接连接读写。 读写方式为1位起始位，8位数据位，1位停止位，无校验位。
分频系数计算公式为 

divsors=(clock frequency)/(baund rate) 。

#### ROM
ROM模块用于存储运行程序，直接使用原生接口的ROM IP核即可。
位数选择32bits，大小选择4096words。
![ROM1]()

无需锁存输出值
![ROM2]()

使用Intel Hex格式文件（参考XXX节）对ROM IP和进行初始化。
![ROM3]()

点击Finish，生成 .qip文件并加入至工程中。同时查看生成的 .v，使用该模块的接口对ROM IP进行例化。

#### RAM
RAM模块作为数据的存储和堆栈区域，直接使用原生接口的RAM IP核即可。

位数选择32bits，大小选择4096words。
![RAM1]()

选择不锁存数据，并且加上byteenable。
![RAM2]()

当CPU同时读写同一地址时，返回新的数据。
![RAM3]()

RAM无需初始化。
![RAM4]()

#### PLL
加入pll模块，生成50Mhz时钟。
输入时钟选择12Mhz
![PLL1]()

选择能够reset复位，并输出locked作为其余模块的reset_n。
![PLL2]()

选择确定的输出频率为50Mhz。
![PLL3]()

#### SEGMENT
加入segment.v模块，segment.v为对数码管需要显示的数据进行译码的模块。

#### 顶层模块
  在顶层模块对各个部件进行例化，加入GPIO寄存器和sw按键寄存器，以实现对LED和按键开关的控制。根据SoC设计在顶层中对CPU发出的访存地址进行映射，具体实现见picosoc.v。

  使用原生SRAM接口的picorv32无法使用Quartus自带的platform designer（Qsys）对各部件进行连接和地址分配，故使用Verilog在顶层模块中对SoC各个部件的各个部件进行连接并对映射分配地址。

#### 时钟约束
  增加时钟约束，新建Synnopsys Design Constraint File，写入clock源时钟约束，12Mhz时钟的周期为83.33ns。

#### 仿真
  编写testbench在仿真环境下观察程序运行结果，仿真环境下同样需要模拟出12Mhz的输入频率，才能确保UART输出波形的位宽正确。
  
#### 配置启动方式
  在Assignment->Device->Device and Pin Options->Configuration-> Configuration Mode选择带 With Memory Initialization的启动方式。

  若未设置启动方式，则综合后项目将报如下错误
  
  ```
  Error (16031): Current Internal Configuration mode does not support memory initialization or ROM. Select Internal Configuration mode with ERAM.
  ```
  
#### 配置引脚
  综合项目后对引脚进行配置，其中数码管为共阴极，LED为低电平点亮，将RX和TX接入任意的GPIO引脚，编译项目即可。
  
#### 项目下板
  为MAX10开发板的GPIO口，VBUS和GND焊上杜邦线公头，用杜邦线将MAX10和TTL转USB设备（3.3V）接口相连，并将TTLB转USB设备连接至电脑。
  
  打开串口助手，设置波特率，项目下板后即可看到程序运行的打印信息。

### 使用AXI-LITE接口picorv32搭建SoC
  为方便使用Platform designer（Qsys）进行系统构建，并进一步拓展各部件的功能与实用性，可选择对picorv32进一步封装为AXI-LITE接口的CPU。
  
  Qsys官方IP核接口为Avolon接口，但也能够兼容AXI, AXI-Lite,AXI-Stream等一系列总线协议，即使用以上接口的IP核皆可在Qsys中直接相互连接。

#### 封装IP核
  使用Qsys中的new component功能建立新的AXI-lite	IP核

 ![picorv32-axi1]()
 
  为了让Qsys能够直接识别接口类型和自动分类，需要在picorv32_axi模块的基础上进行封装，将其接口名称按照Qsys对于AXI类型接口的命名规范进行命名，其次可以去除picorv_axi中一些不必要的接口，仅留下时钟，复位，中断，AXI-LITE接口即可。
  
  根据Quartus  Platform Degsigner 用户手册ug-qps-platform-designer.pdf Table 160. 使用以下前缀能够使平台自动识别接口类型。
 ![axi-interface]()

  添加对picorv32封装的picorv32_axi_wrapper.v和picorv32.v，此时需要将picorv32_axi_wrapper作为Top-level File，添加完成后综合文件。
 ![picorv32-axi2]()

  若系统无法自动对齐信号，需要自行选择接口和信号。
 ![picorv32-axi3]()

  此时reset的signal type设置为reset_n，保证复位信号为低电平有效。
 ![picorv32-axi4]()
 
 因为需要运行包含乘除法的基准测试和执行中断，所以将ENABLE_MUL ENABLE_DIV ENABLE_IRQ参数设置为1，其余参数的功能可参考README。
  ![picorv32-axi5]()
  
#### ROM
  加入ROM IP核，大小选择16384 Byte（16KB），并使用hex文件进行初始化。
  ![picorv32-rom1]() 
  
  ![picorv32-rom2]() 

  加入RAM IP核，大小为16KB。
  ![picorv32-ram1]() 


  加入UART RS232 IP 核
  ![picorv32-uart1]()
  波特率选择115200，去掉Fixed baud rate的选项。
    ![picorv32-uart2]()
  根据ug_embedded_ip.pdf Table95，UART RS-232内部寄存器分配如下，
    ![picorv32-uart3]()
    
  波特率的计算方法：
  
Divisor=((clock frequency)/(baud rate)) -1

  根据项目实践经验，若pll 时钟IP核 input clock为12Mhz，output clock为50Mhz，baud rate为115200， 则
  
  Divisor = 12Mhz / 115200 = 104。
  
  此时需要在程序运行后通过写入Divisor的值才能够让串口正常工作。
若若pll 时钟IP核 input clock为50Mhz，output clock为50Mhz，baud rate为115200， 则

Divisor = 50Mhz / 115200 = 434。

此时运行程序无需额外写Divisor，串口即可按照预先设定的波特率正常工作。


加入两个PIO模块分别作为LED数据显示和数码管数据输出。
![pio1]()

![pio2]()


将各部件连接
![picorv32-axiconnector]()


按照设计更改外设地址，更改外设名称，添加对外接口。
![picorv32-addr]()

点击finish，并生成qsys文件。

#### 例化qsys
将pico_axi.qsys文件加入项目工程，该模块的例化示例在pico_axi_inst.v文件中。

在顶层模块中例化pico_axi，加入对数码管数据显示的译码模块segment.v。

#### 时钟、引脚
加入时钟约束，配置引脚等与XXX相同。

## 软件移植
  此时，需要编写脚本和工具将C语言、汇编等源程序编译为Riscv架构下的可执行ELF文件，并将可执行代码段与只读数据段转换为hex格式文件。
  
  为了确保SoC搭建的正确性，需要使用官网测试用例对SoC进行验证，故可以以firmware目录下的测试程序为基准，对自行搭建的SoC进行适配，主要修改内容包括根据外设地址（UART）进行修改，并将数据段复制至RAM中进行初始化。
  
  根据XXX节的对firmware所测的SoC的描述可知，该firmware程序运行在64KB的RAM中，其UART地址为0x1000_0000。
  
  由于MAX10中的内存容量较小，无法将编译出来的firmware程序完全放置在芯片之中，故针对firmware程序作出适当的剪裁。
  
  首先去掉firmware目录下的所有C语言文件，即去除print功能，去除查找梅森素数的C语言程序sieve.c，去除对中断，异常进行处理的irq.c，去除multest.c，stats.c，
  同时在Makefile中将firmware目录下C文件生成的目标文件链接至ELF文件的代码去除。
  其次，需要在start.S中去除调用这部分功能的代码（将文件开头ENABLE_XXX的宏注释）。
 
  更改start.S中输出“DONE”信息部分代码的UART地址，即将0x1000_0000改为0x0200_0004；

  此外还需更改tests/riscv_test.h文件中输出TEST_FUNC_NAME处的串口地址和对于单条指令运行成功或失败时执行的代码部分。
  
  在此项目中，作者将RVTEST_PASS宏和RVTEST_FAIL宏设置为往串口输出“OK”，“ERROR“信息，故更改串口地址即可。
  
  若使用UART RS-232 IP核，则无法连续打印字符，需要在每次写串口之前加入判断status寄存器trdy位的代码。

  此时回到firmware目录下对sections.lds文件进行修改，可以看出该链接脚本直接将所有程序段放置在0x0000_0000~0x0000_c000的地址空间内。
  
  根据SoC地址空间分布，
  需将程序的可执行代码段和只读数据放置在0x0000_0000~0x0000_3fff处的ROM处，
  将数据段放置在0x0000_4000~0x0000_7fff处的RAM段。
  
  此外，因为在对访存指令的测试中需要对内存段进行初始化，故需要将数据段的加载地址LMA放置在输出文件的text段中，即使用AT(ADDRESS)属性定义该.data程序段的加载位置。
  
  最后，在start.s文件开头读取ROM中内存数据并初始化至RAM中。
  
  具体修改可参照仓库代码firmware.lds。

  使用Makefile对程序进行编译，输入make firmware/firmware.bin文件生成二进制文件。

  此时仍可能出现如下错误，segmentation fault，提示信息为程序过大，无法完全放入ROM空间中。

  故说明无法一次性运行所有官方测试用例，此时可分四个批次对TEST的代码分别运行。
  通过更改根目录下的Makefile文件，将tests目录下的目标文件部分链接至firmware可执行文件中。
此时执行make命令即可生成bin文件。


## Intel HEX格式文件

### 格式说明
  Intel HEX 文件是遵循 Intel HEX 文件格式的 ASCII 文本文件。在 Intel HEX 文件的每一行都包含了一个 HEX 记录。
Intel HEX由任意数量的十六进制记录组成。每个记录包含5个域，它们按以下格式排列：
![HEX]()

Start Code  每个 Intel HEX 记录都由冒号开头
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


### 生成方式
  1. 通过Riscv工具链可将汇编文件和C文件编译为ELF可执行文件。
  2. 通过Riscv中的Objdump将ELF文件中的代码段和只读数据段提取为bin文件。
  3. 自行编写程序将bin文件转换为hex格式，此处提供两个程序进行转换。bin2coe.py------ 将bin文件读入，然后转换为以32位指令一行的data，并加入Start code，byte count，address，record type，命名为coe格式（不是标准coe）。coe2hex------将coe文件读入，然后计算并加入checksum。

### objcopy
  objcopy中自带的BFD库中支持ihex格式，可通过-O参数指定，即可编译成Intel Hex格式，但此时的数据为小端数据，若用于初始化以32bits字为单位的ROM IP核，则从ROM IP核中读取出来的数据的大小端则会相反。此外，若ROM IP指定为32bits的，则用于初始化的hex格式地址也应该以按字编址作为数据的起始地址，而不是按字节编址。
  
## 调试帮助
  若串口无法正常工作，可按照以下方式进行调试。
  
### 编写程序
  首先编写简单的串口测试程序，主要功能为设置UART的divisor数值，
  然后读取divisor并将其显示至数码管，循环往串口写入同一字符， 
  同时判断status寄存器，是否从上位机接收到数据，若检测到数据则将该字符回显至终端，
  与此同时需要让LED在一段时间后不断变化，以判断下板后程序是否一直在运行。

### 在仿真环境下查看波形。
  在testbench文件中设置输入时钟为12Mhz,即与STEP FPGA MAX10实验板上的晶振频率相同。
  若使用UART RS-232 IP核搭建环境，则其在仿真环境下默认的divisor为4，在程序中写入divisor后会变成设置的数值。
  在testbench中模拟上位机给rx接口发送数据，每一位符号的持续时间为 divisor*cycle。
  运行后，首先观察tx和led是否有变化，波形是否与预期的效果相同。
  若不相同，则检查此时程序运行的状态，判断是程序的逻辑问题还是SoC的搭建问题。
  若波形按照预期效果显示，但是tx的宽度与rx接收的宽度不相符，则是divisor的问题。

### 下板环境
  若以上问题解决后，下板后在真实环境下未出现预期效果，则可通过示波器等直接接入引脚tx。
  若SoC中运行的程序为特定时间内网tx发送同样的数据，则示波器能够明显接收到稳定的信号波形，
  或者通过Trigger设置低电平触发，则运行后若有数据发送至tx，则示波器将捕捉此处发送的数据。
  tx发送的高电平为3.3v，使用measure功能对每一位符号的发送位宽进行测量，其tx发送的波特率即为
  baud rate=1/∆x。
  最后，可利用Quartus 自带的下板测试功能Signal Trap Logic Analyzer，下板后捕捉SoC内部的信号。
