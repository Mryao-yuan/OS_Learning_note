[org 0x7c00]


	mov ah,0x0e
	int 0x10	; 中断




	mov si booting	; 字符串赋值
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






booting：
	db "my os is loading...",10,13,0	;要输出的字符串


; 填充 0
times 510-($-$$) db 0

; 标志是MBR
db 0xaa,0x55

