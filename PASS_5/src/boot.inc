; ========== loader and Kernel ====================

LOADER_BASE_ADDR equ 0x900
LOADER_START_SECTOR equ 0x2

; ========== gdt 描述符属性 ====================
DESC_BASE_ADDR_HIGH equ (0x00 << 24)
; 粒度是 4K
DESC_G_4K  equ  1_00000000000000000000000b
; 操作数是 32 位
DESC_D_32  equ  1_0000000000000000000000b
; 32 位 CPU 下编程
DESC_L 	   equ  0_000000000000000000000b 
; 操作系统可以用
DESC_AVL   equ  0_00000000000000000000b
; ============== 段界限========================
DESC_LIMIT_CODE_HIGH  equ 1111_0000000000000000b
DESC_LIMIT_DATA_HIGH  equ DESC_LIMIT_CODE_HIGH
DESC_LIMIT_VIDEO_HIGH equ 0000_0000000000000000b
; ============== 段存在========================
DESC_P equ 1_000000000000000b 
; ============== 描述符优先等级========================
DESC_DPL_0 equ 00_0000000000000b 
DESC_DPL_1 equ 01_0000000000000b 
DESC_DPL_2 equ 10_0000000000000b 
DESC_DPL_3 equ 11_0000000000000b 
; ============== 段类别========================
; 代码\数据\系统
; =========================== ========================
DESC_S_CODE equ 1_000000000000b 
DESC_S_DATA equ DESC_S_CODE 
DESC_S_sys equ 0_000000000000b 
; ========== 段类型 ====================
DESC_TYPE_CODE equ 1000_00000000b  ; 可执行
DESC_TYPE_DATA equ 0010_00000000b  ; 可写
; ========== 高 32 位段描述符整合 ====================
; 代码\数据
; =========================== ========================
DESC_CODE_HIGH4 equ DESC_BASE_ADDR_HIGH + DESC_G_4K + DESC_D_32 + \
DESC_L + DESC_AVL + DESC_LIMIT_CODE_HIGH + DESC_P + \
DESC_DPL_0 + DESC_S_CODE + DESC_TYPE_CODE + 0x00

DESC_DATA_HIGH4 equ DESC_BASE_ADDR_HIGH + DESC_G_4K + DESC_D_32 + \
DESC_L + DESC_AVL + DESC_LIMIT_DATA_HIGH + DESC_P + \
DESC_DPL_0 + DESC_S_DATA + DESC_TYPE_DATA + 0x00

DESC_VIDEO_HIGH4 equ DESC_BASE_ADDR_HIGH + DESC_G_4K + DESC_D_32 + \
DESC_L + DESC_AVL + DESC_LIMIT_DATA_HIGH + DESC_P + \
DESC_DPL_0 + DESC_S_DATA + DESC_TYPE_DATA + 0x00

; ========== 选择子属性 ====================
RPL0 equ 00b
RPL1 equ 01b
RPL2 equ 10b
RPL3 equ 11b
TI_GDT equ 000b
TI_LGT equ 100b
