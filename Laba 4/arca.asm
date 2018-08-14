
.model small 
.stack 100h
.data 
    platform db 0FFh,44h,0FEh,44h,0FEh,44h,0FEh,44h,0FEh,44h,0FEh,44h,0FEh,44h,0FEh,44h,0FEh,44h,0FEh,44h,0FEh,44h,0FEh,44h,0FEh,44h,0FEh,44h,0FEh,44h,0FEh,44h,0FEh,44h,0FEh,44h
    platformRight   dw ?
    platformLeft    dw ?
    line_title      db 0FEh,66h
    line            dw 0x0005
    ball            db 0Fh, 0Ah   
    size_platform   dw 0x001A                 
    size_line       dw 0x00A0                    
    platformLoc     dw 0x0F50              
    ballLoc         dw 0x0F00
    repeat          dw 0x8F00
    endLine         dw 0x0FF0
    byteDivider     db 0x0002
    curX            dw 0x0050h
    curY            dw 0x0017h
    vectorX         dw -2h
    vectorY         dw -1h 
    points          dw 0x0000                                 
    max_coints      dw 0x0250                       
    points_str      db 10 dup(?)            
    LEN             dw 0                          
    score           db ' ',0Fh
                    db 's',0Fh,'c',0Fh,'o',0Fh,'r',0fh,'e',0Fh,':',0Fh,' ',0Fh ,' ',0h,' ',07h  ,' ',07h
    size_score      dw 0x0015h 
    
    rules  db '<',0Fh,'-',0Fh,' ',0Fh,'-',0fh,' ',0Fh,'w',0Fh,'r',0Fh ,'u',0Fh ,'m',0Fh ,' ',0Fh ,'v',0Fh ,'l',0Fh ,'e',0Fh ,'v',0Fh ,'o',0Fh
           db ' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh
           db ' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh
           db ' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh
           db ' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh
           db ' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh
           db ' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh
           db ' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh 
           
           db '-',0Fh,'>',0Fh,' ',0Fh,'-',0fh,' ',0Fh,'w',0Fh,'r',0Fh ,'u',0Fh ,'m',0Fh ,' ',0Fh ,'v',0Fh ,'p',0Fh ,'r',0Fh ,'a',0Fh ,'v',0Fh,'o',0Fh
           db ' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh
           db ' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh
           db ' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh
           db ' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh
           db ' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh
           db ' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh
           db ' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh
           db 'A',0Fh,'n',0Fh,'y',0Fh,' ',0Fh,'k',0Fh,'e',0Fh,'y',0Fh,' ',0Fh,'t',0Fh,'o',0Fh,' ',0Fh,'s',0Fh,'t',0Fh,'a',0Fh,'r',0Fh,'t',0Fh,'!',0Fh 
    size_rules dw 0x0162h
    
    game_over   db 'G',0Fh,'a',0Fh,'m',0Fh,'e',0Fh,' ',0h,'o',0Fh,'v',0Fh,'e',0Fh,'r',0Fh
    winner      db 'W',0Fh,'i',0Fh,'n',0Fh 
    flag        db 0
    curSpeed    dw 0x8f00           
    
    SPA     equ 20h                    
    PL      equ 0FEh                  
   
    LEFT    equ 0x4B00  ;"<-"
    RIGHT   equ 0x4D00  ; "->"  
    ENTER   equ 0x1C0D  ; "Enter"
.code 
 start:
    main1:
    call begin
    call cursorHide 
    call clearScreen
    call drawRules 
    call drawTitle 
    call drawScore
    call points_show 
    call drawPlatform 
    call drawBall
    call drawBreaks
    call go 
 main: 
    mov cx,[repeat]           
  cycle:  
    call movePlatform
    dec cx
    cmp cx, 0
    jne cycle                  
    call moveBall            
    call drawBall
    jmp main
