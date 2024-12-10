;------------------------FLAPPY BIRD PROJECT   Section H:   Rollno: 0648 and 0570 -------------------------------
[org 0x0100]           
jmp start              ; Jump to start of the code 

;------------------------DATA SECTION -------------------------------

;------------------------Bird data  -------------------------------

birdinitial: dw 160 * 11 + 35 * 2 ; Initial bird position
bird: db 'D'                  ; Bird direction ('U' for up, anything else for down)
birdHeight: db 2               
birdY:dw  0
birdX:dw  70


 
  
pipeGap: db 2               
pillarinitial: dw 20 * 2      
pillar2initial:dw 40*2
pillar3initial:dw 60*2
pillar4initial:dw 80*2
randomPillar1: db 6  
randomPillar2: db 4 
randomPillar3: db 12 
randomPillar4: db 10 
randomPillar5: db 10 ; Random height for pillar 1
randomPillar6: db 8 ; Random height for pillar 2
randomPillar7: db 5 ; Random height for pillar 3
randomPillar8: db 14 ; Random height for pillar 4
pillar1Passed: db 0
pillar2Passed: db 0
pillar3Passed: db 0
pillar4Passed: db 0

;------------------------ Flags  -------------------------------

oldisr: dd 0 
oldTimerISR dd 0            
animationFlag: db 2        
score: dw 0
scoreLabel db 'Score: $'
keyReleased db 0       
timerCounter db 0      
ticksRequired db 5
colFlag: db 0
ScoreBuffer db 5, 0, 0, 0, 0, '$'
delayT : equ 0xBBBB
pcb:    dw 0, 0, 0, 0, 0 ;  
        dw 0, 0, 0, 0, 0 ;
        dw 0, 0, 0, 0, 0	
        dw 0, 0, 0, 0, 0		 
current: db 0
;------------------------Text data  -------------------------------

maxlength: dw 40
mainText: db 'Press Enter to Play'
len: db 19

;------------------------intro data  -------------------------------

line0_prompt: db  '------------------------------'
game_prompt: db   '       WACKY WINGS            '
enter_prompt: db 'PRESS S TO GO TO GAME'
presented_prompt:db    'PRESENTED BY :'
name1_prompt:db  'ESHAAL REHMATULLAH 12345678'
name2_prompt:db 'ATIKA HUSSAIN 12345678'

;------------------------pause data  -------------------------------

pausepage_prompt: db'      --PAUSE PAGE--         '
resume_prompt: db 'PRESS R KEY TO RESTART THE GAME.'
exitgame_prompt:db 'PRESS E KEY TO EXIT THE GAME.'

;------------------------exit  data  -------------------------------

exitpage_prompt: db'      --EXIT PAGE--         '
gameover_prompt: db'      --GAME OVER --         '
thankyou_prompt:db'THANKYOU FOR PLAYING THE GAME><'
backkey_prompt: db '----PRESS M KEY TO GO BACK----'

;------------------------instructions  data  -------------------------------

instruction_head: db 'INSTRUCTIONS:'
up_prompt:db      '1) PRESS UP KEY TO MOVE THE BIRD.'
pause_prompt:db   '2) PRESS P KEY TO PAUSE THE GAME.'
exit_prompt:db    '3) PRESS E KEY TO EXIT THE GAME.'
restart_prompt:db '4) PRESS R KEY TO RESTART THE GAME.'
instruc_prompt:db 'PRESS I KEY TO SEE INSTRUCTIONS.'
inst_prompt: db   '     INSTRUCTIONS PAGE        '

  ;------------------------MULTI TASKING     -------------------------------
  taskone:
  
  jmp taskone
  
  tasktwo:
  jmp tasktwo


                 ;------------------------SOUND    -------------------------------

sound:                ; Save all registers
   pusha
   pushf
   cli
   mov cx, 3          ; Repeat the sound sequence 3 times
playLoop:
    ; Load the counter 2 value for D3
    mov al, 0b6h
    out 43h, al
    mov ax, 1fb4h
    out 42h, al
    mov al, ah
    out 42h, al

    ; Turn the speaker on for D3
    in al, 61h
    mov ah, al
    or al, 3h
    out 61h, al
    call delay       ; Call the existing delay function
    mov al, ah
    out 61h, al               ; Turn off the speaker

    call delay        ; Delay between tones

    ; Load the counter 2 value for A3
    mov ax, 152fh
    out 42h, al
    mov al, ah
    out 42h, al

    ; Turn the speaker on for A3
    in al, 61h
    mov ah, al
    or al, 3h
    out 61h, al
    call delay
    mov al, ah
    out 61h, al

    call delay

    ; Load the counter 2 value for A4
    mov ax, 0A97h
    out 42h, al
    mov al, ah
    out 42h, al

    ; Turn the speaker on for A4
    in al, 61h
    mov ah, al
    or al, 3h
    out 61h, al
    call delay
    mov al, ah
    out 61h, al

    call delay

    loop playLoop             ; Repeat the sequence 5 times
    
	popf
    popa                      ; Restore all registers
    ret                       ; Return to the caller
	
	
 

                  ;------------------------KBR INTERUPT SECTION -------------------------------
