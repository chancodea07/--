; 程序版本：3.0
; 编程逻辑：缓冲区、内存
; 实现的功能：n位+m位相同位数的10进制加法运算（n<=m且m,n<15）
; 修复了最高位进位的bug
; 另一个bug，n>m时计算失效，没有建立好的输入异常机制（Exception）

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
    ADD SI, 15
    ; 指向最后一位，便于倒序处理
    ; 这里倒序处理的目的是将没有存入数据的内存单元放在前面
    ; 例如默认存入为 09 02 03 04 00 00 00 00，则倒序后是 00 00 00 00 09 02 03 04，这样是为了处理高位进位时的情况
    CALL NUMBER_PROCESS
    LEA SI, ADD2
    ADD SI, 15
    CALL NUMBER_PROCESS
    CALL ADDING
    ; 进行数据处理，遍历每一位，对大于十的进行进位
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
        ; CX记录缓冲区实际数字的数量，为后续循环做准备
        LEA DI, ADD_BUFFER + 2
        ADD DI, CX
        DEC DI
    NUMBER_CONVERT:
        SUB BYTE PTR [DI], 30H
        MOV BL, [DI]
        ; BL寄存器起到中间变量的作用
        DEC DI
        ; DI自减1，整个循环过程类似于for循环（i--）
        MOV BYTE PTR [SI], BL
        DEC SI
    LOOP NUMBER_CONVERT
        RET
NUMBER_PROCESS ENDP
ADDING PROC NEAR
    LEA SI, ADD1
    ADD SI, 15
    LEA DI, ADD2
    ADD DI, 15
     ; 指向最后一位，便于倒序处理
    MOV CL, [ADD_BUFFER+1]
    MOV CH, 0
    MOV BX, 0
    ADDING_LOOP:
        MOV BYTE PTR BL,[SI]
        DEC SI
        ADD [DI], BL
        DEC DI
    LOOP ADDING_LOOP
    RET
ADDING ENDP
BIT_PROCESS PROC NEAR
    LEA DI, ADD2
    MOV CL, [ADD_BUFFER+1]
    MOV CH, 0
    ADD DI, 15
    BIT_LOOP:
        MOV BYTE PTR AL, [DI]
        CMP AL, 0AH
        JB LOOP_ENDING
        ;大于十的情况
        SUB AL, 0AH
        MOV BYTE PTR [DI], AL;位调整
        DEC DI
        ADD [DI],1;前一位加一
        JMP FORCE_END;因为上边已经减了一次做进位处理，这里是为了防止DI被多减1次
    LOOP_ENDING:
        DEC DI
    FORCE_END:
    LOOP BIT_LOOP
    RET
BIT_PROCESS ENDP
NUM_DISP PROC NEAR
    LEA DX, OUTPUTINFO
    MOV AH, 9H
    INT 21H
    LEA DI, ADD2
    MOV SI, 0;作为一个“标志性”寄存器存在，当碰到第一个非零数时更改状态
    MOV CX, 16
    NUM_DISP_LOOP:
        MOV BYTE PTR DL, [DI]
        CMP SI, 1
        JE GENERAL_PROCESS
        CMP	DL,	0
        JE  LOOP_END
        MOV SI, 1
    GENERAL_PROCESS:
        ADD DL, 30H
        MOV AH, 2H
        INT 21H
    LOOP_END:
        INC DI
    LOOP NUM_DISP_LOOP
    RET
NUM_DISP ENDP
CODES ENDS
END START
