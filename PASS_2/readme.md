# BIOS详解

BIOS（Basic Input/Output System ）：基本输入输出系统，主要工作是检查，初始化硬件，建立中断向量表（IVT），这样子可以通过“ INT 中断号”来实现相关硬件的调用。

BIOS 是系统中的第一个运行的软件，是通过硬件加载，其入口地址为 0xFFFF0,在电脑开机的那一瞬间CPU 的 cs：ip 就被置为 0xF000：0xFFF0，进入 BIOS 地址开始执行 BIOS程序 ;但是 0xFFFF0到 0xFFFFFF 之间只有 16字节，故 BIOS 程序并不在此处,通过跳转指令 jmp far f000:e05b 来跳转到 0xfe05b（实模式下段基地址要*16） 处，开始执行 BIOS 的硬件检测，并在 0x000～0x3ff 出建立数据结构，中断向量表（IVT）中填写中断例程;最后校验启动盘中的扇区内容（通过结尾的 0x55 和 0xaa 来辨别）

<font color="orange" size="2">声明：因个人能力有限，本文仅是个人的学习记录笔记，有错误之处还望指出</font>

## MBR详解

MBR的大小必须是 512 字节，且最后两个字节必须是 0x55 和 0xaa（x86下小端存储）

- "$":表示当前行（NASM预留的关键字）

- "$$"  ：表示本section的地址（NASM预留的关键字）

- times ：重复

- db ：是一种伪操作命令，定义操作数占用的字节数

```c

; 主引导程序

SECTION MBR vstart=0x7c00
 mov ax,cs
 mov ds,ax
 mov es,ax
 mov ss,ax
 mov fs,ax
 mov sp,0x7c00 ; 栈地址为 0x7c00

; 清屏 利用 0x06号功能，上卷全部行，则可清屏幕
; 
; 中断：INT 0x10  功能号：0x06 描述：上卷窗口
; 
; 输入
; AH 功能号 = 0x06
; AL = 上卷的行数（0代表全部）
; BH = 上卷行属性
; （CL，CH）=窗口左上角的位置（x，y）位置
; （DL,DH）= 窗口右下角的位置（x，y）位置
; 无返回值
 mov ax,0x600
 mov bx,0x700
 mov cx,0  ; 左上角（0,0）
 mov dx,0x184f   ; 右上角（80,25）
     ; VGA文本模式中，一行容纳80个字符，共25行
     ; 0x18=24,0x4f=79
 int 0x10  ; BIOS中断


; 获取光标位置
; 在光标位置处打印字符

 mov ah,3 ; 输入 3 子功能是获取光标位置，需要存入 ah 寄存器
 mov bh,0    ; bh 寄存器是待获取的光标的页号

 int 0x10 ; 输出： ch=光标开始行，cl=光标结束行
    ; dh = 光标所在行号，dl= 光标所在列号

; 获取光标位置结束


; 打印字符串

; 还是用 10h 中断，不过这次调用 13 号子功能打印字符串
 mov ax,message
 mov bp,ax  ; es：bp 为串首地址，es 此时同 cs 一致
     ; 开头时已经为 sreg 初始化
 ; 光标位置要用到 dx 寄存器中的内容， cx 中的光标位置可忽略 
 mov cx,16        ; cx表示串长度（1 MBR ）长度是 5，不包括结束符 0 的字符个数
 mov ax,0x1301 ; 子功能号：13 是显示字符及属性，要存入 ah 寄存器
     ; al 设置写字符方式 al=01 ： 显示字符串，光标随着移动
 mov bx,0x2  ; bh 存储要显示的页号，此处是第 0 页
     ; bl 是字符属性，黑底绿字（bl = 02h）

 int 0x10

; 打印字符结束

jmp $ ;程序跳转至此

; 输出 1 MBR
message db "MY OS is Loading"

; 用0填充 当前行到section的地址之间没数据的地方用 0 填充 
times 510 -($ -$$) db 0

db 0x55,0xaa

; db 是一种伪操作命令，定义操作数占用的字节数

```

## 创建硬盘

查看bximage命令
> bximage --help

1. 运行 bximage
2. 选择 1 （Create new ...）创建新的硬盘镜像
3. 输入 hd （创建硬盘镜像）
4. flat （硬盘类型）
5. 512 （扇区大小）
6. 16 （硬盘大小）
7. xx.img（输出镜像的名称）

可以直接配置

> bximage -q -hd=16 -mode=create -sectsize=512 -imgmode=flat mas    ter.img

## 配置bochs

1. 运行 bochs
2. 选择 4 [save options to ...] 保存配置文件到
3. 输入要将配置保存的文件 （bochsrc）
4. 7 [Quit now]  退出
5. 打开新建的 bochsrc 文件
6. 在 display_library 选项下加入 options=“gui_debug” (加入gui的显示界面)
7. boot:floppy 修改为 boot :disk (从硬盘中启动)
8. 将利用 bximage 创建的虚拟硬盘的输出写入 bochsrc 对应的目录中

![](./img/bximage)

## 编写makefile

```bash
mbr.bin:mbr.s
 nasm -o mbr.bin mbr.s
# 创建 master.img
master.img:mbr.bin
 bximage -q -mode=create -hd=16 -sectsize=512 -imgmode=flat master.img
# 将bin文件输出为 512 字节大小的 master.img 镜像 
 dd if=mbr.bin of=master.img bs=512 count=1 conv=notrunc

.PHONY:clean
clean:
 rm -rf *.bin
 rm -rf *.img
.PHONY:bochs
bochs:master.img 
 bochs -q


```

## 运行结果

>输入 make bochs

![](./img/bochs_result)