kbisr:
    push ax
    push bx
    push es
    
    in al, 0x60                 ; Read the key from keyboard port
	
    cmp al, 0x1C                ; 'ENTER'
    je startAnimate            
	
    cmp al, 0x19                ; 'P'
    je stopAnimate              
	
	cmp al,0x1F                 ; 'S'
	je mainScreen
	
    cmp al, 0x13                ; 'R' 
    je restartGame              
	
    cmp al, 0x12                ; 'E'
    je exitGame                  
	
    cmp al, 0x32                ; 'M' 
    je gobacktoIntro            
	
    cmp al, 0x17                ; 'I' 
    je instructionScreen        
	
    cmp al, 0x48                ; 'UP ARROW Pressed'
    je moveBirdUp

    cmp al, 0xF0                ; 'Key Release Prefix'
    jne noRelease               ; If not, skip release logic
    
    ; Key release logic
    in al, 0x60                 ; Read the next byte
    cmp al, 0x48                ; Is it the UP arrow key?
    je birdKeyReleased          ; If yes, handle key release
    jmp endKbisr                ; Otherwise, skip
    
noRelease:
    mov byte [bird], 'D'        ; Move the bird down
    mov byte [cs:keyReleased], 1
    jmp endKbisr

moveBirdUp:
    mov byte [bird], 'U'        ; Move the bird up
    mov byte [cs:keyReleased], 0 
    jmp endKbisr

birdKeyReleased:
    mov byte [cs:keyReleased], 1 ; Set the release flag
	mov byte [timerCounter], 0 
    jmp endKbisr

startAnimate:
    cmp byte [animationFlag], 1  
    je endKbisr                  
    mov byte [animationFlag], 1  
    jmp endKbisr

stopAnimate:
    cmp byte [animationFlag], 0 
    je endKbisr                 
    mov byte [animationFlag], 0 
    call pauseScreen     
    jmp endKbisr
   
   mainScreen:
    cmp byte [animationFlag], 5 
    je endKbisr                 
    mov byte [animationFlag], 5 
    call mainscreenbackg
   jmp endKbisr
   
restartGame:
    cmp byte [animationFlag], 2 
    je endKbisr                 
    mov byte [animationFlag], 2 
	call RestartGame
    call introScreen       
    jmp endKbisr

exitGame: 
                         
    call exitScreen             
    jmp exitProgram              

gobacktoIntro:
    cmp byte [animationFlag], 2
    je endKbisr                  
    mov byte [animationFlag], 2 
    call introScreen      
    jmp endKbisr

instructionScreen:
    cmp byte [animationFlag], 3 
    je endKbisr                 
    mov byte [animationFlag], 3  
    call instrucScreen       
    jmp endKbisr

endKbisr:
    pop es
    pop bx
    pop ax
    jmp far [cs:oldisr]         ; Chain to original ISR


	                  ;------------------------TIMER -------------------------------
 
timerISR:
    pusha
    cmp byte [keyReleased], 1  
    je startCountingTicks      

skipTimerLogic:
    mov al, 0x20
    out 0x20, al               
    popa
    jmp far [cs:oldTimerISR]   ; Chain to original timer ISR
startCountingTicks:
    inc byte [cs:timerCounter]   
    mov bl, [cs:timerCounter]    
    call delay
    cmp bl, [cs:ticksRequired]
    jne skipTimerLogic           

    ; Required ticks reached
    mov byte [bird], 'D'          
    mov byte [cs:timerCounter], 0  
    mov byte [cs:keyReleased], 0  

    jmp skipTimerLogic

              ;------------------------SOFTWARE INTERUPT SECTION -------------------------------
 
print_bios_string:
    pusha
    mov ah, 0x13
    mov al, 1
    mov bh, 0
    mov bl, 0x30
    push cs
    pop es
    int 0x10
    popa
    ret
	
 print_score:
    pusha                          
    mov ax, [score]                
    mov bx, 10                     
    lea di, [ScoreBuffer + 5]       ; Point DI to the end of ScoreBuffer (reserve space)
    mov byte [di], '$'             
    dec di                         

.convert_loop:
    xor dx, dx                     
    div bx                          
    add dl, '0'                     
    mov [di], dl                    
    dec di                          
    test ax, ax                     
    jnz .convert_loop                

    lea si, [di + 1]                

    ; Set cursor position in the middle of the screen
    mov dh, 12                      ; Row 
    mov dl, 32                      ; Column 
    mov ah, 02h                     ; BIOS function to set cursor position
    int 0x10

    ; Print the converted score string
    mov ah, 09h                     ; BIOS function to print string with attributes
    mov al, [si]                    ; Load the character to print
    mov bh, 0                       ; Page number (usually 0)
    mov bl, 0Bh                     ; Text color attribute (light cyan)
    mov cx, 1                       ; Print the string once
    int 0x10                        ; Call BIOS interrupt to print character

    ; Print the rest of the string characters
print_loop:
    inc si                          ; Move to the next character in the string
    mov al, [si]                    ; Load next character
    cmp al, '$'                     ; Check if it's the end of the string
    je print_done                   ; If end of string, finish
    mov ah, 09h                     ; BIOS function to print string with attributes
    int 0x10                        ; Call BIOS interrupt to print character
    jmp print_loop                  ; Continue printing next characters

print_done:
    popa                           ; Restore registers
    ret                             ; Return from function



;------------------------ background  -------------------------------
	background1:
    push es                 
    push ds
    pusha
    pushf

    mov ax, 0xb800           
    mov es, ax
    xor di, di                 
    mov ax, 0x3F20            
    mov cx, 2000               
    rep stosw                  

;------------------------ clouds  -------------------------------
    call drawClouds
	call drawBird
	call border
	
    popf
    popa
    pop ds
    pop es
    ret
 ;------------------------ INTRO SUBROUTINE -------------------------------
 
