; 主引导程序

%include "boot.inc"
;[org 0x7c00]
; 设置屏幕为文本模式，清楚屏幕

SECTION MBR vstart = 0x7c00  

    mov ax,cs
    ;mov ax,0
	mov ds,ax
	mov es,ax
	mov ss,ax
	mov fs,ax
	mov sp,0x7c00	; 栈地址为 0x7c00

    mov ax,3
    int 0x10
   
; 字符串赋值
    mov si ,booting
    call print

print:
    mov ah,0x0e  ; ah 为0xe al为字符 int 0x10 打印字符
.next:      ; 逐个打印字符
    mov al,[si]
    cmp al,0    ; 比较看是字符串否打印完成
    jz .done    ; 结束
    int 0x10    ; 调用中断
    inc si  ; si 自增，依次打印字符
    jmp .next
.done:    
    ret

; 打印字符结束

   mov eax,LOADER_START_SECTOR ; 起始扇区
   mov bx, LOADER_BASE_ADDR    ; 写入的地址
   mov cx,1                    ; 待写入扇区数
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
booting:
    db "Booting My OS...",10,13,0   ;\n\r 
error:
    mov si, .msg
    call print
    hlt     ; 让 CPU 停止
    jmp $
    .msg db "Booting error !!!",10,13,0

; 用0填充 当前行到section的地址之间没数据的地方用 0 填充 
times 510 - ($ -$$) db 0
; 为什么此次要 -8 从 502减去前面的填充（怀疑是include 了2个字节）
db 0x55,0xaa

; db 是一种伪操作命令，定义操作数占用的字节数