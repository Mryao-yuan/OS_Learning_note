; 主引导程序

SECTION MBR vstart=0x7c00
	mov ax,cs
	mov ds,ax
	mov es,ax
	mov ss,ax
	mov fs,ax
	mov sp,0x7c00	; 栈地址为 0x7c00

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
	mov cx,0		; 左上角（0,0）
	mov dx,0x184f   ; 右上角（80,25）
					; VGA文本模式中，一行容纳80个字符，共25行
					; 0x18=24,0x4f=79
	int 0x10		; BIOS中断


; 获取光标位置
; 在光标位置处打印字符

	mov ah,3	; 输入 3 子功能是获取光标位置，需要存入 ah 寄存器
	mov bh,0    ; bh 寄存器是待获取的光标的页号

	int 0x10	; 输出： ch=光标开始行，cl=光标结束行
				; dh = 光标所在行号，dl= 光标所在列号

;	获取光标位置结束


; 打印字符串

; 还是用 10h 中断，不过这次调用 13 号子功能打印字符串
	mov ax,message
	mov bp,ax		; es：bp 为串首地址，es 此时同 cs 一致
					; 开头时已经为 sreg 初始化
	; 光标位置要用到 dx 寄存器中的内容， cx 中的光标位置可忽略 
	mov cx,16        ; cx表示串长度（1 MBR ）长度是 5，不包括结束符 0 的字符个数
	mov ax,0x1301	; 子功能号：13 是显示字符及属性，要存入 ah 寄存器
					; al 设置写字符方式 al=01 ： 显示字符串，光标随着移动
	mov bx,0x2		; bh 存储要显示的页号，此处是第 0 页
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