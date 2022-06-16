%include "boot.inc"
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

; 打印字符结束

   mov eax,LOADER_START_SECTOR ; 起始扇区
   mov bx, LOADER_BASE_ADDR    ; 写入的地址
   mov cx,4                    ; 待写入扇区数
   call rd_disk_m_16           ; 以下读取程序的起始部分(一个扇区)
   ; 比较跳转的硬盘位置的结束标志
   jmp LOADER_BASE_ADDR        ; 跳转到 0x900 （loader 运行）


; function：读取硬盘 n 个扇区
rd_disk_m_16:
                    ; eax =LBA 扇区号
                    ; bx = 将数据写入的内存地址
                    ; cx = 读入的扇区数
    mov esi,eax ; 备份 eax
    mov di,cx   ; 备份 cx
; 读写硬盘：
; step 1：设置要读取的扇区数
    mov dx,0x1f2
    mov al,cl
    out dx,al   ; 读取的扇区数

    mov eax,esi ; 恢复 ax

; step 2：将 LBA 地址存入 0x1f3 ～ 0x1f6
    ; LBA地址 7～0 位写入端口0x1f3
    inc dx ; 加1 0x1f3
    out dx,al

  ; LBA地址 15～8 位写入端口0x1f4
    mov cl,8
    shr eax,cl
    inc dx ;0x1f4
    out dx,al

  ; LBA地址 23～16 位写入端口0x1f5
    shr eax,cl
    inc dx ;0x1f5
    out dx,al

    shr eax,cl
    and al,0x0f     ; LBA 第24～27 位
    or al,0xe0      ; 设置7～4 位为 1110,表示 LBA 模式
    mov dx,0x1f6
    out dx,al

; step 3：向0x1f7端口写入读命令，0x20
    mov dx,0x1f7
    mov al,0x20
    out dx,al

; step 4：监测硬盘状态
.not_ready:
    ; 同一个端口，写时表示写入命令字，读时表示读入硬盘状态
    nop ; 等待
    in al,dx
    and al,0x88 ; 第 3 位为 1 表示硬盘控制器已经准备好数据传输
                ; 第 7 位为 1 表示硬盘忙碌
    cmp al,0x08
    jnz .not_ready  ; 未准备好则继续等待

; step 5：从 0x1f0 端口读取数据
    mov ax,di
    mov dx,256
    mul dx
    mov cx,ax

; di 为要读取的扇区数量，一个扇区有 512 个字节，每次读入一个字，一共需要 di * 512 /2 次 ，所以是 di * 256

    mov dx,0x1f0
.go_on_read:
    in ax,dx
    mov [bx],ax
    add bx,2
    loop .go_on_read
    ret


; 用0填充 当前行到section的地址之间没数据的地方用 0 填充 
times 510 - ($ -$$) db 0
; 为什么此次要 -8 从 502减去前面的填充（怀疑是include 了2个字节）
db 0x55,0xaa

; db 是一种伪操作命令，定义操作数占用的字节数