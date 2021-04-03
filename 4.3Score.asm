; Input Score支持输入一个成绩，回车后再次输入
DATA SEGMENT
    info DB 13,10,'Input Score:','$'
    Score_Buffer DB 16
                DB ?
                DB 16 DUP(?)
    Score6 DB 16 DUP(?)
    Score7 DB 16 DUP(?)
    Score8 DB 16 DUP(?)
    Score9 DB 16 DUP(?)
    Score10 DB 16 DUP(?)
    INFO6 DB 13,10,'60~69:',13,10,'$'
    INFO7 DB 13,10,'70~79:',13,10,'$'
    INFO8 DB 13,10,'80~89:',13,10,'$'
    INFO9 DB 13,10,'90~99:',13,10,'$'
    INFO10 DB 13,10,'100:',13,10,'$'
DATA ENDS

STACKS SEGMENT

STACKS ENDS

CODES SEGMENT
    ASSUME CS:CODES, DS:DATA, SS:STACKS
START:
    MOV AX, DATA
    MOV DS, AX
    MOV CX, 10;输10次成绩
    INIT:
    ; 初始化
        MOV BX,30H
        MOV BYTE PTR [Score10], BL
        MOV BYTE PTR [Score9], BL
        MOV BYTE PTR [Score8], BL
        MOV BYTE PTR [Score7], BL
        MOV BYTE PTR [Score6], BL
    SCORE_:
        CALL SCORE
    LOOP SCORE_
    CALL INFO_DISP
    MOV AH, 4CH
    INT 21H
    SCORE PROC NEAR
    INPUT_SCORE:
        LEA DX, info
        MOV AH, 9H
        INT 21H
        LEA DX, Score_Buffer
        MOV AH, 0AH
        INT 21H
    STORING:
        MOV AH, [Score_Buffer+1]
        MOV AL, [Score_Buffer+2]
        CMP AH, 3H
        JE FLAG100
    GENERAL_:
        CMP AL, 39H
        JE FLAG90
        CMP AL, 38H
        JE FLAG80
        CMP AL, 37H
        JE FLAG70
        CMP AL, 36H
        JE FLAG60
        RET
    FLAG100:;统计100分人数
        ADD BYTE PTR [Score10], 1H
        RET
    FLAG90:;统计90分人数
        ADD BYTE PTR [Score9], 1H
        RET
    FLAG80:;统计人数
        ADD BYTE PTR [Score8], 1H
        RET
    FLAG70:;统计人数
        ADD BYTE PTR [Score7], 1H
        RET
    FLAG60:;统计人数
        ADD BYTE PTR [Score6], 1H
        RET
SCORE ENDP
INFO_DISP PROC NEAR
    LEA DX, INFO6
    MOV AH, 9H
    INT 21H
    MOV DX, 0
    MOV BYTE PTR DL, [Score6]
    MOV AH, 2H
    INT 21H
    LEA DX, INFO7
    MOV AH, 9H
    INT 21H
    MOV DX, 0
    MOV BYTE PTR DL, [Score7]
    MOV AH, 2H
    INT 21H
    LEA DX, INFO8
    MOV AH, 9H
    INT 21H
    MOV DX, 0
    MOV BYTE PTR DL, [Score8]
    MOV AH, 2H
    INT 21H
    LEA DX, INFO9
    MOV AH, 9H
    INT 21H
    MOV DX, 0
    MOV BYTE PTR DL, [Score9]
    MOV AH, 2H
    INT 21H
    LEA DX, INFO10
    MOV AH, 9H
    INT 21H
    MOV DX, 0
    MOV BYTE PTR DL, [Score10]
    MOV AH, 2H
    INT 21H
    RET
INFO_DISP ENDP
CODES ENDS
END START
