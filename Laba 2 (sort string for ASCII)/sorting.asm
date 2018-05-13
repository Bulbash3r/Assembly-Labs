.model small
.stack 100h
.data
 
message_input  db "Enter a line for sorting: $"
message_output db "Result: $"
message_source db "Your line: $"
endline        db 10, 13, '$'
  
;буфер на 200 символов
size equ 200
line db size DUP('$')

.code
output macro str ;вывод строки
    mov ah, 9
    mov dx, offset str
    int 21h
endm

input macro str ;ввод строки
    mov ah, 0Ah
    mov dx, offset str
    int 21h
endm 

start:         
    mov ax, @data
    mov ds, ax
    mov es, ax
    
    output message_input 
    mov line[0], 197  
    
    input line
    
    mov ax, 3
    int 10h  
    
    output message_source   
    mov ah, 9
    mov dx, offset line + 2
    int 21h  
    
    output endline
    
main_loop:         
    mov ah, 9
    mov dx, offset line + 2
    int 21h 
    output endline
    ;зануляем регистры
    xor si, si
    xor di, di
    xor ax, ax
    xor dx, dx    
    mov si, offset line + 2 ;ds:si - начало строки
    
first_word:
    cmp byte ptr[si], ' ' 
    jne check_compare ;если символ не пробел
    inc si
    
    cmp byte ptr[si], 13
    je the_end ;если конец строки - к концу программы
    
    jmp first_word
     
loop_per_line:
    inc si
    cmp byte ptr[si], ' '
    je check_whitespace ;если символы равны
    cmp byte ptr[si], 13 
    jne loop_per_line 
    cmp ax, 0
    jne main_loop
    jmp the_end ;если конец строки, то выход
       
check_compare:
    cmp dx, 0
    jne compare ;если есть два слова, то сравниваем
    push si ;заносим адрес первого слова в стек
    mov dx, 1 
    jmp loop_per_line
    
check_whitespace:
    cmp byte ptr[si+1], ' '
    je loop_per_line ;если несколько пробелов, идём дальше
    inc si ;адрес второго слова
    jmp check_compare
    
compare:
    pop di ;извлекаем в es:di адрес первого слова    
    push si ;помещаем в стек адрес второго и первого слова 
    push di    
    mov cx, si
    sub cx, di
    repe cmpsb ;сравнивать пока символы равны   
    dec si
    dec di
    xor bx, bx
    mov bl,byte ptr[di] 
    cmp bl, byte ptr[si] 
    jg change ;переставляем если первое слово > второго
    pop di
    pop si
    push si 
    
    jmp loop_per_line
    
change:
    inc al
    pop di
    pop si
    
    xor cx, cx
    xor bx, bx
    mov dx, si ;второе слово   
loop1: ;поиск начала второго слова 
    dec si
    inc cx
    cmp byte ptr [si-1], ' '
    je loop1
    
loop2:
    dec si
    mov bl, byte ptr [si] 
    push bx ;помещаем первое слово в стек (с конца, естественно)
    inc ah ;длина первого слова
    cmp si, di
    jne loop2
    
    mov si, dx ;dx = адрес начала второго слова
    
loop3:  ;второе слово на первое
    cmp byte ptr [si], 13
    je loop4
    mov bl, byte ptr [si]
    xchg byte ptr [di], bl
    
    inc si
    inc di
    cmp  byte ptr [si], ' '
    jne loop3
    
loop4:
    mov byte ptr[di], ' '
    inc di
    loop loop4
    
    mov si, di
    mov dx, si
    dec si
loop5: ;первое слово на первое из стека
    inc si
    cmp byte ptr[si], 13
    je main_loop
    
    pop bx
    mov byte ptr[si], bl
    
    dec ah
    cmp ah, 0
    je loop6
    
    jmp loop5
    
loop6:
    push dx
    mov dx, 1
    xor cx, cx
    jmp loop_per_line 
        
the_end:   
    output endline
    output message_output 
    
    mov ah, 9
    mov dx, offset line + 2
    int 21h
    
    mov ah, 4Ch
    int 21h
end start