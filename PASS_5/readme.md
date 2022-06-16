# 深入保护模式

## 内存检测

在 LINUX 中获取内存容量是通过 BIOS 的 0x15 的中断来实现的主要有三个子功能(写入EX 寄存器中实现)

1. EAX = 0xE820 : 遍历主机上的全部内存
2. AX = 0xE801 :分别检测地 15MB 和 16MB ~ 4GB的内存
3. AH = 0x88 :最多检测 64 MB的内存(实际内存超过也返回 64MB)

---

### 0xE820 获取内存

通过该 BIOS 中断的子功能调用返回内存信息保存在 ARDS(Address Range Descriptor Structure)地址范围描述符中

- ARDS(共有 5 个字段,20个字节)
    |字节偏移量|属性名称|描述|
    |---|---|---|
    |0|BaseAddrLow|基地址的低 32 位|
    |4|BaseAddrHigh|基地址的高 32 位|
    |8|LengthLow|内存长度的低 32 位,字节为单位|
    |12|LengthHigh|内存长度的高 32 位,字节为单位|
    |16|Type| 本段内存的类型|

---

- Type 字段
    |Type 值|名称|描述|
    |---|---|---|
    |1|AddressRangeMemory|这段内存$可以被操作系统使用$|
    |2|AdressRangeReserved|内存使用中 / 保留 ,$操作系统不可使用$ |

---

- 调用说明 
    |调用前输入 / 返回输出|寄存器/状态位|参数用途|
    |---|---|---|
    |调用前|EAX|存储子功能号 :0xE820|
    | 调用前|EBX|ARDS 后续值,每执行一次调用返回一种类型内存的 ARDS 结构,故用此记录下一个待返回内存的 ARDS|
    |调用前|ES:DI|ARDS 缓冲区:BIOS将获取到的内存信息写入次寄存器指向的内存,每次都以 ARDS 格式返回|
    |调用前|ECX|ARDS 结构的字节大小:用来指示 BIOS 写入的字节数|
    |调用前|EDX| 固定为签名标记 0x534d4150 该十六进制数字是字符串 SMAP 的ASCII 码: BIOS 将调用者正在请求的内存信息写入 ES:DI 寄存器所指向的 ARDS 缓冲区后,再用此前面校验信息|
    |返回输出|CF 位|0/1:正确执行 / 出错 |
    |返回输出|EAX|字符串 SMAP 的 ASCII 码 0x534d4150|
    |返回输出|ES:DI|ARDS 缓冲区,同输入值一样,返回时被 BIOS 写入了内存信息|
    |返回输出|ECX| BIOS 写入到 ES:DI 所指向的 ARDS 结构中的字节数, BIOS 最小写入 20 个字节|
    |返回输出|EBX|后续值:下一个 ARDS 的位置,每次中断过后,BIOS 都会更新此数值,BIOS 可以通过此数值来找到下一个待返回的 ARDS 结构. 在 CF 位 =0 的时候,EBX = 0 说明是最后一个 ARDS 结构|

---

中断调用步骤

1. 将调用前的寄存器填写数值
2. BIOS 中断调用 0x15 
3. 判断 CF 位 的值 = 0,读出寄存器的值

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