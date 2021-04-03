DATA SEGMENT
    string_a DB 'HELLO WORLD!',13,10,'$'
DATA ENDS

EXT SEGMENT
    string_b DB 100 DUP(?)
EXT ENDS

STACKS SEGMENT

STACKS ENDS

CODES SEGMENT
    ASSUME CS:CODES, DS:DATA, SS:STACKS
START:
    MOV AX, DATA
    MOV DS, AX
    LEA DX, string_a
    MOV AH, 9H
    INT 21H
    MOV AX, EXT
    MOV ES, AX
    ; 记录字符串的长度，存放结果到SI中
    STRLEN:
    MOV BYTE PTR BL, DS:[SI]
    INC SI
    CMP BL, '$' ;这里不与00空字节比较，因为INC SI后内存单元已经指向空字节
    JNE STRLEN
    DEC SI      ; 此时SI指向字符串的结束符
    MOV CX, SI  ; 记录循环次数，也即实际字符串的长度
    COPYING:
        DEC SI  ; 这里是避免将原字符串末尾的结束符复制到新字符串的首位
        MOV BYTE PTR BL, DS:[SI]
        MOV BYTE PTR ES:[DI], BL
        INC DI
    LOOP COPYING
    MOV BL, '$'
    MOV BYTE PTR ES:[DI], BL;末位添加字符串的结束符号，便于正常输出
    DISP_STRING:;输出复制的字符串，9号中断输出的是DS:DX处的字符串，所以要将DS替换为ES
    MOV AX, ES
    MOV DS, AX
    LEA DX, string_b
    MOV AH, 9H
    INT 21H
    MOV AH, 4CH
    INT 21H
CODES ENDS
END START
