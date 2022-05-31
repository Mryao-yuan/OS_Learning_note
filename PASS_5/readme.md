# 深入保护模式

## 内存检测

BIOS 利用 0x15 中断可以来获取内存


### ADRS(Address Range Descriptot Structure)

| 字节偏移量 | 属性名称 | 描述 |
| 
||

### Type 字段

|Type 值|名称|描述|
|----|----|-----------|
| 1 | AddressRangememory | 这段内存可以被操作系统使用 |
| 2 | AddressRangeReserved | 内存使用中或者被系统保留,操作系统不可以用此内存|
| 其他 | 未定义 | 保留 |



## 内存分页

## 加载内核

- 查看是否可重定位
    >file main.o 

- 查看符号地址
    > nm main.o
- 链接程序
    > ld main.o -Ttext 0xc0001500 -e main -o kernel.bin 
    - -Ttext : 指定其实虚拟地址为 0xc0001500
    - -o : 输出文件名称
    - -e : 同 --entry 指定程序起始地址(可以是符号名称)
链接器默认把名为 _start 的函数作为程序的入口地址(也可以用 -e 指定为 main)

### ELF 文件格式

Executable and Linking Format :可执行和链接格式

|ELF目标文件类型|Description|
|----|----|
|待重定位文件(Relocatable file)|常说的目标文件,源文件编译后但为完成链接的文件,用于与其他目标文件合并链接|
|共享目标文件(Shared object file)|动态链接库|
|可执行文件(Executable file|经过编译链接后,可以直接运行的程序文件|


#### 可执行程序

1. 代码 .text 段 section ELF / segment CPU
2. 数据
    -  `.data section`
    - `.bss` 未初始化过的数据 `Block Strated by Symbol`


## 