introScreen:
	pusha
    call background1

    mov dh,3     ;middle of screen 
	mov dl,23
	mov cx,30
    mov bp, line0_prompt
    call print_bios_string
	
	add dx,0x0100
	mov cx, 30
    mov bp, game_prompt
    call print_bios_string

    add dx, 0x0100        ;next line
    mov cx,30
    mov bp, line0_prompt
    call print_bios_string

    add dx, 0x0500        ;next line
    mov cx,21
    mov bp, enter_prompt
    call print_bios_string
	
	add dx, 0x0100        ;next line
    mov cx,31
    mov bp, instruc_prompt
    call print_bios_string
	
	add dx, 0x0100        ;next line
    mov cx,30
    mov bp, exitgame_prompt 
    call print_bios_string

    add dx, 0x0500        ;next line
    mov cx,30
    mov bp, line0_prompt
    call print_bios_string
	
    add dx, 0x0100        ;next line
	mov cx,14
    mov bp, presented_prompt
    call print_bios_string

    add dx, 0x0100
	mov cx,27
    mov bp, name1_prompt
    call print_bios_string

    add dx, 0x0100
	mov cx,22
    mov bp, name2_prompt
    call print_bios_string
	
    add dx, 0x0100        ;next line
	mov cx,30
    mov bp, line0_prompt
    call print_bios_string
      
	  
	popa
	ret 
	 ;------------------------ INSTRUCTION SUBROUTINE -------------------------------
	
instrucScreen:
	pusha
    call background1

    mov dh,3     ;DOTTED LINE
	mov dl,23
	mov cx,30
    mov bp, line0_prompt
    call print_bios_string
	
	add dx,0x0100    ;INSTRUCTION PAGE
	mov cx, 30
    mov bp, inst_prompt
    call print_bios_string

    add dx, 0x0100        ;DOTTED LINE
    mov cx,30
    mov bp, line0_prompt
    call print_bios_string

    add dx, 0x0500        ;M COMMAND
    mov cx,30
    mov bp, backkey_prompt
    call print_bios_string
	
	add dx, 0x0400        ;inst head
    mov cx,13
    mov bp, instruction_head
    call print_bios_string
	
    add dx, 0x0100        ;DOTTED LINE
	mov cx,30
    mov bp, line0_prompt
    call print_bios_string
	
    add dx, 0x0100        ;UP COMMAND
    mov cx,33
    mov bp, up_prompt
    call print_bios_string
	
    add dx, 0x0100        ;P COMMAND
	mov cx,33
    mov bp, pause_prompt
    call print_bios_string

    add dx, 0x0100        ;E COMMAND
	mov cx,32
    mov bp, exit_prompt
    call print_bios_string

    add dx, 0x0100         ;R COMMAND
	mov cx,35
    mov bp, restart_prompt
    call print_bios_string
	
    add dx, 0x0100        ;DOTTED LINE
	mov cx,30
    mov bp, line0_prompt
    call print_bios_string
	popa 
	ret 
	 ;------------------------ PAUSE SUBROUTINE -------------------------------
pauseScreen:
	pusha
    call background1

    mov dh,3     ;DOTTED LINE
	mov dl,23
	mov cx,30
    mov bp, line0_prompt
    call print_bios_string
	
	add dx,0x0100    ;PAUSE PAGE
	mov cx, 29
    mov bp, pausepage_prompt
    call print_bios_string

    add dx, 0x0100        ;DOTTED LINE
    mov cx,30
    mov bp, line0_prompt
    call print_bios_string
	
    add dx, 0x0500        ;DOTTED LINE
	mov cx,30
    mov bp, line0_prompt
    call print_bios_string
	
    add dx, 0x0100        ;R COMMAND
    mov cx,32
    mov bp, resume_prompt
    call print_bios_string
	
	add dx, 0x0200        ;exit head
    mov cx,29
    mov bp, exitgame_prompt
    call print_bios_string
	add dx, 0x0200        ;exit head
    mov cx,6
    mov bp, scoreLabel
    call print_bios_string
	add dx, 0x0200        ;exit head
    mov cx,4
    mov bp, [score]
    call print_score
	
    add dx, 0x0100        ;DOTTED LINE
	mov cx,30
    mov bp, line0_prompt
    call print_bios_string
	popa 
	ret 
 ;------------------------ EXIT SUBROUTINE -------------------------------
 
    exitScreen:
    pusha
    call background1

    mov dh,3     ;DOTTED LINE
	mov dl,23
	mov cx,30
    mov bp, line0_prompt
    call print_bios_string
	
	add dx,0x0100    ;EXIT PAGE
	mov cx, 28
    mov bp, exitpage_prompt
    call print_bios_string

    add dx, 0x0100        ;DOTTED LINE
    mov cx,30
    mov bp, line0_prompt
    call print_bios_string
	
    add dx, 0x0500        ;DOTTED LINE
	mov cx,30
    mov bp, line0_prompt
    call print_bios_string
	
    
	
	 add dx, 0x0100        ;DOTTED LINE
	mov cx,30
    mov bp, line0_prompt
    call print_bios_string
	
	 add dx, 0x0300        ;DOTTED LINE
	mov cx,30
    mov bp, line0_prompt
    call print_bios_string
	
	add dx, 0x0100        ;exit head
    mov cx,31
    mov bp, thankyou_prompt
    call print_bios_string
	
    add dx, 0x0100        ;DOTTED LINE
	mov cx,30
    mov bp, line0_prompt
    call print_bios_string
	popa
	ret
	
