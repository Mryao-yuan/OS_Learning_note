%include "src/boot.inc"
section loader vstart=LOADER_BASE_ADDR
; 栈顶为 0x900
LOADER_STACK_TOP equ LOADER_BASE_ADDR
jmp loader_start

;##############################################
; 构建 gdt 及其内部的描述符
; 第 1 ~ 3 个描述符分别为:代码段描述符,栈段描述符,显存描述符
;############################################# 
	; 第 0 个描述符不可用
	GDT_BASE :  dd 0x00000000	; 低 4 字节
				dd 0x00000000		; 高 4 字节
	CODE_DESC : dd 0x0000FFFF
				dd DESC_CODE_HIGH4
	DATA_STACK_DESC : dd 0x0000FFFF
					  dd DESC_DATA_HIGH4
; db 一个字节数据，占用 1字节
; dw 一字类型 ，占用 2 字节
; dd 双字类型，占用 4 字节
	VIDEO_DESC : dd 0x80000007 ; limit = (0xbffff-0xb8000)/4k = 0x7
             	 dd DESC_VIDEO_HIGH4 ; 此时 dpl 为 0
	; 全局描述符的大小 = 当前大小 - 基地址
	GDT_SIZE equ $ - GDT_BASE
	; 全局描述符的界限 = 全局描述符的大小 - 1(从 0 开始)
	GDT_LIMIT equ GDT_SIZE - 1

	times 60 dq 0		; 此处预留 60 个描述符空位

;##############################################
; 选择子的配置
; 描述符索引值(13)+TI(1)+RPL(2)
;############################################# 
	; 索引值左移 12 位
	SELECTOR_CODE equ (0x0001 << 3) + TI_GDT +RPL0
	SELECTOR_DATA equ (0x0002 << 3) + TI_GDT +RPL0
	SELECTOR_VIDEO equ (0x0003 << 3) + TI_GDT +RPL0

	; 以下是 gdt 指针，前 2 个字节是 gdt 界限，后 4 字节是 gdt 起始地址
	gdt_ptr dw GDT_LIMIT
			dd GDT_BASE

; 输出字符
loadermsg db '2 loader in real.'

	; 开始加载

loader_start:
;##############################################
;INT 0x10 功能号：0x13 功能描述：打印字符串
;############################################# 
; 输入：
; AH 子功能号 = 13H
; BH = 页码
; BL = 属性（AL=00H/01H）
; CX = 字符串长度
;（DH,DL）= 坐标（行，列）
; ES：BP = 字符串地址
; AL = 显示方式
; 0 ：字符串中只显示字符，其显示属性在 BL 中 且显示后，光标位置不变
; 1 ：字符串中只显示字符，其显示属性在 BL 中 且显示后，光标位置改变
; 2 ：字符串中只显示字符和显示属性，显示后，光标位置不变
; 3 ：字符串中只显示字符和显示属性，显示后，光标位置改变
; 无返回值
	mov sp,LOADER_BASE_ADDR
	mov bp,loadermsg
	mov cx,17		; 输出 17 个字符
	mov ax,0x1301	; ah=13,al=01
	mov bx,0x001f	; bh=0,bl=1f (蓝底粉红色)
	mov dx,0x1800	; dh=18
	int 0x10

;********************* 准备进入保护模式 **************************************
; 1. 打开 A20
; 2. 加载 gdt
; 2. 将 cr0 的 pe 位置 1

;************** 打开A20 **************** 

	in al,0x92
	or al,0000_0010B
	out 0x92,al 

;************** 加载 GDT **************** 
	lgdt [gdt_ptr]

;************** CR0 第 0 位置 1 **************** 
	mov eax,cr0
	or eax,0x00000001
	mov cr0,eax
	
	jmp dword SELECTOR_CODE:p_mode_start  ; 刷新流水线(防止 16 位 和 32 位指令造成的混乱)

; 32 位操作
[bits 32]
p_mode_start:
	mov ax,SELECTOR_DATA
	mov ds,ax
	mov es,ax
	mov ss,ax
	mov esp,LOADER_STACK_TOP
	mov ax,SELECTOR_VIDEO
	mov gs,ax

	mov byte [gs:160],'p'

	jmp $

;##############################################
; 创建页目录及页表
;##############################################

setup_page:
; 先把页目录占用的空间逐字节清 0
	mov ecx,4096
	mov esi,0

.clear_page_dir:
	mov byte [PAGE_DIR_TABLE_POS + esi],0
	inc esi
	loop .clear_page_dir

; 开始创建页目录项(PDE)
.crate_pde: ; 创建 Page Direcory Entry
	mov eax,PAGE_DIR_TABLE_POS
	add eax,0x1000	; 此时 eax 为第一个页表的位置及其属性
	mov ebx,eax   	; 此处为 ebx 赋值,是为 .create_pte 做准备, ebx 为基地址

; 下面
;
;