; -------Loader 和 kernel-------

LOADER_BASE_ADDR equ 0x900
LOADER_START_SECTOR equ 0x2

; ------- gdt 描述符属性 -------

DESC_BASE_ADDR_HIGH1 equ (0x00 << 24)	; 段基地址的第 24~ 31 位(高8位)
DESC_G_4K equ 1_00000000000000000000000b ; 粒度为4K 第 23 位
DESC_D_32 equ 1_0000000000000000000000b ; 32位操作数 第 22 位 
DESC_L    equ 0_000000000000000000000b   ; 32位 CPU 下编程 第 21 位 
; 64 位代码标记,此处为 0 便可
DESC_AVL  equ 0_00000000000000000000b ; CPU 不用此位，暂置为 0 第 20 位
; 代码/数据/显卡的段界限(高)
DESC_LIMIT_CODE2  equ 1111_0000000000000000b ; 代码段界限_后 第 16 位
DESC_LIMIT_DATA2  equ DESC_LIMIT_CODE2		; 数据段界限_后 第 16 ~ 19 位置
DESC_LIMIT_VIDEO2 equ 0000_000000000000000b	; 15

DESC_P equ 1_000000000000000b			; 段存在  第 15 位
; DPL 描述特权等级: 0~3 
DESC_DPL_0 equ 00_0000000000000b		; 13
DESC_DPL_1 equ 01_0000000000000b
DESC_DPL_2 equ 10_0000000000000b
DESC_DPL_3 equ 11_0000000000000b		; 13
; 段类型:系统段/数据段
DESC_S_CODE equ 1_000000000000b			; 12
DESC_S_DATA equ DESC_S_CODE			  ;	数据段	
DESC_S_sys equ 0_000000000000b		  ; 系统段 	
; 段的 type 属性	
DESC_TYPE_CODE equ 1000_00000000b     ; 可执行,非一致性,不可读,已访问位清 0

; x=1,c=0,r=0,a=0 代码段是可执行，非一致性，不可读，已访问位 a 清 0

DESC_TYPE_DATA equ 0010_00000000b

; x=0,e=0,w=1,a=0 数据段是不可执行，向上扩展，可写，访问位 a 清 0

; 代码段的高 4 字节
DESC_CODE_HIGH4 equ DESC_BASE_ADDR_HIGH1 + DESC_G_4K + DESC_D_32 + \
DESC_L + DESC_AVL + DESC_LIMIT_CODE2 + \
DESC_P + DESC_DPL_0 + DESC_S_CODE + \
DESC_TYPE_CODE + 0x00

; 数据段的高 4 字节
DESC_DATA_HIGH4 equ DESC_BASE_ADDR_HIGH1 + DESC_G_4K + DESC_D_32 + \
DESC_L + DESC_AVL + DESC_LIMIT_DATA2 + \
DESC_P + DESC_DPL_0 + DESC_S_DATA + \
DESC_TYPE_DATA + 0x00

; 显存段的高 4 字节
DESC_VIDEO_HIGH4 equ DESC_BASE_ADDR_HIGH1 + DESC_G_4K + DESC_D_32 + \
DESC_L + DESC_AVL + DESC_LIMIT_VIDEO2 + DESC_P + \
DESC_DPL_0 + DESC_S_DATA + DESC_TYPE_DATA  + 0x00


; ------- 选择子属性 -------
RPL0 equ 00b
RPL1 equ 01b
RPL2 equ 10b
RPL3 equ 11b
TI_GDT equ 000b
TI_LDT equ 100b


; 分页管理
PAGE_DIR_TABLE_POS equ 0x1
