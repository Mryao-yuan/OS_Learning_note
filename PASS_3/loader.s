%include "boot.inc"
section loader vstart=LOADER_BASE_ADDR



; dw 0x55aa ;魔数：用于判断错误
; 打印字符串
mov si,Loading
call print

; 阻塞
jmp $
print:
    mov ah,0x0e
.next:
    mov al,[si]
    cmp al,0
    jz  .done
    int 0x10
    inc si
    jmp .next   ; 循环
.done:
    ret


Loading:
db "Loading My OS...",10,13,0 ;\n\r


















;   mov byte  [gs:0x00],'L'
;   mov byte  [gs:0x01],0xA4    ;A:0x1010(绿色背景闪烁)，4：0x0100（前景色为红色）
;
;   mov byte  [gs:0x02],'o'
;   mov byte  [gs:0x03],0xA0    ;A:0x1010(绿色背景闪烁)，0：0x0000（前景色为黑色）
;
;   mov byte  [gs:0x04],'a'
;   mov byte  [gs:0x05],0xA4
;
;   mov byte  [gs:0x06],'d'
;   mov byte  [gs:0x07],0xA7 ;A:0x1010(绿色背景闪烁)，0：0x0000（前景色为白色）
;
;   mov byte  [gs:0x08],'i'
;   mov byte  [gs:0x09],0xA1 ;A:0x1010(绿色背景闪烁)，1：0x0001（前景色为蓝色）
;
;   mov byte  [gs:0x0A],'n'
;   mov byte  [gs:0x0B],0xA4
;
;   mov byte  [gs:0x0C],'g'
;   mov byte  [gs:0x0D],0xA4
;   
;   mov byte  [gs:0x0E],'!'
;   mov byte  [gs:0x0F],0xA4
;
;   mov byte  [gs:0x10],'!'
;   mov byte  [gs:0x11],0xA4
;
;   mov byte  [gs:0x12],'!'
;   mov byte  [gs:0x13],0xA4

; 阻塞
jmp $