;------------------------ GAMEVOER SUBROUTINE -------------------------------	
gameoverScreen:
    pusha
    call background1

    mov dh,3     ;DOTTED LINE
	mov dl,23
	mov cx,30
    mov bp, line0_prompt
    call print_bios_string
	
	add dx,0x0100    ;GAMEOVER PAGE
	mov cx, 28
    mov bp, gameover_prompt
    call print_bios_string

    add dx, 0x0100        ;DOTTED LINE
    mov cx,30
    mov bp, line0_prompt
    call print_bios_string
	
    add dx, 0x0500        ;DOTTED LINE
	mov cx,30
    mov bp, line0_prompt
    call print_bios_string
	
    add dx, 0x0100        ;R COMMAND
    mov cx,32
    mov bp, resume_prompt
    call print_bios_string
	
	add dx, 0x0100        ;exit head
    mov cx,6
    mov bp, scoreLabel
    call print_bios_string
	
	
	add dx, 0x0100        ;exit head
    mov cx,4
    mov bp, [score]
    call print_score
	
	 
	
    add dx, 0x0100        ;DOTTED LINE
	mov cx,30
    mov bp, line0_prompt
    call print_bios_string
	popa
	ret
	
	
	 ;------------------------ SCORE generator   -------------------------------
printScoreGame:
    pusha
    mov ax, [score]        
    mov bx, 10             
    lea di, [ScoreBuffer + 5] 
    mov byte [di], '$'     
    dec di                 

    convert_loop:
        xor dx, dx         
        div bx             
        add dl, '0'        
        mov [di], dl       
        dec di             
        test ax, ax        
        jnz convert_loop   

    lea si, [di+1]

    mov dl, 19
    mov dh, 1        
    mov bh, 0              
    mov ah, 02h            
    int 0x10               

   
    mov ah, 09h             
    mov bl, 0Bh           
    mov cx, 1             
    mov al, [si] 
    
    .print_loop:
        mov ah, 09h
        int 10h           ; Print character with color
        inc si
        inc dl            ; Move cursor right
        mov ah, 02h
        int 10h           ; Set cursor position
        mov al, [si]      ; Get next character
        cmp al, '$'       ; Check if we are done
        jne .print_loop

    popa
    ret
 

                      ;------------------------ GENERAL FUNCTIONS  -------------------------------
 
                          ;------------------------ collision -------------------------------
CheckCollision:
    pusha                             
    push es                           
    mov ax, 0xb800
    mov es, ax
    mov ax, [birdinitial]            ; Bird's current position
    mov bx, [pillarinitial]          ; Position of the first pillar
    cmp bx, 20 * 2                   
    je p1             
	
    mov bx, [pillar2initial]         ; Position of the second pillar  
    cmp bx, 40 * 2                  
    je p2           
	
    mov bx, [pillar3initial]         ; Position of the third pillar  
    cmp bx, 60 * 2                   
    je p3             
	
    mov bx, [pillar4initial]         ; Position of the fourth pillar  
    cmp bx, 80 * 2                    
    je p4           
	
p1:
    mov dx, [randomPillar1]          ; Height of the upper pipe
    mov cx, 160
    mul cx
    add dx, bx
    cmp ax, dx                       ; Check collision with the upper pipe
    jle CheckSides                   
    ; Check collision with the lower pipe
    mov dx, [randomPillar5]          
    add dx, [pipeGap]                
    cmp ax, dx
    jge CheckSides                   
    ; Score increment logic
    cmp word [pillar1Passed], 1      ; Check if the pillar has already been passed
    je NoScoreIncrement              
    cmp bx, ax
    jl IncrementScore1               ; Increment score when bird passes the pillar

p2:	
    mov dx, [randomPillar2]          ; Height of the upper pipe
    mov cx, 160
    mul cx
    add dx, bx
    cmp ax, dx                       
    jle CheckSides                   
    mov dx, [randomPillar6]          
    add dx, [pipeGap]               
    cmp ax, dx
    jge CheckSides                   
    cmp word [pillar2Passed], 1      ; Check if the pillar has already been passed
    je NoScoreIncrement
    cmp bx, ax
    jl IncrementScore2

p3:
    mov dx, [randomPillar3]          ; Height of the upper pipe
    mov cx, 160
    mul cx
    add dx, bx
    cmp ax, dx                       
    jle CheckSides                   
    cmp ax, dx
    jge CheckSides                   
    cmp word [pillar3Passed], 1      ; Check if the pillar has already been passed
    je NoScoreIncrement
    cmp bx, ax
    jl IncrementScore3 

p4:
    mov dx, [randomPillar4]          ; Height of the upper pipe
    mov cx, 160
    mul cx
    add dx, bx
    cmp ax, dx                       
    jle CheckSides                    
    mov dx, [randomPillar8]           
    add dx, [pipeGap]                 
    cmp ax, dx
    jge CheckSides                   
    cmp word [pillar4Passed], 1      ; Check if the pillar has already been passed
    je NoScoreIncrement
    cmp bx, ax
    jl IncrementScore4	
	
	

IncrementScore1:
    inc byte [score]
    mov word [pillar1Passed], 1      ; Mark pillar as passed
    jmp CheckSides
    jmp CheckSides

IncrementScore2:
    inc byte [score]
    mov word [pillar2Passed], 1      ; Mark pillar as passed
    jmp CheckSides

IncrementScore3:
    inc byte [score]
    mov word [pillar3Passed], 1      ; Mark pillar as passed
    jmp CheckSides

IncrementScore4:
    inc byte [score]
    mov word [pillar4Passed], 1      ; Mark pillar as passed
    jmp CheckSides

NoScoreIncrement:
    jmp CheckSides

CheckSides:
    ; Check the right side of the bird
    mov di, [birdinitial]
    add di, 7 * 2                     
CheckRight:
    cmp word es:[di], 0x2020          
    je SetGameOver                    
 
    mov di, [birdinitial]	
    sub di, 160                
CheckTop:
    cmp word es:[di], 0x2020          
    je SetGameOver                    
    ; Check the lower side of the bird
    add di, 320                   
CheckBottom:
    cmp word es:[di], 0x2020          
    je SetGameOver   	 

CheckGround:
    cmp word [birdinitial], 19*160         
    je SetGameOver   	 

