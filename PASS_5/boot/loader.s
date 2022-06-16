%include "src/boot.inc"
section loader vstart=LOADER_BASE_ADDR
LOADER_STACK_TOP equ LOADER_BASE_ADDR

jmp loader_start


;=============================================
; 构建 gdt 及其内部描述符
;=============================================
 GDT_BASE : dd 0x0000_0000b
			dd 0x0000_0000b

CODE_DESC : dd 0x0000_ffffb
			dd DESC_CODE_HIGH4
DATA_STACK_DESC : dd 0x0000_ffffb
				  dd DESC_DATA_HIGH4
VIDEO_DESC : dd 0x8000_0007
			 dd DESC_VIDEO_HIGH4

;=============================================
; gdt 的大小 和 限度
;=============================================
GDT_SIZE equ $ - GDT_BASE
GDT_LIMIT equ GDT_SIZE - 1

times 60 dq 0

;=============================================
; 选择子的设置
;=============================================
SELECTOR_CODE 	equ (0x0001 << 3 ) + TI_GDT +RPL0
SELECTOR_DATA 	equ (0x0002 << 3 ) + TI_GDT +RPL0
SELECTOR_VIDEO 	equ (0x0003 << 3 ) + TI_GDT +RPL0

;=============================================
; gdt 指针配置
;=============================================
gdt_ptr dw GDT_LIMIT
		dd GDT_BASE


loadermsg db '2 loader in real.'

loader_start:
	mov sp,LOADER_BASE_ADDR
	mov bp,loadermsg
	mov cx,17	; 写入的字符个数
	mov ax,0x1301
	mov bx,0x001f
	mov dx,0x1800
	int 0x10


;=============================================
; 准备进入保护模式
; 1. 打开 A20
; 2. 加载 gdt
; 3. 将 cr0 的 pe 位置1
;=============================================

in al ,0x92
or al,0000_0010b
out 0x92,al

lgdt [gdt_ptr]

mov eax,cr0
or  eax,0000_0001b
mov cr0,eax

jmp dword SELECTOR_CODE:p_mode_start ; 刷新流水线

[bits 32]
p_mode_start:
	mov ax,SELECTOR_DATA
	mov dx,ax
	mov es,ax
	mov ss,ax
	mov esp,LOADER_STACK_TOP
	mov ax,SELECTOR_VIDEO
	mov gs,ax

	mov byte [gs:160],'p'

jmp $
