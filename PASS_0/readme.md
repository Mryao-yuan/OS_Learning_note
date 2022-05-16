# 简述操作系统




## 物理地址，逻辑地址，有效地址

**在实模式下**

物理地址：段基地址*16+段内偏移

**保护模式下**

地址：段基地址+段内偏移

- 打开分页

线性地址/虚拟地址

通过页表转换：物理地址

- 未打开分页

 物理地址

## 魔数

在操作系统中具有特殊意义的数字如：0x55 和 0xaa，0x7c00

- 当BIOS检测到扇区中最后两个数为 0x55 和 0xaa 就可以确定该扇区是要寻找的MBR 

- 0x7c00：BIOS将其所检查的第一个扇区载入的内存地址

## 指令集

- 指令集：具体的一套指令编码（X86,ARM）

- 微架构：指令集的物理实现方式

## MBR，EBR,DBR和ODR

这几个概念都是围绕计算机的控制权而衍生的。

- MBR（Main Boot Record）：主引导记录

   <strong>扇区内容</strong>

1. 446字节的引导程序及参数
2. 64字节的分区表
3. 2字节的结束标记 0x55 和 0xaa

位于整个硬盘的最开始扇区（0盘0道1扇区）

- DBR （DOS Boot Record）：DOS操作系统的引导记录

    <strong>扇区内容</strong>

1. 跳转指令，使 MBR 跳转到引导代码
2. 厂商信息，DOS版本信息
3. BIOS 参数块 BPB （BIOS Parameter Block）
4. 操作系统引导程序
5. 结束标记 0x55 和 0xaa

- EBR（Expand Boot Record）：拓展启动记录

为了解决分区数量限制，与MBR的结构相同，但是位置数量不同，MBR只有一个，位于整个硬盘最开始的扇区，但是 EBR 有无数个，具体位置取决与拓展分区的分配情况

<strong>区别</strong>