NoPillarCollision:
call printScoreGame
    pop es                            
    popa                              
    ret                              

SetGameOver:
	; call fallBird
	; call delay
	; call delay
	
    mov byte [animationFlag], 4       ; Set game over state
    pop es
    popa
    ret

 
 
  ;------------------------  restart game  -------------------------------
  
RestartGame:
    mov word [birdinitial], 160 * 11 + 35 * 2   ; Initial bird position (X, Y)
    mov byte [bird], 'D'    
    mov byte [pipeGap], 2         ; Reset pipe gap between pipes
    ; Reset pillar positions (hardcoded values for each pillar)
    mov word [pillarinitial], 20 * 2
    mov word [pillar2initial], 40 * 2
    mov word [pillar3initial], 60 * 2
    mov word [pillar4initial], 80 * 2

    ; Reset random pillar heights (hardcoded values for each random pillar height)
    mov byte [randomPillar1], 6
    mov byte [randomPillar2], 4
    mov byte [randomPillar3], 12
    mov byte [randomPillar4], 10
    mov byte [randomPillar5], 10
    mov byte [randomPillar6], 8
    mov byte [randomPillar7], 5
    mov byte [randomPillar8], 14
	
	mov byte [pillar1Passed],0
	mov byte [pillar2Passed],0
	mov byte [pillar3Passed],0
	mov byte [pillar4Passed],0

    mov byte [score], 0
    mov byte [animationFlag], 2  
    ret           
  ;------------------------ random generator   -------------------------------
getRandomLength:
    mov al, 0x00              ; Clear AL
    out 0x70, al              ; Access RTC register
timeWaste:
    in al, 0x71               ; Get the current second value
    and al, 0x0F              ; Extract the lower nibble
    add al, 5                 ; Ensure minimum pipe length is 5
    ret
	 
  ;------------------------ delay -------------------------------
delay:
    push cx
    mov cx, [delayT]
loop1:
    dec cx
    jnz loop1
    pop cx
    ret
	
	  ;------------------------ clouds  -------------------------------
    drawClouds:
    mov di, 160 * 3 + 20      ; Starting position of the first cloud
    mov cx, 2                 ; Cloud height
cloud1Row:
    mov si, 8                 ; Cloud width
cloud1Col:
    mov word [es:di], 0xFFFF  ; White cloud character
    add di, 2                 ; Move to the next character in the row
    mov ax,si
    dec si
    jnz cloud1Col
    add di, 160 - (8 * 3)     ; Move to the next row of the cloud
    loop cloud1Row

    ; Draw the second cloud
    mov di, 160 * 6 + 60      ; Starting position of the second cloud
    mov cx, 3                 ; Cloud height
cloud2Row:
    mov si, 10                ; Cloud width
cloud2Col:
    mov word [es:di], 0xFFFF  ; White cloud character
    add di, 2                 ; Move to the next character in the row
    dec si
    jnz cloud2Col
    add di, 160 - (10 * 3)    ; Move to the next row of the cloud
    loop cloud2Row

    ; Draw the third cloud
    mov di, 160 * 3 + 130     ; Starting position of the third cloud
    mov cx, 2                 ; Cloud height
cloud3Row:
    mov si, 6                 ; Cloud width
cloud3Col:
    mov word [es:di], 0xFFFF  ; White cloud character
    add di, 2                 ; Move to the next character in the row
    dec si
    jnz cloud3Col
    add di, 160 - (6 * 3)     ; Move to the next row of the cloud
    loop cloud3Row
	ret
		
	;------------------------ GROUND SUBROUTINE -------------------------------
RenderGround:
    pusha                             ; Save all registers
    push es                           ; Save ES register
    mov ax, 0xB800
    mov es, ax

    mov di, 160 * 20                 ; Start at the ground row (position 160*20 in video memory)
    mov cx, 5                        ; Number of ground rows to render
groundRow:
    mov si, 80                       ; 80 characters per row
    xor bx, bx                       ; Reset column counter
groundCol:
    cmp bx, 5                        ; Check if the column counter is 5
    jne printSpace                   ; If not 5, print a space
    mov word [es:di], 0x2E07         ; Dot character ('.') with color (0x2E07)
    xor bx, bx                       ; Reset column counter
    jmp continueGround

printSpace:
    mov word [es:di], 0x2020         ; Ground color and space (0x2020)
    
continueGround:
    inc bx                           ; Increment column counter
    add di, 2                        ; Move to the next character position (2 bytes per character in video memory)
    dec si                           ; Decrement row counter
    jnz groundCol                    ; Repeat for all columns in the row
    add di, 0                        ; Move to the next ground row
    loop groundRow                   ; Repeat for all ground rows


    pop es                            ; Restore ES register
    popa                              ; Restore all registers
    ret                               ; Return from subroutine
	
	               ;------------------------ bird and border  -------------------------------
	  
fallBird:
pusha
push di
    mov di,   160 * 19 + 35 * 2 
    mov cx, [birdHeight]                 ; Bird height
.birdBR:
    mov si, 6                ; Bird width
.birdBC:
    mov word [es:di], 0x6020  ; Bird body color and character
    add di, 2
    dec si
    jnz .birdBC
    add di, 160 - (6 * 2)     ; Move to next bird row
    loop .birdBR

    ; Draw bird's beak
    mov di,   160 * 19 + 35 * 2 
    add di, 170
    mov cx, 2
.birdB:
    mov word [es:di], 0xCC20  ; Bird beak color and character
    add di, 2
    loop .birdB

    ; Draw bird's eyes
    mov di,   160 * 19 + 35 * 2 
    add di, 6
    mov word [es:di], 0x0020  ; Left eye
    add di, 4
    mov word [es:di], 0x0020  ; Right eye
    pop di 
	popa
	ret
	
 drawBird:
