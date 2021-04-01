; 程序实现的相关功能：
; 数字输入输出样例：99
; 字母情况的输入输出样例：A c
; 其他情况的输入输出样例：￥ <无字符>

DATA SEGMENT
MESG DB 'This is the end of the program.','$'
DATA ENDS
STACK SEGMENT

STACK ENDS
CODES SEGMENT
    ASSUME CS:CODES, DS:DATA, SS:STACK
START:
MAIN:
    MOV  DL, 0AH
    MOV  AH, 2H
    INT  21H                            ;输出换行，在这里换行是为了便于观察输出情况和程序的执行情况
    MOV  AH,1
    INT  21H                            ;系统等待输入一个字符，键入一个字符之后会自动转为ASCII值存入AL中
    CMP  AL,0DH                         ;如果输入字符为回车则跳到标识符DIRCET_END处执行
    JE   DIRCET_END
    CMP  AL,39H
    JBE  NUMBER                         ;如果=<9则跳到标识符NUMBER处执行
    CMP  AL,41H                         ;（>9成立）如果>=A则跳到WORD_处执行
    JAE  WORD_                          ;如上解析
    JMP  MAIN                           ;（<A成立）继续输入字符
NUMBER:                                 ;字符1-9
    CMP AL, 31H                         ;判断是否>=1，匹配成功则进一步执行，否则必然是除回车外的其他字符，进行返回字符重新输入
    JAE NUM_DISP
    JMP MAIN
NUM_DISP:                               ;原样输出字符
    MOV DL, AL
    MOV AH, 2H
    INT 21H
    JMP MAIN
WORD_:                                  ;字符为英文单字A-Z或a-z
    CMP	AL,	5AH                         ;大于A的情况下与Z进行比较
    JBE WORD_DISP                       ;小于Z的情况：直接进入输出
    CMP	AL,	61H                         ;(通过比较，大于Z的情况下)与a进行比较
    JB MAIN                             ;小于a的情况：其他字符，跳转重新输出
    ;大于等于a的情况
    CMP	AL,	7AH                         ;与z进行比较
    JBE WORD_DISP                       ;<=z成立则跳转输出
    JMP MAIN                            ;不成立(>z)则说明是其他字符，重新输入
WORD_DISP:
    MOV DL, 20H
    MOV AH, 2H
    INT 21H
    MOV DL, 63H                         ;显示字符c
    MOV AH, 2H
    INT 21H
    JMP MAIN
DIRCET_END:                             ;字符为回车时，设计为在最后输出提示信息并结束程序
    MOV AX, DATA
    MOV DS, AX
    LEA DX, MESG
    MOV AH, 9
    INT 21H
    MOV AH, 4CH
    INT 21H
CODES ENDS
END START