logics: 
    begin:
        mov ax,@data
        mov ds, ax
        mov ah,00                        
        mov al,03
        int 10h  
        
        push 0B800h
        pop es
        mov ax, [platformLoc]                
        mov [platformLeft], ax             
        mov [platformRight], ax 
        mov ax, [size_platform]           
        add [platformRight],ax            
        ret
     go:
        mov ah, 00h               
        int 16h    
     cursorHide:                  
        mov ah,1               
        mov cx, 0x2000           
        int 10h 
        ret
     drawScore:
        mov di, 00h
        lea si, score
        mov cx, [size_score]
        rep movsb
        ret
     drawTitle:                 
        xor ax, ax
        mov ax, 0x0001h
        mul [size_line]           
        mov di, ax
        add ax, size_line
     cycle_:                 
        cmp di, ax           
        je return            
        mov si, offset line_title  
        mov cx, 2
        rep movsb
        jmp cycle_       
     clearScreen:               
        mov ah, 0x06
        mov al, 0x00              
        mov bh, 0x07h              
        xor cx,cx                 
        mov dl, 0x80              
        mov dh, 0x25
        int 0x10
        ret
     drawBreaks:               
        mov ax, [line]         
        mul [size_line]         
        mov bx, ax 
        add ax, [size_line]     
        mov cx, 0x0032           
     loopl:         
        call drawBlock         
        call drawSpace          
        dec cx                 
        cmp cx, 0
        je return                
        cmp bx, ax             
        jge new_line
        jmp loopl
     new_line:                   
        add ax, [size_line]     
        add [line],1            
        push ax
        mov ax, [line]
        div [byteDivider]
        cmp ah, 1             
        je step                
        add bx, 8              
        pop ax
        jmp loopl               
     step:
        pop ax
        mov bx, ax
        sub bx, [size_line]        
        jmp loopl    
     drawBlock:         ;block of 1 element  
        push cx 
        mov cx, 0x0004            
     drawBlock2:                      
        mov es:[bx], PL     
        mov es:[bx+1], 040h       
        add bx, 2                
        dec cx
        cmp cx, 0                 
        jne drawBlock2
        pop cx                    
        ret
     drawSpace:          ;space of 1 element         
        push cx
        mov cx, 0x0004
     drawSpace2:
        mov es:[bx], SPA        
        mov es:[bx+1], 0h 
        add bx, 2
        dec cx
        cmp cx, 0
        jne drawSpace2
        pop cx    
        ret  
     drawPlatform:                  
        mov di, [platformLoc]      ;location
        mov cx, [size_platform]             ;size
        mov si, offset platform                  ;draw
        cld
        rep movsb
        ret  
     movePlatform:            
        mov ah, 01h           
        int 16h
        jnz checkKey 
        ret
     checkKey:                    ;comparing with codes of right and left
        mov ah, 00h           
        int 16h 
        cmp ax, RIGHT
        je  go_right
        cmp ax, LEFT
        je  go_left
        ret
     go_right:                ;wrum-wrum pravo       
        mov bx, [platformLoc]       
        add bx, [size_platform]      
        cmp bx, [endLine]            
        jge movePlatform             
        mov es:[bx],PL         
        mov es:[bx+1], 044h 
        mov bx, [platformLoc]
        mov es:[bx],SPA            
        mov es:[bx+1],0h
        add [platformLoc],2
        add [platformRight], 2
        add [platformLeft], 2        
        jmp movePlatform
     go_left:                      ;wrum-wrum levo    
        cmp [platformLoc], 0F00h       
        jle movePlatform
        sub [platformLoc], 2
        sub [platformRight], 2
        sub [platformLeft], 2          
        mov bx, [platformLoc]
        add bx, [size_platform]        
        mov es:[bx],SPA
        mov es:[bx+1],0h 
        mov bx, [platformLoc]           
        mov es:[bx],PL
        mov es:[bx+1], 044h
        jmp movePlatform 
     moveNull:
        jmp movePlatform      
     drawBall:
        xor bx, bx
        mov bx, [ballLoc]     
        xor ax, ax
        mov ax, [curY]       
        mul [size_line]      
        add ax, [curX]       
        mov [ballLoc], ax    
        cmp ax, bx
        je return             
        mov di, ax           
        mov si, offset ball 
        mov cx, 2
        cld
        rep movsb 
        mov es:[bx], SPA   
        mov es:[bx+1], 0h
        ret
     changeVectorY:          
        neg [vectorY]
        jmp checkBorderX
     changeVectorX: 
        neg [vectorX]
        jmp next  
      
     moveBall:                  
     checkBorderY:               
        cmp [curY], 2           
        je changeVectorY
     checkBorderX:              
        xor dx, dx               
        mov dx, [size_line]
        sub dx, [vectorX]        
        cmp [curX], dx          
        jge  changeVectorX      
        cmp [curX], 0           
        jle  changeVectorX  
     next:                       
        xor ax, ax  
        mov ax, [curY]          
        add ax, [vectorY]       
        mov [curY], ax          
        xor bx, bx
        mov bx, [curX]           
        add bx, [vectorX]       
        cmp bx, 0               
        jl back1
      next1:  
        mov [curX], bx           
        mul [size_line]          
        add ax, bx              
        mov di, ax
        push di
        mov ax, es:[di] 
     next2:  
        pop di
        mov ax, es:[di]
        cmp al, PL       
        je back_move
        cmp [curY], 0x0019      
        je gameOver
        cmp al, 0FEh
        jne check_go_awake      
        ret  
     back1:                   
        neg [vectorX]
        add bx, [vectorX]      
        add bx, [vectorX]      
        jmp next1   
     back_move: 
        call checkBrick       
        neg [vectorY]         
        neg [vectorX]
        mov ax, [curY]
        add ax, [vectorY]      
        mov [curY], ax        
        mov ax, [curX]
        add ax, [vectorX]
        mov [curX], ax          
        neg [vectorX]
        call checkChangeVector  
        ret
     checkChangeVector:           
        mov dx, [platformLeft]
        sub dx, [size_line] 
        cmp dx, [ballLoc]       
        je decVectorX           
        add dx, 2              
        cmp dx, [ballLoc]
        je decVectorX           
        add dx, 2
        cmp dx, [ballLoc]       
        je decVectorX
        mov dx, [platformRight] 
        sub dx, [size_line]     
        cmp dx, [ballLoc]
        je incVectorY           
        sub dx, 2
        cmp dx, [ballLoc]
        je incVectorY 
        sub dx, 2
        cmp dx, [ballLoc]
        je incVectorY
        ret
     decVectorX: 
        sub [vectorX], 2
        ret
     incVectorY:
        add [vectorX], 2
        ret                                                       
     checkBrick:                
        cmp [curY],0x0018       
        je return 
        cmp [curY], 0x0001    
        je return
        mov ax, [curY]         
        mul [size_line]
        mov bx, ax
        add bx, [curX]
     loop1:                      
        sub bx, 2               
        cmp bx, ax
        jl go1
        cmp es:[bx], SPA
        jne loop1
     go1:                       
        add bx, 2               
        call drawSpace
        add [points],10         
        call points_show 
     return:
        ret      
     gameOver:
        call clearScreen           
        mov ax,0x000A
        mul [size_line]
        add ax,0x0048
        mov di, ax
        mov si, offset game_over
        mov cx, 0x0012
        rep movsb 
        push ax
       
        call sleep                 
        jmp reload                 
     sleep:
        mov cx,20
        mov dx,0           
        mov ah,86h              
        int 15h                 
        
     cycle_read:
        mov ah,1              
        int 16h
        jnz read
        ret   
     read:
        xor ah,ah               
        int 16h 
        jmp cycle_read   
     check_go_awake: 
        mov bx, [ballLoc]          
        add bx, [vectorX]        
        mov ax, es:[bx]         
        cmp al, 0FEh
        jne return
        mov ax, [curY]          
        mul [size_line]
        mov dx, ax
        add ax, [curX]           
        sub ax, [vectorX]
        mov bx, ax
        mov ax, es:[bx]         
        cmp al, 0FEh
        jne return 
     loop3:                  
        sub bx, 2
        cmp bx, dx
        je go2
        cmp es:[bx],0FEh
        je loop3
        add bx, 2
     go2:                        
        call drawSpace
        mov bx, [ballLoc]          
        add bx, [vectorX]        
     loop4:                        
        sub bx,2                  
        cmp es:[bx],0FEh
        je loop4
     next3:
        add bx,2                    
        call drawSpace
        neg [vectorY]             
        neg [vectorX]
        mov ax, [curY]
        add ax, [vectorY]
        mov [curY], ax
        mov ax, [curX]
        add ax, [vectorX]
        mov [curX], ax              
        add [points],20
        call points_show 
            
