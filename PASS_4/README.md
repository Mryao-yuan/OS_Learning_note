# 保护模式

## 保护模式详解

### 寻址方式对照

| 基址寄存器 | 变址寄存器 | 16位偏移量 |
|---|---|---|

<strong>保护模式寻址方式</strong> 

| 基址寄存器 | 变址寄存器 | 比例因子 | 32位偏移量|
| :---- | ----: | :----: | ---- |
eax,esi,ebx,edi,ecx,ebp,edx,esp|eax,esi,ebx,edi,ecx,ebp,edx|1、2、4、8|立即数

### 运行模式切换

- 通过 bits 指令来向编译器传达当前所需的模式:实/保护 模式
	- 用法：[bits 16/32]
	- 默认是在 16 位模式下
- 进入保护模式的步骤
	1. 打开 A20
	2. 加载 gdt
	3. 将 cr0 的 pe 位置 1

- 操作数字反转
	- 前缀 0x66
- 指令反转  
	- 前缀 0x67

压入的是 16 位数据，栈指针 -2,
压入的是 32 位数据，栈指针 -4,

## 全局描述符(GDT)

### 段描述符

### 全局描述符表 GDT , 局部描述符表 LDT 及选择子

<strong>段描述符格式</strong>

- 高 32 位

|段基址|G|D/B|L|AVL|段界限|P|DPL|S|TYPE|段基址|
|:----|----|----|----|----|----|----|----|----|----|:----:|
31~24|23|22|21|20|19~16|15|14~13|12|11~8|7~0|

- 低 32 位 

|段基址|段界限|
|----|----|
|15～0|15～0|

- 在 32 位保护模式下,寻址空间是 4G ,故在平坦模型中,段基地址是 0  选择粒度为 4K 的时候,段界限是 0xFFFFF

### 全局描述符

- 内存的起始地址
- 内存的长度
- 内存的属性

```cpp
typedef struct descriptor /* 共有8个字节*/
{
    /* 低 32 位 ==>基地址 0~15*/
    unsigned short limit_low;			//段界限 0~15 位
    unsigned int base_low:24;			//基地址 0~15 16~23 位
    /* 高 32 位*/ 
    unsigned char type:4;				//段类型:指定本描述符的类型
    unsigned char segement:1;			//1 表示数据段/0 表示系统段
    unsigned char DPL:2;				//Describe Privilege Level 描述符特权等级 0~3,进入保护模式:0,用户等级:3
    unsigned char present:1;			//段存在位 1:内存/ 0:磁盘  
    unsigned char limit_high:4;			//段界限 16~19
    unsigned char available :1;			//操作系统可用
    unsigned char long_mode:1;			//是否是 64 位代码段 1/0 : 64/32 位
    unsigned char big :1;				//1/0:32 位/16位	
    unsigned char granularity:1;		//粒度 4KB / 1B ==>对应段界限 4GB/1MB
    unsigned char base_high;			//基地址 24 ~ 31 位置
} __attribute__((packed)) descriptor
```

### type segement =1

type段常搭配S 段来对描述符类型定义

|X|C/E|R/W|A|
|----|----|----|----|

- X: 1/代码 0/数据 Executable
- X=1:代码段(可执行)

    - C:一致性代码段

    - R:是否可读

- X=0:数据段(不可执行)

    - E:拓展方向 (0/1:上/下  栈用于下 )

    - W:是否可写(1/0:可写/不可写)
    
- A: Accessed 是否被 CPU 访问

### 全局描述符表 GDT(Global Descriptor Table)

全局描述符表相当于是描述符的数组,数组中的每个元素都是 8 字节大小的描述符;

利用选择子所提供的下标在 GDT 中索引描述符

GDT 是16位,表示范围 : $2^{16}=65536$ 

描述符数量 : $65536/8=8192$ (每个描述符 8 字节)

- 第 0 个描述符不可用:选择子未初始化,会被置为 0,处理器发出异常

```s
lgdt[gdt_ptr];加载 gdt

sgdt[gdt_ptr];保存 gdt
```
lget:loader gdt
sget:


```cpp
typedef struct pointer{
    unsigned short limit; //size -1
    unsigned int base; 
}__attribute__((packed))pointer;
```

### 段选择子

通过选择子来确定段描述符,从而确定特权等级\界限和段的基地址

- 只需要一个代码段
- 需要一个或者多个数据段 / 栈段
- 加载到段寄存器中 / 校验特权级


```cpp
typedef struct selector{
    unsigned char RPL:2;        //请求特权级(0~3)
    unsigned char TI:1;         //Table indicator 1/0: 在LDT/GDT 中索引描述符
    unsigned char index : 13;   // gdt的下标 2^13=8192
}__attribute__((packed))selector;
```

### A20线

8086 1M

段地址 * 16 + 偏移地址 > 1M

80286 24 根地址线 16M
386 32 根地址线 4G

地址回绕:超过 1M 仍然会回去

操作 0x92 端口,将其第 1 位置 1

```s
in al,0x92
or al,0000_0010b
out 0x92,al

```

### cr0 的 PE(0)位打开 protect enable

```s
mov eax,cr0
or eax,1
mov cr0,eax
```
