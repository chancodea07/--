DATA SEGMENT
    string_a DB 'The school of Information Science and Engineering Shandong University','$'
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
    MOV AX, EXT
    MOV ES, AX
    COPYING:;按字节遍历内存单元，实现字符串的正序复制
    MOV BYTE PTR BL, DS:[SI]
    CMP BL, 0
    JE DISP_STRING
    MOV BYTE PTR ES:[DI], BL
    INC SI
    INC DI
    JMP COPYING
    DISP_STRING:;正序输出复制的字符串，9号中断输出的是DS:DX处的字符串，所以要将DS替换为ES
    MOV AX, ES
    MOV DS, AX
    LEA DX, string_b
    MOV AH, 9H
    INT 21H
    MOV AH, 4CH
    INT 21H
CODES ENDS
END START
