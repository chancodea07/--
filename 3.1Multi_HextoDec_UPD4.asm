; 程序输入无效字符不读入，例如1jc=1c，只输入非法字符则输出0
; 支持4位转化
; 借用了2.2.1&2.2.2的写法进行字母判断
; upd1：修复了程序没有考虑中间0的问题
; upd2：勉强支持部分4位Hex的进制转换，但还是有大量的bug,逻辑不清晰（不上传）
; upd3：重构程序的逻辑，去掉了无用的的位数判断使得程序更为清晰
; upd4（Final）：细节优化，比如FFFF不显示的问题；完善程序注释
DATA SEGMENT
    STRING DB 13,10,"Please input a Hex number(Up to 4 bits):",'$'
DATA ENDS
STACKS SEGMENT
    DW 200 DUP(0)
STACKS ENDS
CODES SEGMENT
    ASSUME CS:CODES, DS:DATA, SS:STACKS
START:
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
    CMP AL,0DH                         ;如果输入字符为回车则跳到标识符Init处执行，进行寄存器初始化
    JE Init
    CMP AL,39H
    JBE NUMBER                         ;如果=<9则跳到标识符NUMBER处执行
    CMP AL,41H                         ;（>9成立）如果>=A则跳到WORD_处执行
    JAE WORD_                          ;如上解析
    JMP MAIN_INPUT                     ;（<A成立）继续输入字符
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
WORD_:
    CMP	AL,	46H                         ;大于A的情况下与F进行比较
    JBE WORD_PROCING_1                  ;<=F的情况
    CMP	AL,	61H                         ;(通过比较，大于Z的情况下)与a进行比较
    JB MAIN_INPUT                       ;小于a的情况：其他字符，跳转重新输出
    ;大于等于a的情况
    CMP	AL,	66H                         ;与f进行比较
    JBE WORD_PROCING_2                  ;<=f成立则跳转
    JMP MAIN_INPUT                      ;不成立(>f)则说明是其他字符，重新输入
WORD_PROCING_1:
    SUB DL, 37H;大写字母转十六进制字
    JMP STORING_
WORD_PROCING_2:
    SUB DL, 57H;小写字母转十六进制字
    JMP STORING_
Init:
; 寄存器初始化，便于后续处理，AX作为原始数据寄存器，BX作为压栈次数寄存器，CX和DX全部置零，为除法做准备
    MOV CX, 0
    MOV AX, BX
    MOV BX, DX
    MOV DX, 0
    MOV BX, 0
; 以上实现了输入1-4bit Hex数后将数据存入AX寄存器中，并初始化寄存器，BX用于记录十进制位数便于后续输出

; 下面进行连续/10入栈运算处理进行分类讨论，难点在于对DIV的理解
    CMP	AX, 0FFH
    JBE SIMPLE_PROCESS
    CMP AX, 0FFFFH
    JA ENDING
GENERAL:;一般的处理流程，针对除数为16位的情况，也是转化到simple_process中
    MOV CX, 0AH
    DIV CX
    PUSH DX;余数入栈
    ADD BX, 1;压栈次数记录，便于后续输出存在栈中的所有数字组成一个完整的十进制数
    MOV DX, 0;这是考虑到后续循环而采用的措施，DX必须置零，否则会出现错误的结果
    CMP AX, 0FFH;这里也要进行二次/多次判断是否除数还是16位，因为两种情况的处理逻辑是不同的
    JAE GENERAL
SIMPLE_PROCESS:;简单8位处理情况
; 每次DL取AH中存放的余数后需要将AH置零
    MOV CX, 0
    MOV CL, 0AH
    DIV CL
    MOV DL, AH
    MOV AH, 0
    PUSH DX
    ADD BX, 1;压栈次数记录，便于后续输出存在栈中的所有数字组成一个完整的十进制数
    CMP	AL,	0
    JNE SIMPLE_PROCESS
; 以上完成了转化为十进制数并入栈的工作
; 出栈输出操作，与前面的BX位数相联系进行输出即可，比较简单
Decimal_Disp:
    POP DX
    ADD DL, 30H;这里是为了正常输出数字，转换成ASCII的Hex形式
    MOV AH, 02H
    INT 21H
    SUB BX,1;压栈次数减一，类似起到循环控制的作用
    CMP BX,0;BX=0则表明输出完成，否则继续输出
    JNE Decimal_Disp
ENDING:
    MOV AH, 4CH
    INT 21H
CODES ENDS
END START

