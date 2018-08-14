.model small
.data  
    filename    db 80 dup(0)
    arguments   db 120 dup(0)
    numberTen   dw 000Ah
    
    ;EXEC Parameter Block
    EPB         dw 0                     ;текущее окружение
                dw offset commandline, 0  ;адрес командной строки
                dw 005Ch, 0, 006Ch, 0    ;адрес FCB программы      
    commandline db 125
                db " /?"
    commandtext db 122 dup (?)          
    
    numberString db 20 dup ('$')
    size        dw ?
    msg1        db 'Poehali!', 13, 10, '$'
    msg2        db 'Vvedite chislo: ', '$'
    err_msg     db 13,10,'Oshibka granic chisla$'
    erropen_msg db 13,10,"Don't open!", '$'  
    errmem_msg  db 13,10,'Oshibka pamyati', '$'
    msg3        db 13,10,'Tblk any key$'
    dsize       dw $-filename
 
.stack 256
.code         
  
;Ввод числа  
inputNumbers proc  
repeatElementInput:
    lea dx, numberString
    call inputString          
    lea si, numberString[2]
    call parseString
    jc invalidInput
    call loadNumber 
    loop inputNumbers
ret

invalidInput:
    jno tryAgainOutput
tryAgainOutput:
    jmp repeatElementInput
    
loadNumber:
    mov [di], ax
    add di, 2 
ret 
inputNumbers endp
  
  
inputString proc
    mov ah, 0Ah
    int 21h
ret
inputString endp 
  
sizeInput proc
    lea di, size
    mov cx, 0001h
    call inputNumbers
    cmp ax, 255
    jg er
    cmp ax, 1
    jl er
    call loadNumber
ret
sizeInput endp      
  
;считывание имени файла из командной строки
get_name proc
    push ax  ;сохраняем регистры
    push cx
    push di
    push si
    xor cx, cx
    mov cl, es:[80h]  ;Количество символом в командной строке
    cmp cl, 0
    je endParse
    mov di, 82h       ;Смещение командной строки в блоке PSP
    lea si, filename
cicle1:
    mov al, es:[di]   ;Заносим в al посимвольно значение командной строки
    cmp al, ' '       ;Если первое слово кончилось       
    je end_get_name
    cmp al, 0Dh
    je endParse
    mov [si], al      ;заносим символ из ком.строки в filename 
    inc di            ;на следующий символ
    inc si            
    jmp cicle1 

end_get_name: 
    lea si, arguments
    mov [si], 0
    inc si
    inc di 
    xor cl, cl
cycle2: 
    mov al, es:[di]
    cmp al, 0Dh
    je endParse
    mov [si], al
    inc di
    inc si
    inc cl
    jmp cycle2:

endParse:
    dec si       
    lea si, arguments
    dec cl
    mov [si], cl
    pop si            ;Восстанавливаем регистры
    pop di
    pop cx
    pop ax   
ret
get_name endp
           
;Макрос вывода строки
;dx - смещение строки для вывода                
output macro str
    push dx
    push ax  
    lea dx, str
    mov ah, 09h
    int 21h
    pop ax 
    pop dx
endm
 
;Парсинг строки в число
;Регистры dx, bx, ax используются в процессе, si - адрес строки
;ax содержит результат, cf - флаг переноса    
parseString proc 
    xor dx, dx
    xor bx, bx
    xor ax, ax  
    jmp inHaveSign  
parseStringLoop:
    mov bl, [si]  ;1 цифра = 1 байт 
    jmp isNumber
validString:
    sub bl, '0'
    imul numberTen ;ax * 10
    jo invalidString           ;число > 16 бит
    js invalidString           ;число > 15 бит
    add ax, bx
    js invalidString           ;чекаем положительное число на появление знака 
checkInvalid:
    inc si
    jmp parseStringLoop             
             
isNumber:
    cmp bl, 0Dh          ;enter
    je endParsing        ;если конец строки, прекращаем парсить
    cmp bl, '0'                               
    jl invalidString     ;если ASCII < '0'
    cmp bl, '9'
    jg invalidString     ;если ASCII > '9'      
    jmp validString      ;число
  
inHaveSign:
    cmp [si], '-'
    je invalidString
    cmp [si], '+'
    jne isNullString
    inc si     
    jmp isNullString
    
negative: 
    mov ch, 1
    inc si
    jmp isNullString

isNullString:
    cmp [si], 0Dh
    je invalidString
    jmp parseStringLoop
        
invalidString:
    xor ch, ch         
    stc   ;CF = 1
ret

endParsing:
    cmp ax, 255 
    jg invalidString
    cmp ax, 1
    jl invalidString
    
    clc  ;CF = 0
    mov size, ax
ret
parseString endp 
 
start:
    mov ax, @data            
    mov ds, ax  
    
    call get_name
    output msg1
    output msg2
    call sizeInput
    
    mov ax, 03
    int 10h
    
    ;освобождаем всю память после конца программы и стека    
    mov sp, csize + 100h + 200h            
    mov ah, 4ah   ;сокращаем память до минимума
    mov bx, (csize/16)+256/16+(dsize/16)+20
    int 21h           ;изменяем размер выделенного блока памяти      
    jc er
    
    mov ax, cs  
    ;блок параметров функции загрузки файла
    mov word ptr EPB+4, ax   ;сегмент командной строки
    ;file control block
    mov word ptr EPB+8, ax   ;сегмент первого FCB
    mov word ptr EPB+0Ch, ax ;сегмент второго FCB
    
    mov cx, size
     
openProgram:     
    mov ax, 4B00h       ;4B00h - загрузить и выполнить
    lea dx, filename    ;имя файла
    lea bx, epb         ;блок EPB 
    int 21h
    jc  erOpen
    loop openProgram

ex: 
    output msg3
    mov ah, 1                ;ожидаем тыка по клавише
    int 21h
    mov ax, 4c00h            ;выходим
    int 21h
er: 
    output err_msg
    jmp ex
erOpen: 
    output erropen_msg
    jmp ex 
erMem: 
    output errmem_msg
    jmp ex    
csize dw $-start 
end start