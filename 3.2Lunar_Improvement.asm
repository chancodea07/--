; 修改部分：
; 1. 字符转数字的代码流程，仅用循环进行替代，简化了程序的思路
; 只需要遍历所有的内存单元，依次减去30H即可
data segment
      infon db 0dh,0ah,'please input a year: $'
      Y db 0dh,0ah,'This is a leap year! $'
      N db 0dh,0ah,'This is not a leap year! $'
      w dw 0
      buf db 8
          db ?
          db 8 dup(?)
data ends
stack segment stack
     db 200 dup(0)
stack ends
code segment
    assume ds:data,ss:stack,cs:code
start:mov ax,data
      mov ds,ax
      lea dx,infon
      mov ah,9
      int 21h
      lea dx,buf
      mov ah,10
      int 21h
      mov cl,[buf+1]
      mov ch,0
      lea di,buf+2
      call datacate
      call ifyears
      jc a1
      lea dx,n
      mov ah,9
      int 21h
      jmp exit
a1:        lea dx,y
            mov ah,9
            int 21h
            jmp exit
exit:      mov ah,4ch
            int 21h
datacate proc near
     NUMBER_CONVERT:
        SUB BYTE PTR [DI], 30H
        MOV BL, [DI]
        INC DI
        MOV BYTE PTR [SI], BL
        INC SI
    LOOP NUMBER_CONVERT
        RET
datacate endp
ifyears proc near
     push bx
     push cx
     push dx
     mov ax,[w]
     mov cx,ax
     mov dx,0
     mov bx,100
     div bx
     cmp dx,0
     jnz lab1
     mov ax,cx
     mov bx,400
     div bx
     cmp dx,0
     jz lab2
     clc
     jmp lab3
     lab1:mov ax,cx
          mov dx,0
          mov bx,4
          div bx
          cmp dx,0
          jz lab2
          clc
          jmp lab3
     lab2:stc
     lab3:pop dx
          pop cx
          pop bx
          ret
ifyears endp
code ends
   end start

