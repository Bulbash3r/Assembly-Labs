name "Laba 1"

org 100h

jmp start ; go to start

msg: db "Hello World!",0Dh,0Ah,24h ;0Dh \0, 0Ah \n

start:           ;metka start
     mov dx, msg 
     mov ah, 09h ;subfunction 9, output of string
     int 21h     ;output the message
       
     mov ah,0    ;exit code 0
     int 16h     ;exit with waiting
ret              ;return