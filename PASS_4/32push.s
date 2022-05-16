%include "boot.inc"

section push32_test vstart = 0x900
jmp loader_start

gdt_addr:

; 构建 gdt 及其内部的描述符

    GDT_BASE: dd  0x00000000
            dd      0x00000000
    CODE_DESC: dd  0x0000FFFF
            dd      DESC_CODE_HIGH4
    DATA_STACK_DESC: dd  0x0000FFFF
            dd      DESC_DATA_HIGH4
