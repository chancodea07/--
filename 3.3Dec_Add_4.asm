; 程序版本：4.0
; 编程逻辑：缓冲区、内存操作
; 实现的功能：m位+n位相同位数的10进制加法运算（m，n不高于15位），并且有输入异常检查

DATA SEGMENT
    INFON DB 0AH, 0AH, 'Please input an integer number: $',0AH
          DB 12 DUP(?)
    ADD1 DB 16 DUP(?)
    ADD2 DB 16 DUP(?)
    ; 存放输入端十五位数字
    ADD_BUFFER DB 16
        DB ?
        DB 16 DUP(?)
    OUTPUTINFO DB 0AH,'The result is:$',0AH
    ; 缓冲区作为加数输入端
DATA ENDS

STACKS SEGMENT
    STACK DB 200 DUP(0)
STACKS ENDS

CODES SEGMENT
    ASSUME CS:CODES, DS:DATA, SS:STACKS
START:
    MOV AX, DATA
    MOV DS, AX
    LEA SI, ADD1
    ADD SI, 15
    ; 指向最后一位
    CALL NUMBER_PROCESS
    MOV DX, STACKS
    MOV SS, DX
    LEA DX, STACK
    MOV SP, 0
    PUSH AX
    MOV AX, 0
    LEA SI, ADD2
    ADD SI, 15

    CALL NUMBER_PROCESS
    PUSH AX
    MOV AX, 0
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
        MOV AX, 0
        MOV AX, CX;临时存储CX的值，便于后续比较
        LEA DI, ADD_BUFFER + 2
        ADD DI, CX
        DEC DI
    NUMBER_CONVERT:
        SUB BYTE PTR [DI], 30H
        MOV BL, [DI]
        DEC DI
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
    ;比较两次的数字长度，确定输出的数字范围
    ;Debug发现LEA指令执行后会改变SP的值，因而这里对SP进行修正
    ADD SP, 2
    MOV AX, 0
    MOV BX, 0
    POP AX
    POP BX
    CMP	AX,	BX
    JAE FIRST
    MOV CX, BX
    JMP GENERAL_
    FIRST:
        MOV CX, AX
        JMP GENERAL_
    ; MOV CL, [ADD_BUFFER+1]
    GENERAL_:
    MOV CH, 0
    MOV BX, 0
    ADDING_LOOP:
        MOV BYTE PTR BL,[SI]
        DEC SI
        ADD [DI], BL
        DEC DI
    LOOP ADDING_LOOP
    SUB SP, 2
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
        ;大于10的情况处理
        SUB AL, 0AH
        MOV BYTE PTR [DI], AL;位调整
        DEC DI
        ADD [DI],1;前一位加一
        JMP FORCE_END;防止DI被多减1次
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
