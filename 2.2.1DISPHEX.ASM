; 程序功能：显示AL中两位十六进制数
CODES SEGMENT
    ASSUME CS:CODES            ;伪指令，CS段寄存器与CODES产生联系
START:
    MOV AX, 0AEH               ;向AL中写入原始数据，这也是程序需要输出的数据，需要指出的是这里的数据可以是任意的两位HEX值
    MOV BL, AL                 ;向BL中写入AL，起到暂存数据的作用
    MOV DL, AL                 ;向DL中写入AL
    MOV CL, 4                  ;向CL中写入4，作为二进制下的逻辑右移位数，实现了DL十六进制角度上整体右移一位，起到了取高位的作用
    SHR DL, CL                 ;逻辑右移指令，实现了DL十六进制角度上整体右移一位
    CMP DL, 9                  ;比较指令，对两数相减进行操作，这里会改变Flag中部分内容供后续JBE指令作条件判断
    JBE NEXT1                  ;条件转移指令，如果低于或等于(<=)则跳转，与CMP连用相当于if(DL<=9)=>跳转至NEXT1处向下执行，否则继续向下执行
    ADD DL, 7                  ;DL自加7，主要是处理十六进制A-F的显示问题，具体见下面的描述
NEXT1:
    ADD	DL,	30H                ;DL自加30，目的是与原字符的ASCII值进行匹配

    MOV AH, 2                  ;从DL中输出字符
    INT 21H                    ;执行上述功能调用

    MOV DL, BL                 ;DL取出暂存于BL的原数据3E
    AND DL, 0FH                ;对两数进行与运算，结果存放至DL中，起到了取低位的作用
    CMP	DL,	9                  ;比较指令，对两数相减进行操作，这里会改变Flag中部分内容供后续JBE指令作条件判断
    JBE NEXT2                  ;与CMP连用，相当于if(DL<=9)=>跳转至NEXT2向下执行，否则一直向下执行
    ADD	DL,	7                  ;DL自加7，如果不通过条件会+7处理之后再进入NEXT2，主要是大于9之后十六进制显示为A-F，而整体+7之后的十六进制值恰好都与A-F字符的ASCII值差30，这样就实现了A-F的输出对应
NEXT2:
    ADD	DL,	30H                ;DL自加30，目的是与原字符的ASCII值进行匹配

    MOV AH, 2                  ;从DL中输出字符，显示低位ASCII码
    INT 21H                    ;执行上述功能调用

    MOV AH, 4CH                ;返回命令行窗口
    INT 21H                    ;执行调用，实现返回命令行窗口
CODES ENDS
END START

