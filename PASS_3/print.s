; 直接操作显卡
SECTION MBR vstart=0x7c00
	mov ax,cs
	mov ds,ax
	mov es,ax
	mov ss,ax
	mov fs,ax
	mov sp,0x7c00	; 栈地址为 0x7c00
    mov ax,0xb800   ; 文本显示模式
    mov gs,ax

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

    ; 输出背景色绿色，前景色红色，跳动显示：MY OS is Loading
    ; byte 用于指定操作数所占空间为2字节
    mov byte  [gs:0x00],'B'
    mov byte  [gs:0x01],0xA4    ;A:0x1010(绿色背景闪烁)，4：0x0100（前景色为红色）

    mov byte  [gs:0x02],'o'
    mov byte  [gs:0x03],0xA0    ;A:0x1010(绿色背景闪烁)，0：0x0000（前景色为黑色）

    mov byte  [gs:0x04],'o'
    mov byte  [gs:0x05],0xA4

    mov byte  [gs:0x06],'t'
    mov byte  [gs:0x07],0xA7 ;A:0x1010(绿色背景闪烁)，0：0x0000（前景色为白色）

    mov byte  [gs:0x08],' '
    mov byte  [gs:0x09],0xA4 

    mov byte  [gs:0x0A],'L'
    mov byte  [gs:0x0B],0xA1 ;A:0x1010(绿色背景闪烁)，1：0x0001（前景色为蓝色）

    mov byte  [gs:0x0C],'o'
    mov byte  [gs:0x0D],0xA4
    
    mov byte  [gs:0x0E],'a'
    mov byte  [gs:0x0F],0xA4

    mov byte  [gs:0x10],'d'
    mov byte  [gs:0x11],0xA4

    mov byte  [gs:0x12],'i'
    mov byte  [gs:0x13],0xA4
    
    mov byte  [gs:0x14],'n'
    mov byte  [gs:0x15],0xA4

    mov byte  [gs:0x16],'g'
    mov byte  [gs:0x17],0xA4

    mov byte  [gs:0x18],'!'
    mov byte  [gs:0x19],0xA4

    mov byte  [gs:0x1A],'!'
    mov byte  [gs:0x1B],0xA4
        
    mov byte  [gs:0x1C],'!'
    mov byte  [gs:0x1D],0xA4

 ; 换行 回车 \n \r
    mov byte  [gs:0x1E],10
    mov byte  [gs:0x1F],0xA4 
    mov byte  [gs:0x20],13
    mov byte  [gs:0x21],0xA4


; 用0填充 当前行到section的地址之间没数据的地方用 0 填充 
times 510 -($ -$$) db 0

db 0x55,0xaa

; db 是一种伪操作命令，定义操作数占用的字节数