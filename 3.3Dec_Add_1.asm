; 接续以前的寄存器思路，没有使用缓冲区，目前只能够实现4位的加法
; 实现逻辑：输入数字，转化为10进制存储，随后二者相加，再对结果进行处理，然后进行输出

DATA SEGMENT
    STRING DB 13,10,"Please input an integer number(up to 4 bits):",'$'
    W DW 0
DATA ENDS
STACKS SEGMENT
    DW 200 DUP(0)
STACKS ENDS
CODES SEGMENT
    ASSUME CS:CODES, DS:DATA, SS:STACKS
START:
    CALL DEC_STORING
    CALL DEC_STORING;调用两次从而存入到不同的存储单元

    MOV AH, 4CH
    INT 21H

DEC_STORING PROC;子程序实现输入与转化,并将输入数字存入到两个对齐的内储存单元
    WELCOME: ;输入提示信息
        MOV AX, DATA
        MOV BX, 0
        MOV DS, AX
        LEA DX, STRING
        MOV AH, 9H
        INT 21H
    MAIN_INPUT:
        MOV DX,0
        MOV AH,1
        INT 21H                            ;系统等待输入一个字符，键入一个字符之后会自动转为ASCII值存入AL中
        MOV DL,AL                          ;向DL中写入AL,DL作为每次存储时新的一位Hex
        CMP AL,0DH                         ;如果输入字符为回车则跳到标识符Init处执行，进行数字二次存入内存中
        JE Init
        CMP AL,39H
        JBE NUMBER                         ;如果=<9则跳到标识符NUMBER处执行
        JMP MAIN_INPUT                     ;（>9)继续输入字符
    STORING_:
        MOV CL, 4                          ;向CL中写入4，作为二进制下的逻辑右移位数，实现了BX十六进制角度上整体左移一位，起到了取高位的作用
        SHL BX, CL                         ;逻辑左移指令，实现了BX十六进制角度上整体左移一位
        ADD BX, DX                         ;BX更新存储的十六进制数
        JMP MAIN_INPUT
    NUMBER:                                ;字符0-9
        CMP AL, 30H                        ;判断是否>=0，匹配成功则进一步执行，否则必然是除回车外的其他字符，进行返回字符重新输入
        JAE NUM_PROCING
        JMP MAIN_INPUT
    NUM_PROCING:
        SUB DL, 30H
        JMP STORING_
    Init:
        ; 寄存器初始化，便于后续处理，AX作为原始数据寄存器，BX,CX和DX全部置零
        MOV AX, BX
        MOV BX, 0
        MOV CX, 0
        MOV DX, 0
        CALL FINAL
        RET
    FINAL PROC
            MOV BX, AX
            MOV CL, 4
            ;处理低位
            MOV DL, 0FH;取定位
            AND BX, DX
            PUSH BX
            SHL DL, CL
            MOV BX, AX
            AND BX, DX
            SHR BL, CL
            PUSH BX
            ;处理高位
            MOV BX, 0
            MOV BL, AH
            MOV DL, 0FH;取定位
            AND BX, DX
            PUSH BX
            SHL DL, CL
            MOV BL, AH
            AND BX, DX
            SHR BL, CL
            PUSH BX
            MOV CX, 4;最高控制在4位
            CMP SI, 0
            JNE FA
        UPDATE_DATA:
            POP DX
            MOV BYTE PTR[W+SI], DL
            INC SI
        LOOP UPDATE_DATA
            JMP EXIT
        FA:
            MOV SI, 0
        UPDATE_DATA2:
            POP DX
            MOV BYTE PTR[W+10H+SI], DL
            INC SI
        LOOP UPDATE_DATA2
        EXIT:
            RET
    FINAL ENDP
DEC_STORING ENDP


CODES ENDS
END START