pusha
push di
    mov di,   160 * 16 + 65 * 2 
    mov cx, [birdHeight]                 ; Bird height
birdBR:
    mov si, 6                ; Bird width
birdBC:
    mov word [es:di], 0x6020  ; Bird body color and character
    add di, 2
    dec si
    jnz birdBC
    add di, 160 - (6 * 2)     ; Move to next bird row
    loop birdBR

    ; Draw bird's beak
    mov di,   160 * 16 + 65 * 2 
    add di, 170
    mov cx, 2
birdB:
    mov word [es:di], 0xCC20  ; Bird beak color and character
    add di, 2
    loop birdB

    ; Draw bird's eyes
    mov di,   160 * 16 + 65 * 2 
    add di, 6
    mov word [es:di], 0x0020  ; Left eye
    add di, 4
    mov word [es:di], 0x0020  ; Right eye
    pop di 
	popa
	ret
	 ;BORDER
	
 border: 
    mov dx,0x2020
    mov di, 0
moveRight:
    add di, 2
    mov word [es:di], dx
    cmp di, 158    ;160-2
    jnz moveRight

mov di, 158
moveDown:
    add di, 160
    mov word [es:di], dx
    cmp di, 3998    ;4000-2
    jnz moveDown

mov di, 3998
moveLeft:
    sub di, 2
    mov word [es:di], dx
    cmp di, 3840
    jnz moveLeft

moveUp:
    sub di, 160
    mov word [es:di], dx
    cmp di, 160
    jnz moveUp
	ret
	
   
;----------------------------------- STATIC START SCREEN--------------------------------------
	
staticBird:
pusha
push di
    mov di,   160 * 11 + 35 * 2 
    mov cx, [birdHeight]                 ; Bird height
staticBR:
    mov si, 6                ; Bird width
staticBC:
    mov word [es:di], 0x6020  ; Bird body color and character
    add di, 2
    dec si
    jnz staticBC
    add di, 160 - (6 * 2)     ; Move to next bird row
    loop staticBR

    ; Draw bird's beak
    mov di,   160 * 11 + 35 * 2 
    add di, 170
    mov cx, 2
staticB:
    mov word [es:di], 0xCC20  ; Bird beak color and character
    add di, 2
    loop staticB

    ; Draw bird's eyes
    mov di,   160 * 11 + 35 * 2 
    add di, 6
    mov word [es:di], 0x0020  ; Left eye
    add di, 4
    mov word [es:di], 0x0020  ; Right eye
    pop di 
	popa
	ret
	
mainscreenbackg:

	push es                   ; Save registers
    pusha
    pushf

    mov ax, 0xb800            ; Set video memory segment
    mov es, ax
    xor di, di                ; Start at the beginning of video memory
    mov ax, 0x3F20            ; Space character with cyan color
    mov cx, 2000              ; Clear 2000 words (screen size)
    rep stosw                 ; Write to screen
      
	 call staticBird
     call RenderGround
     call drawClouds
	  call delay
    popf
    popa
    pop es
    ret
	           ;------------------------ GAME ELEMENTS  -------------------------------
background:
    push es                   ; Save registers
    push ds
    pusha
    pushf

    mov ax, 0xb800            ; Set video memory segment
    mov es, ax
    xor di, di                ; Start at the beginning of video memory
    mov ax, 0x3F20            ; Space character with cyan color
    mov cx, 2000              ; Clear 2000 words (screen size)
    rep stosw                 ; Write to screen

;------------------------ clouds  -------------------------------
    call drawClouds
	
    popf
    popa
    pop ds
    pop es
    ret
	;------------------------ START SCREEN  -------------------------------
	printStartScreen:
    push es                   ; Save registers
    push ds
    pusha
    pushf
    mov ax, 0xb800
    mov es, ax
;------------------------ pillar1 -------------------------------
mov cl, [randomPillar1]    ; Use stored height for the upper pipe
mov di, [pillarinitial]    ; Use the current pillar position

printUpperPipe:
    push cx                ; Save row counter (upper pipe height)
    mov cx, 4              ; Pillar width (4 columns)
printUpperPipeRow:
    mov word [es:di], 0x2020 ; Write character for the upper pipe
    add di, 2              ; Move to the next column
    loop printUpperPipeRow ; Repeat for all columns
    pop cx                 ; Restore row counter
    add di, 160 - (4 * 2)  ; Move to the next row
    dec cl                 ; Decrement row count
    jnz printUpperPipe     ; Repeat for all rows

; Calculate lower pipe start position
mov al, 20                 ; Total rows from top to ground
sub al, cl                 ; Subtract upper pipe length
sub al, [pipeGap]          ; Apply pipe gap
mov bl, al
mov al, 160
mul bl                     ; Calculate row offset for lower pipe
mov di, ax
add di, [pillarinitial]    ; Use the current pillar position

printLowerPipe:
    push cx                ; Save row counter (lower pipe height)
    mov cx, 4              ; Pillar width (4 columns)
printLowerPipeRow:
    mov word [es:di], 0x2020 ; Write character for the lower pipe
    add di, 2              ; Move to the next column
    loop printLowerPipeRow ; Repeat for all columns
    pop cx                 ; Restore row counter
    add di, 160 - (4 * 2)  ; Move to the next row
    dec cl                 ; Decrement row count
    jnz printLowerPipe     ; Repeat for all rows

	
;------------------------ pillar2 -------------------------------
	mov cl, [randomPillar2]    ; Use stored height for the upper pipe
    mov di, [pillar2initial]    ; Use the current pillar position

