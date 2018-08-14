.model small
.stack 100h
.data
    filename        db 80 dup(0)
    buffer          db 128 dup(0)
    buf             db 0    
    handle          dw 0       
    counter         dw 0 
    c               dw 0
    flag            db 0
    space_counter   dw 0  
      
    closeString     db "Close the file$"
    errorExeString  db "Atata, ne zapuskay .exe!$"
    openFileError   db "Error of open!$"  
    openString      db "Open the file$" 
    newLine         db 13, 10, '$'
    errorString     db "Error!$"
    exitString      db "Exit$"
    lastSymbol      db 0
  
.code 
   
;Вывод строки     
outputString proc
    mov ah, 09h
    int 21h
ret 
outputString endp 
             
;Вывод \n             
printNewLine proc
    lea dx, newLine
    call outputString
ret
printNewLine endp   
     
;Считывание имени файла из ком.строки
get_name proc
    push ax  ;сохраняем наши регистры
    push cx
    push di
    push si
    xor cx, cx
    mov cl, es:[80h]  ;Количество символом в командной строке
    cmp cl, 0
    je end_get_name
    mov di, 82h       ;Смещение командной строки в блоке PSP
    lea si, filename
cicle1:
    mov al, es:[di]   ;Заносим в al посимвольно значение командной строки
    cmp al, 0Dh       ;0Dh - товарищ Enter, он же возврат каретки
    je end_get_name
    mov [si], al      ;заносим символ из ком.строки в filename 
    inc di            ;на следующий символ
    inc si            
    jmp cicle1 
end_get_name:
    dec si
    cmp BYTE PTR [si], 'e'
    je exeError
    
    cmp BYTE PTR [si], 'm'
    je exeError          
    
    pop si            ;Восстанавливаем регистры
    pop di
    pop cx
    pop ax   
ret
get_name endp

;Открытие файла для чтения и записи
fopen  proc 
   mov ah, 3dh         ;3Dh - открыть существующий файл
   mov al, 2           ;Режим доступа (чтение и запись)
   lea dx, filename    ;DS:DX - путь к файлу
   int 21h             ;Досовское прерывание (открытие)
   jc openError        ;Словили маслину - выходим, CF = 1
   mov handle, ax      ;Сохраняем идентификатор     
ret
fopen endp

;Закрытие файла
fclose proc 
   mov ah, 3eh         ;3Eh - закрытие файла
   mov bx, handle      ;Идентификатор
   int 21h             ;Закрываем лавочку(зачёркнуто) файл
   jc error            ;Прыгаем к ошибке    
ret
fclose endp     


checkTab:            
    cmp BYTE PTR [si], 9
    jne notWhiteSpace
    jmp next
    
;Удаление пустых строк
proc space 
mov counter, 0
mov space_counter, 0
i:     
    mov cx, 128    ;В cx количество байт для чтения
    mov bx, handle
    lea dx, buffer  ;В dx адрес текста для считывания
    mov ah, 3fh     
    int 21h
    jc error
    xor cx, cx
    mov cx, ax      ;В сх количество считанных символов
    jcxz close      ;Конец файла 
    
    push ax
    xor si, si
    mov c, 0        ;Счётчик прочитанных символов
    mov flag, 0
    lea si, buffer  ;Адрес строки
    cmp BYTE PTR [si], 0
    je close     
            
        k:  
            inc c   ;количество символов в строке++
            cmp  BYTE PTR [si], 10  ;newline
            je endOfLine            ;Если конец строки
            cmp  BYTE PTR [si], ' '
            jne checkTab
            next:  
            pop ax
            cmp ax, c
            je endOfLine
            push ax
            inc si
            jmp k
    jmp i

notWhiteSpace:
    cmp BYTE PTR [si], 13   ;cret
    je cret    
    pop ax
    cmp ax, c
    je endOfLine
    push ax
    mov flag, 1     ;Флаг = 1, значит строка не пустая
    inc si
    jmp k  

nonEmpty:
;перемещаем указатель
;bx - идентификатор, cx:dx - расстояние, al = 0 - относительно начала
    xor ax, ax
    mov bx, handle
    mov ah, 42h
    mov dx, counter
    xor cx, cx
    int 21h 

;пишем в файл
;bx - идентификатор, ds:dx - адрес буфера с данными
;cx - число байтов для записи
    xor ax, ax
    mov bx, handle
    mov ah, 40h
    mov dx, offset buffer
    xor cx, cx
    mov cx, c  
    int 21h
 
;добавляем к общему числу прочитанных символов число символов, прочитанных
;из текущей строки  
    mov ax, counter
    add ax, c
    mov counter, ax

    mov ax, counter
    add ax, space_counter
    mov counter, ax
      
;вновь тягаем указатель, только на этот раз к началу следующей строки      
    xor ax, ax
    mov bx, handle
    mov ah, 42h
    mov dx, counter
    xor cx, cx
    int 21h

    mov ax, counter
    sub ax, space_counter
    mov counter, ax
    
    jmp i 

Empty:
;обновляем значение считанных символов и символов в пустой строке 
    mov ax, c
    add space_counter, ax
    mov ax, counter
    add ax, space_counter
    mov counter, ax

;перемещаем указатель к концу пустой строки   
    xor ax, ax
    mov bx, handle
    mov ah, 42h
    mov dx, counter
    xor cx, cx
    int 21h
   
    mov ax, counter
    sub ax, space_counter
    mov counter, ax

    jmp i

;достигли конца строки - чекаем была ли она пустой          
endOfLine:
    cmp flag, 1
    je  nonEmpty
    jne Empty
        
cret:
    pop ax
    cmp ax, c
    je endOfLine
    push ax
    inc si
    jmp k
endp     
      
;Если ошибочка  
error:
    lea dx, errorString
    call outputString
    call printNewLine
    jmp exit  

exeError:
    lea dx, errorExeString
    call outputString
    call printNewLine
    jmp exit
    
      
openError:
    lea dx, openFileError
    call outputString
    call printNewLine
    jmp exit  
               
begin:         
    mov ax, @data
    mov ds, ax
    
    call get_name  ;Получаем название файла
    call fopen     ;И открываем его  
    
    lea dx, openString
    call outputString  
    call printNewLine
    
    call space 
    jmp close 
      
close:                                                             
    
    xor ax, ax
    mov bx, handle
    mov ah, 42h 
    dec counter
    mov dx, counter
    xor cx, cx
    int 21h    

    mov bx, handle
    mov ah, 40h
    int 21h
           
    call fclose 
    
    lea dx, closeString  
    call outputString
    call printNewLine

exit:                  
    lea dx, exitString
    call outputString 
    call printNewLine
    mov ah, 4ch
    int 21h            
end begin