points_show:                         
    push bx 
    mov ax, [max_coints]
    cmp [points], ax
    jge win
    lea bx, points
    lea di, points_str
    call pointsTOstr                      
    
    mov cx, LEN
    mov di, 10h
    lea si, points_str
    cld
    rep movsb                         
    pop bx 
    ret           
pointsTOstr PROC                           
    push ax
    push bx
    push cx
    push di    

    mov ax, [bx]
    mov bx, 10
    xor cx, cx       
division:
    xor dx, dx
    div bx       
    push dx
    inc cx
    cmp ax, 0
    jne division
    
    mov LEN, cx
    add LEN, cx  
save_in_str:
    pop dx
    add dl, '0'
    mov [di], dl
    inc di  
    mov [di], 0Fh
    inc di
    loop save_in_str    
    
    pop di 
    pop cx
    pop bx
    pop ax
    ret
endp 

drawRules proc
    mov di, 00h
    lea si, rules
    mov cx, [size_rules]
    rep movsb 
    
    mov ah, 1
    int 21h 
    call clearScreen    
ret
endp

reload:
    mov ah, 00h
    int 16h
    mov bx, ENTER
    cmp ax, bx 
    jne endProgram 
    mov [points], 0
    mov [platformLoc],0x0F50
    mov [ballLoc],0x0FA0
    mov [curX],0x005Ah
    mov [curY],0x0017h
    mov [vectorX],-2h
    mov [vectorY],-1h  
    mov [line], 5 
    mov [repeat], 0x8F00
    mov [flag], 0
    call begin
    call clearScreen 
    call drawTitle 
    call drawScore
    call points_show 
    call drawPlatform 
    call drawBall
    call drawBreaks
    call go 
    jmp main
endProgram:
    call clearScreen
    mov ax, 4C00h
    int 21h
win:
        call clearScreen
        mov ax,0x000A
        mul [size_line]
        add ax,0x0048
        mov di, ax
        mov si, offset winner
        mov cx, 0x000E
        rep movsb 
        push ax
        call sleep
        jmp reload