printUpperPipe2:
    push cx                ; Save row counter (upper pipe height)
    mov cx, 4              ; Pillar width (4 columns)
printUpperPipeRow2:
    mov word [es:di], 0x2020 ; Write character for the upper pipe
    add di, 2              ; Move to the next column
    loop printUpperPipeRow2 ; Repeat for all columns
    pop cx                 ; Restore row counter
    add di, 160 - (4 * 2)  ; Move to the next row
    dec cl                 ; Decrement row count
    jnz printUpperPipe2    ; Repeat for all rows

; Calculate lower pipe start position
mov al, 20                 ; Total rows from top to ground
sub al, cl                 ; Subtract upper pipe length
sub al, [pipeGap]          ; Apply pipe gap
mov bl, al
mov al, 160
mul bl                     ; Calculate row offset for lower pipe
mov di, ax
add di, [pillar2initial]    ; Use the current pillar position

printLowerPipe2:
    push cx                ; Save row counter (lower pipe height)
    mov cx, 4              ; Pillar width (4 columns)
printLowerPipeRow2:
    mov word [es:di], 0x2020 ; Write character for the lower pipe
    add di, 2              ; Move to the next column
    loop printLowerPipeRow2 ; Repeat for all columns
    pop cx                 ; Restore row counter
    add di, 160 - (4 * 2)  ; Move to the next row
    dec cl                 ; Decrement row count
    jnz printLowerPipe2     ; Repeat for all rows
 
 ;------------------------ pillar3 -------------------------------

mov cl, [randomPillar3]    ; Use stored height for the upper pipe
mov di, [pillar3initial]    ; Use the current pillar position

printUpperPipe3:
    push cx                ; Save row counter (upper pipe height)
    mov cx, 4              ; Pillar width (4 columns)
printUpperPipeRow3:
    mov word [es:di], 0x2020 ; Write character for the upper pipe
    add di, 2              ; Move to the next column
    loop printUpperPipeRow3 ; Repeat for all columns
    pop cx                 ; Restore row counter
    add di, 160 - (4 * 2)  ; Move to the next row
    dec cl                 ; Decrement row count
    jnz printUpperPipe3   ; Repeat for all rows

; Calculate lower pipe start position
mov al, 20                 ; Total rows from top to ground
sub al, cl                 ; Subtract upper pipe length
sub al, [pipeGap]          ; Apply pipe gap
mov bl, al
mov al, 160
mul bl                     ; Calculate row offset for lower pipe
mov di, ax
add di, [pillar3initial]    ; Use the current pillar position

printLowerPipe3:
    push cx                ; Save row counter (lower pipe height)
    mov cx, 4              ; Pillar width (4 columns)
printLowerPipeRow3:
    mov word [es:di], 0x2020 ; Write character for the lower pipe
    add di, 2              ; Move to the next column
    loop printLowerPipeRow3 ; Repeat for all columns
    pop cx                 ; Restore row counter
    add di, 160 - (4 * 2)  ; Move to the next row
    dec cl                 ; Decrement row count
    jnz printLowerPipe3     ; Repeat for all rows
 
  ;------------------------ pillar4 -------------------------------
 
		mov cl, [randomPillar4]    ; Use stored height for the upper pipe
mov di, [pillar4initial]    ; Use the current pillar position

printUpperPipe4:
    push cx                ; Save row counter (upper pipe height)
    mov cx, 4              ; Pillar width (4 columns)
printUpperPipeRow4:
    mov word [es:di], 0x2020 ; Write character for the upper pipe
    add di, 2              ; Move to the next column
    loop printUpperPipeRow4 ; Repeat for all columns
    pop cx                 ; Restore row counter
    add di, 160 - (4 * 2)  ; Move to the next row
    dec cl                 ; Decrement row count
    jnz printUpperPipe4   ; Repeat for all rows

; Calculate lower pipe start position
mov al, 20                 ; Total rows from top to ground
sub al, cl                 ; Subtract upper pipe length
sub al, [pipeGap]          ; Apply pipe gap
mov bl, al
mov al, 160
mul bl                     ; Calculate row offset for lower pipe
mov di, ax
add di, [pillar4initial]    ; Use the current pillar position

printLowerPipe4:
    push cx                ; Save row counter (lower pipe height)
    mov cx, 4              ; Pillar width (4 columns)
printLowerPipeRow4:
    mov word [es:di], 0x2020 ; Write character for the lower pipe
    add di, 2              ; Move to the next column
    loop printLowerPipeRow4 ; Repeat for all columns
    pop cx                 ; Restore row counter
    add di, 160 - (4 * 2)  ; Move to the next row
    dec cl                 ; Decrement row count
    jnz printLowerPipe4     ; Repeat for all rows
 
call RenderGround
call continueBird
  ;------------------------ BIRD print  -------------------------------
  
    mov di, [birdinitial]
    mov cx, [birdHeight]                 ; Bird height
birdBodyRow:
    mov si, 6              ; Bird width
birdBodyCol:
    mov word [es:di], 0xEE20  ; Bird body color and character
    add di, 2
    dec si
    jnz birdBodyCol
    add di, 160 - (6 * 2)     ; Move to next bird row
    loop birdBodyRow

    ; Draw bird's beak
    mov di, [birdinitial]
    add di, 170
    mov cx, 2
birdBeak:
    mov word [es:di], 0xCC20  ; Bird beak color and character
    add di,2
    loop birdBeak

    ; Draw bird's eyes
    mov di, [birdinitial]
    add di, 6
    mov word [es:di], 0x0020  ; Left eye
    add di, 4
    mov word [es:di], 0x0020  ; Right eye
	
  ;------------------------ bird movement -------------------------------
    
    cmp byte [bird], 'U'
    jne downn
    sub word [birdinitial], 160 ; Move bird up
    ;call continueBird
	jmp exit
