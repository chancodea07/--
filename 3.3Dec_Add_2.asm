; 程序版本：2.0（1.0没有编完，只实现了数据存入，并且是寄存器循环输入的方式，思路麻烦，遂放弃）
; 编程逻辑：缓冲区、内存
; 已知的bug：最高位进位会发生溢出
; 实现的功能：n位+n位相同位数的加法运算

DATA SEGMENT
    INFON DB 0AH, 0AH, 'Please input an integer number: $',0AH
          DB 12 DUP(?)
    ADD1 DB 16 DUP(?)
    ADD2 DB 16 DUP(?)
    ; 存放输入端十五位数字，同时ADD2存放后续求和的数字
    ADD_BUFFER DB 16
        DB ?
        DB 16 DUP(?)
    OUTPUTINFO DB 0AH,'The result is:$',0AH
    ; 缓冲区作为加数输入端
DATA ENDS

STACKS SEGMENT
    DB 200 DUP(0)
STACKS ENDS

CODES SEGMENT
    ASSUME CS:CODES, DS:DATA, SS:STACKS
START:
    MOV AX, DATA
    MOV DS, AX
    LEA SI, ADD1
    CALL NUMBER_PROCESS
    LEA SI, ADD2
    CALL NUMBER_PROCESS
    CALL ADDING
    ;进行数据处理，遍历每一位对大于十的进行进位
    CALL BIT_PROCESS
    CALL NUM_DISP
    MOV AH, 4CH
    INT 21H
NUMBER_PROCESS PROC NEAR
        LEA DX, INFON
        MOV AH, 9H
        INT 21H
        LEA DX, ADD_BUFFER
        MOV AH, 0AH
        INT 21H
        MOV CL, [ADD_BUFFER + 1]
        MOV CH, 0
        LEA DI, ADD_BUFFER + 2
    NUMBER_CONVERT:
        SUB BYTE PTR [DI], 30H
        MOV BL, [DI]
        INC DI
        MOV BYTE PTR [SI], BL
        INC SI
    LOOP NUMBER_CONVERT
        RET
NUMBER_PROCESS ENDP
ADDING PROC NEAR
    LEA SI, ADD1
    LEA DI, ADD2
    MOV CL, [ADD_BUFFER+1]
    MOV CH, 0
    MOV BX, 0
    ADDING_LOOP:
        MOV BYTE PTR BL,[SI]
        INC SI
        ADD [DI], BL
        INC DI
    LOOP ADDING_LOOP
    RET
ADDING ENDP
BIT_PROCESS PROC NEAR
    LEA DI, ADD2
    MOV CL, [ADD_BUFFER+1]
    MOV CH, 0
    MOV SI, CX;倒向循环遍历
    BIT_LOOP:
        MOV SI, CX
        MOV BYTE PTR AL, [ADD2+SI]
        CMP AL, 0AH
        JB LOOP_ENDING
        ;BIGGER THAN 10
        SUB AL, 0AH
        MOV BYTE PTR [ADD2+SI], AL;位调整
        DEC SI
        INC [ADD2+SI];前一位加一
    LOOP_ENDING:
    LOOP BIT_LOOP
    RET
BIT_PROCESS ENDP
NUM_DISP PROC NEAR
    LEA DX, OUTPUTINFO
    MOV AH, 9H
    INT 21H
    LEA DI, ADD2
    MOV CL, [ADD_BUFFER+1]
    MOV CH, 0
    MOV SI, 0
    NUM_DISP_LOOP:
        MOV BYTE PTR AL, [ADD2+SI]
        INC SI
        ADD AL, 30H
        MOV DL, AL
        MOV AH, 2H
        INT 21H
    LOOP NUM_DISP_LOOP
    RET
NUM_DISP ENDP
CODES ENDS
END START