downn:
    add word [birdinitial], 160 ; Move bird down
    ;call continueBird

exit:
    popf                      ; Restore registers
    popa
    pop ds
    pop es
    ret
 

  ;------------------------ MOVE ground -------------------------------	
moveGround:
    push es                  ; Save registers
    push ds
    pusha

    mov ax, 0xb800           ; Video memory segment
    mov es, ax
    mov di, 160 * 20         ; Start of the ground row in video memory

    ; Loop through each row of the ground
    mov cx, 5                ; Number of ground rows
groundRowLoop:
    push di                  ; Save the current row's starting position
    mov si, di               ; Source position (current row)
    add si, 2                ; Shift one character to the left
    mov dx, 78               ; Number of characters to shift

groundShiftLoop:
    mov ax, [es:si]          ; Read word from source
    mov [es:di], ax          ; Write word to destination
    add si, 2                ; Advance source pointer
    add di, 2                ; Advance destination pointer
    dec dx                   ; Decrement the character counter
    jnz groundShiftLoop      ; Repeat until the entire row is shifted

    ; Add a new character at the end of the row
    mov word [es:di], 0x2020 ; Write space at the end of the row

    pop di                   ; Restore row starting position
    add di, 160              ; Move to the next ground row
    loop groundRowLoop       ; Repeat for all ground rows

    popa
    pop ds
    pop es
    ret
	  ;------------------------ move bird and  pillars  -------------------------------
	continueBird:
    push es
    push ds
    pusha
    pushf

    ; Move the first pillar
    sub word [pillarinitial], 2
    cmp word [pillarinitial], 0
    jge continuePillar1
    mov word [pillarinitial], 80 * 2 ; Reset pillar 1 position
    call getRandomLength             ; Generate new height
    mov [randomPillar1], al          ; Store new height

continuePillar1:

    ; Move the second pillar
    sub word [pillar2initial], 2
    cmp word [pillar2initial], 0
    jge continuePillar2
    mov word [pillar2initial], 80 * 2 ; Reset pillar 2 position
    call getRandomLength              ; Generate new height
    mov [randomPillar2], al           ; Store new height

continuePillar2:

    ; Move the third pillar
    sub word [pillar3initial], 2
    cmp word [pillar3initial], 0
    jge continuePillar3
    mov word [pillar3initial], 80 * 2 ; Reset pillar 3 position
    call getRandomLength              ; Generate new height
    mov [randomPillar3], al           ; Store new height

continuePillar3:
    ; Move the fourth pillar
    sub word [pillar4initial], 2
    cmp word [pillar4initial], 0
    jge continuePillar4
    mov word [pillar4initial], 80 * 2 ; Reset pillar 4 position
    call getRandomLength              ; Generate new height
    mov [randomPillar4], al           ; Store new height

continuePillar4:

    popf                      ; Restore registers
    popa
    pop ds
    pop es
    ret

                  ;------------------------ MAIN MENU  -------------------------------


start:
    ;------------------------ Store Old Keyboard and Timer Interrupt -----------------------
                          
    xor ax, ax
    mov es, ax                  
    mov ax, [es:9*4]            
    mov [oldisr], ax            
    mov ax, [es:9*4+2]          
    mov [oldisr+2], ax          

 cli
    mov ax, [es:8*4]            
    mov [oldTimerISR], ax       
    mov ax, [es:8*4+2]          
    mov [oldTimerISR+2], ax    
     ;------------------------ Install  New Keyboard and Timer Interrupt -----------------------
    mov word [es:9*4], kbisr    
    mov word [es:9*4+2], cs     

     
    mov word [es:8*4], timerISR 
    mov word [es:8*4+2], cs     
    sti                         
  
    ;------------------------ Main Game Loop -------------------------------
mainloop:
    call delay

    cmp byte [animationFlag], 0 ; Check if paused
    je pauseScreenWait           
	
    cmp byte [animationFlag], 1 ; Check if animation is active
    je mainAni                  
	
    cmp byte [animationFlag], 2 ; Check if intro screen
    je introWait                ;  
	
    cmp byte [animationFlag], 3 ; Check if instructions screen
    je instrucWait              
	
	 cmp byte [animationFlag], 4 ; Check if game over  
    je gameOverWait       

    cmp byte [animationFlag], 5 ; Check if game over  
    je mainscreenWait       	
	
	EndGame:
    mov byte [animationFlag],4        ;  flag for game over 
    call gameoverScreen               ; Display the "Game Over" screen
    call RestartGame                  ; Reset game  
    jmp mainloop               

mainAni:
    call background             ; Render the background
    call printStartScreen       ; Render game elements
	call delay
    call moveGround                      
    call CheckCollision
	 call printScoreGame  
    call delay                  

    jmp mainloop                ; Loop back to check state

 ;------------------------ Wait logic for calling screens  -------------------------------
pauseScreenWait:
    call pauseScreen            
    jmp mainloop                

introWait:
    call introScreen            
    jmp mainloop

instrucWait:
    call instrucScreen          
    jmp mainloop
	
mainscreenWait:
	call mainscreenbackg
	jmp mainloop
	
gameOverWait:
  call gameoverScreen          
  call sound
  jmp mainloop
  
   
;------------------------  restore kbisr for smooth exit   -------------------------------
restoreISR:
    cli                         
    xor ax, ax
    mov es, ax                  
    mov ax, [oldisr]            
    mov [es:9*4], ax            
    mov ax, [oldisr+2]          
    mov [es:9*4+2], ax          
    sti                         
    ret

 exitProgram:
    cli                          
    call restoreISR              
    mov ax, 0x3100               ; terminate
    int 0x21