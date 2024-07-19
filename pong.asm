BUFFER_SIZE = 501
.data

buffer BYTE BUFFER_SIZE DUP(?)
filename BYTE "winPeople.txt", 0
fileHandle HANDLE ?
stringLength DWORD ?

SPACE BYTE " ",0dh,0ah,0

READ BYTE BUFFER_SIZE DUP(?)

BALL_X BYTE 14                  ;moves row
BALL_Y BYTE 39					;moves column
COUNT BYTE 0

BALL_VELOCITY_X BYTE 1
BALL_VELOCITY_Y BYTE 1 

PADDLE_LEFT_X BYTE 1                 
PADDLE_LEFT_Y BYTE 1

ORIGINAL_PADDLE_LEFT_X BYTE ?                
ORIGINAL_PADDLE_LEFT_Y BYTE ?
VAL1 BYTE 1
VAL2 BYTE 7

PADDLE_RIGHT_X BYTE 1     
PADDLE_RIGHT_Y BYTE 77

ORIGINAL_PADDLE_RIGHT_X BYTE ?                
ORIGINAL_PADDLE_RIGHT_Y BYTE ?
VAL3 BYTE 1
VAL4 BYTE 7

GAME_START_FLAG BYTE 0  ;flag to determine if the game should start 

tilte0 BYTE "                                                                                                 ",0
title1 BYTE "                    _____   ____  _   _  _____               _____          __  __ ______        ",0
title2 BYTE "                   |  __ \ / __ \| \ | |/ ____|            / ____|   /\   |  \/  |  ____|        ",0
title3 BYTE "                   | |__) | |  | |  \| | |  __            | |  __   /  \  | \  / | |__           ",0
title4 BYTE "                   |  ___/| |  | | . ` | | |_ |           | | |_ | / /\ \ | |\/| |  __|            ",0
title5 BYTE "                   | |    | |__| | |\  | |__| |           | |__| |/ ____ \| |  | | |____           ",0
title6 BYTE "                   |_|     \____/|_| \_|\_____|            \_____/_/    \_\_|  |_|______|           ",0
title7 BYTE "                                                                                                   ",0
title8 BYTE "                                                                                                     ",0
title9 BYTE "                                                                                                      ",0

 WIN1 BYTE "                   _____  _           __     ________ _____     __   __          _______ _   _  _____     ",0
 WIN2 BYTE "                  |  __ \| |        /\\ \   / /  ____|  __ \   /_ |  \ \        / /_   _| \ | |/ ____|	",0
 WIN3 BYTE "                  | |__) | |       /  \\ \_/ /| |__  | |__) |   | |   \ \  /\  / /  | | |  \| | (___		",0
 WIN4 BYTE "                  |  ___/| |      / /\ \\   / |  __| |  _  /    | |    \ \/  \/ /   | | | . ` |\___ \	    ",0
 WIN5 BYTE "                  | |    | |____ / ____ \| |  | |____| | \ \    | |     \  /\  /   _| |_| |\  |____) |	",0
 WIN6 BYTE "                  |_|    |______/_/    \_\_|  |______|_|  \_\   |_|      \/  \/   |_____|_| \_|_____/	    ",0
                                                                                     

 LOST1 BYTE "                   _____  _           __     ________ _____     __     __          _______ _   _  _____     ",0
 LOST2 BYTE "                  |  __ \| |        /\\ \   / /  ____|  __ \   |__ \   \ \        / /_   _| \ | |/ ____|	",0
 LOST3 BYTE "                  | |__) | |       /  \\ \_/ /| |__  | |__) |     ) |   \ \  /\  / /  | | |  \| | (___		",0
 LOST4 BYTE "                  |  ___/| |      / /\ \\   / |  __| |  _  /     / /     \ \/  \/ /   | | | . ` |\___ \	    ",0
 LOST5 BYTE "                  | |    | |____ / ____ \| |  | |____| | \ \    / /_      \  /\  /   _| |_| |\  |____) |	",0
 LOST6 BYTE "                  |_|    |______/_/    \_\_|  |______|_|  \_\   |____|     \/  \/   |_____|_| \_|_____/	    ",0                                                    
																		   


START_GAME_MSG BYTE "                     1. PLAY GAME                                 ",0
DISPLAY BYTE "                     2. DISPLAY WINNERS                                      ",0
EXIT_MSG BYTE "                     3. EXIT                                      ",0
SELECT_OPTION_MSG BYTE "                     Select an option (1 or 2):   ",0
NUMBER_OF_WINNERS BYTE " NUMBER OF PLAYER WHO HAVE WON TILL NOW ",0
INVALID_MSG BYTE "Invalid option. Please try again.",0
Player1_Score BYTE "PLAYER 1 Points: ",0
Player2_Score BYTE "PLAYER 2 Points: ",0
PLAYER1 BYTE 0
PLAYER2 BYTE 0

PLAYER_1 BYTE 30 DUP(?)
PLAYER_2 BYTE 30 DUP(?)
LENGTH_PLAYER1 BYTE ?
LENGTH_PLAYER2 BYTE ?

INPUT_PLAYER_1 BYTE "Enter Player 1's Name: ",0
INPUT_PLAYER_2 BYTE "Enter Player 2's Name: ",0

BOX_TOP_LEFT_X BYTE 15
BOX_TOP_LEFT_Y BYTE 40

PlAYER_CURSOR_X BYTE 19
PlAYER_CURSOR_Y BYTE 42

NEXT_LINE BYTE 0dh,0ah

.code
main PROC

call mainMenu  ;display menu
cmp GAME_START_FLAG, 0 
je Exitprogram

mov eax,0
mov edx,0
call DRAW_BALL
call DRAW_LEFT_PADDLES
call DRAW_TEXT
CHECK_TIME:

call CLEAR_SCREEN
call MOVE_BALL
call DRAW_BALL
call MOVE_PADDLES
call DRAW_LEFT_PADDLES
call DRAW_RIGHT_PADDLES
call DRAW_TEXT
cmp COUNT,0
jne CHECK_TIME
call clrscr
cmp PLAYER1,2
jne PLAYER2_JEET_GAYA
call PLAYER1_WINS
jmp stop

PLAYER2_JEET_GAYA:
call PLAYER2_WINS

stop:

exit

Exitprogram:
   invoke Exitprocess, 0

main ENDP

VIEW_FILE PROC
call crlf
mov edx,OFFSET NUMBER_OF_WINNERS
call writeSTRING
call crlf
    mov edx, OFFSET filename
    call OpenInputFile
    mov fileHandle, eax

    mov edx, OFFSET READ
    mov ecx, BUFFER_SIZE
    call ReadFromFile
	mov buffer[eax],0
    ; Process the data as needed

	mov edx,OFFSET READ 
	call WriteString
    mov eax,fileHandle
	call CloseFile

    RET

HandleError:
    ; Your error-handling code here
    RET
VIEW_FILE ENDP



STORE_IN_FILE1 PROC

INVOKE CreateFile,ADDR filename,GENERIC_WRITE+GENERIC_READ,DO_NOT_SHARE,NULL,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
mov fileHandle,eax
mov cl,LENGTHOF PLAYER_1
mov stringLength,0
INVOKE SetFilePointer,fileHandle,0,0,FILE_END
INVOKE WriteFile, fileHandle,ADDR PLAYER_1,LENGTH_PLAYER1 ,ADDR stringLength,NULL
mov eax, filehandle
mov edx, offset NEXT_LINE
mov ecx, lengthof NEXT_LINE
call writetofile
invoke CloseHandle,fileHandle
    

    RET
STORE_IN_FILE1 ENDP


STORE_IN_FILE2 PROC
    

  INVOKE CreateFile,ADDR filename,GENERIC_WRITE+GENERIC_READ,DO_NOT_SHARE,NULL,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
mov fileHandle,eax
mov cl,LENGTHOF PLAYER_2
mov stringLength,0
INVOKE SetFilePointer,fileHandle,0,0,FILE_END
INVOKE WriteFile, fileHandle,ADDR PLAYER_2,LENGTH_PLAYER2,ADDR stringLength,NULL
mov eax, filehandle
mov edx, offset NEXT_LINE
mov ecx, lengthof NEXT_LINE
call writetofile
invoke CloseHandle,fileHandle

    RET
STORE_IN_FILE2 ENDP


PLAYER2_WINS PROC

call STORE_IN_FILE2
 mov edx, OFFSET LOST1
	mov eax, RED
	call SetTextColor
    call WriteString
    call crlf

	mov edx, OFFSET LOST2
	mov eax, RED
	call SetTextColor
    call WriteString
    call crlf

	mov edx, OFFSET LOST3
	mov eax, RED
	call SetTextColor
    call WriteString
    call crlf

	mov edx, OFFSET LOST4
	mov eax, RED
	call SetTextColor
    call WriteString
    call crlf

	mov edx, OFFSET LOST5
	mov eax, RED
	call SetTextColor
    call WriteString
    call crlf

	mov edx, OFFSET LOST6
	mov eax, RED
	call SetTextColor
    call WriteString
    call crlf

RET
PLAYER2_WINS ENDP

PLAYER1_WINS PROC

	call STORE_IN_FILE1
    mov edx, OFFSET WIN1
	mov eax, BLUE
	call SetTextColor
    call WriteString
    call crlf

	mov edx, OFFSET WIN2
	mov eax, BLUE
	call SetTextColor
    call WriteString
    call crlf

	mov edx, OFFSET WIN3
	mov eax, BLUE
	call SetTextColor
    call WriteString
    call crlf

	mov edx, OFFSET WIN4
	mov eax, BLUE
	call SetTextColor
    call WriteString
    call crlf

	mov edx, OFFSET WIN5
	mov eax, BLUE
	call SetTextColor
    call WriteString
    call crlf

	mov edx, OFFSET WIN6
	mov eax, BLUE
	call SetTextColor
    call WriteString
    call crlf

RET
PLAYER1_WINS ENDP



mainMenu PROC
    mov edx, OFFSET title1
	mov eax, RED
	call SetTextColor
    call WriteString
    call crlf

	mov edx, OFFSET title2
	mov eax, GREEN
	call SetTextColor
    call WriteString
    call crlf

	mov edx, OFFSET title3
	mov eax, RED
	call SetTextColor
    call WriteString
    call crlf

	mov edx, OFFSET title4
	mov eax, GREEN
	call SetTextColor
    call WriteString
    call crlf

	mov edx, OFFSET title5
	mov eax, RED
	call SetTextColor
    call WriteString
    call crlf

	mov edx, OFFSET title6
	mov eax, GREEN
	call SetTextColor
    call WriteString
    call crlf

	mov edx, OFFSET title7
    call WriteString
    call crlf

	mov edx, OFFSET title8
    call WriteString
    call crlf

	mov edx, OFFSET title9
    call WriteString
    call crlf

	options:
    mov edx, OFFSET START_GAME_MSG
	mov eax, BLUE
	call SetTextColor
    call WriteString
    call crlf

	mov edx,OFFSET DISPLAY
	call WriteString
	call crlf

	mov edx, OFFSET EXIT_MSG
	mov eax, BLUE
	call SetTextColor
    call WriteString
    call crlf

    mov edx, OFFSET SELECT_OPTION_MSG
	mov eax, BLUE
	call SetTextColor
	call crlf
    call WriteString
   
    call ReadInt
	
    ; Check the selected option
    cmp eax, 1
    je InputPlayerNames
	cmp eax,2
	je line_BARHO
    cmp eax, 3
    je ExitGame


    mov edx, OFFSET INVALID_MSG
	mov eax, RED
	call SetTextColor
    call WriteString
    call crlf
	jmp options
  

	InputPlayerNames:
	    mov eax, 0     ;Display a box for player names
		mov edx, 0
		call DRAW_BOX

		;Print Player 1's name
        mov edx, OFFSET INPUT_PLAYER_1
        mov eax, YELLOW
        call SetTextColor
        mov dh, PLAYER_CURSOR_X
        mov dl, PLAYER_CURSOR_Y
        call gotoxy
		mov edx, OFFSET INPUT_PLAYER_1
        call WriteString

		
		mov edx, OFFSET PLAYER_1
		mov ecx, 30
		call ReadString
		mov LENGTH_PLAYER1,al

        ; Print Player 2's name
        mov edx, OFFSET INPUT_PLAYER_2
        mov eax, YELLOW
        call SetTextColor
		INC PLAYER_CURSOR_X
        mov dh,PLAYER_CURSOR_X
        mov dl, PLAYER_CURSOR_Y
        call gotoxy
		mov edx, OFFSET INPUT_PLAYER_2
        call WriteString


		mov edx, OFFSET PLAYER_2
		mov ecx, 30
		call ReadString
		mov LENGTH_PLAYER2,al

		mov GAME_START_FLAG, 1
		call Clrscr
		ret

    StartGame:
        mov GAME_START_FLAG, 1   ; Set the flag to 1 indicating the game should start
		call Clrscr
        ret
	line_BARHO:
	call VIEW_FILE
    ExitGame:
        invoke ExitProcess, 0    ; Exit the program

mainMenu ENDP

DRAW_BOX PROC
    ; Draw the top-left corner character
    mov dh, BOX_TOP_LEFT_X
    mov dl, BOX_TOP_LEFT_Y
    call gotoxy
    mov al, '+'
    call WriteChar

    ; Draw the top border
    mov ecx, 34
    L1:
        INC BOX_TOP_LEFT_Y
        mov dh, BOX_TOP_LEFT_X
        mov dl, BOX_TOP_LEFT_Y
        call gotoxy
        mov al, '-'
        call WriteChar
        LOOP L1

    ; Draw the top-right corner character
    mov al, '+'
    call WriteChar

    ; Draw the right border
    mov ecx, 10
    INC BOX_TOP_LEFT_Y
    L2:
        INC BOX_TOP_LEFT_X
        mov dh, BOX_TOP_LEFT_X
        mov dl, BOX_TOP_LEFT_Y
        call gotoxy
        mov al, '|'
        call WriteChar
        Loop L2

    ; Draw the bottom-right corner character
	call gotoxy
    mov al, '+'
    call WriteChar

    ; Draw the bottom border
    mov ecx, 35
   
    L3:
        DEC BOX_TOP_LEFT_Y
        mov dh, BOX_TOP_LEFT_X
        mov dl, BOX_TOP_LEFT_Y
        call gotoxy
        mov al, '-'
        call WriteChar
        LOOP L3

    ; Draw the bottom-left corner character
	 INC BOX_TOP_LEFT_Y
     call gotoxy
	 mov al, '+'
	 call WriteChar

    ; Draw the left border
    mov ecx, 9
    DEC BOX_TOP_LEFT_Y
    L4:
        DEC BOX_TOP_LEFT_X
        mov dh, BOX_TOP_LEFT_X
        mov dl, BOX_TOP_LEFT_Y
        call gotoxy
        mov al, '|'
        call WriteChar
        Loop L4

		ret

 DRAW_BOX ENDP

  

DRAW_LEFT_PADDLES PROC
	
	mov dh,PADDLE_LEFT_X
	mov dl,PADDLE_LEFT_Y

	mov ORIGINAL_PADDLE_LEFT_X,dh                
    mov ORIGINAL_PADDLE_LEFT_Y,dl 

	mov eax, BLUE
    call SetTextColor
	call gotoxy
	mov al, 0DBh
	call WRITEchar

	mov ecx,6
	L1:
		inc PADDLE_LEFT_X	
		mov dh,PADDLE_LEFT_X
		call gotoxy
		mov eax, BLUE
        call SetTextColor

		mov al, 0DBh
	    call WRITEchar
	Loop L1
	
	mov bl,ORIGINAL_PADDLE_LEFT_X
	mov PADDLE_LEFT_X,bl
	mov bl,ORIGINAL_PADDLE_LEFT_Y
	mov PADDLE_LEFT_Y,bl

ret
DRAW_LEFT_PADDLES ENDP

DRAW_RIGHT_PADDLES PROC

	mov dh,PADDLE_RIGHT_X
	mov dl,PADDLE_RIGHT_Y

	mov ORIGINAL_PADDLE_RIGHT_X,dh                
    mov ORIGINAL_PADDLE_RIGHT_Y,dl 

	mov eax, RED
    call SetTextColor
	call gotoxy
	mov al, 0DBh
	call WRITEchar

	mov ecx,6
	L1:
	mov al, 0DBh
		inc PADDLE_RIGHT_X	
		mov dh,PADDLE_RIGHT_X
		call gotoxy
		call writechar
		mov eax, RED
        call SetTextColor

		
	Loop L1

	mov bl,ORIGINAL_PADDLE_RIGHT_X
	mov PADDLE_RIGHT_X,bl
	mov bl,ORIGINAL_PADDLE_RIGHT_Y
	mov PADDLE_RIGHT_Y,bl

RET
DRAW_RIGHT_PADDLES ENDP


MOVE_PADDLES PROC

	call Readkey
	cmp al,'w'
	jz MOVE_LEFT_PADDLE_UP
	
	cmp al,'s'
	jz MOVE_LEFT_PADDLE_DOWN
	
	JMP CHECK_RIGHT_PADDLE_MOVEMENT

RET

MOVE_LEFT_PADDLE_DOWN:
	cmp val2,28
	jae quit

	inc PADDLE_LEFT_X
	mov dh,VAL1
	mov dl,1
	call gotoxy
	mov al, ' '
	call WRITEchar
	INC VAL1
	INC VAL2

	finish:

RET

MOVE_LEFT_PADDLE_UP:
	cmp VAL1,1
	jbe quit 
	
	dec PADDLE_LEFT_X
	mov dh,VAL2
	mov dl,1
	call gotoxy
	mov al, ' '
	call WRITEchar
	DEC VAL1
	DEC VAL2

quit:
jmp CHECK_RIGHT_PADDLE_MOVEMENT
RET

CHECK_RIGHT_PADDLE_MOVEMENT:

	cmp al,'o'
	je MOVE_RIGHT_PADDLE_UP

	cmp al,'l'
	je MOVE_RIGHT_PADDLE_DOWN
	jmp EXIT_PADDLE_MOVEMENT

RET

MOVE_RIGHT_PADDLE_DOWN:

	cmp val4,28
	jae EXIT_PADDLE_MOVEMENT 

	inc PADDLE_RIGHT_X
	mov dh,VAL3
	mov dl,77
	call gotoxy
	mov al, ' '
	call WRITEchar
	INC VAL3
	INC VAL4
RET

MOVE_RIGHT_PADDLE_UP:

	cmp VAL3,1
	jbe EXIT_PADDLE_MOVEMENT 
	dec PADDLE_RIGHT_X
	mov dh,VAL4
	mov dl,77
	call gotoxy
	mov al, ' '
	call WRITEchar
	DEC VAL3
	DEC VAL4

EXIT_PADDLE_MOVEMENT:
RET
MOVE_PADDLES ENDP

DRAW_BALL PROC

	mov dh,BALL_X
	mov dl,BALL_Y
	call gotoxy
	mov eax, WHITE
    call SetTextColor
	mov al,'O'
	call writeChar
		
RET
DRAW_BALL ENDP


CLEAR_SCREEN PROC

	mov eax, 90
	call delay
	inc COUNT
	mov dh,BALL_X
	mov dl,BALL_Y
	call gotoxy
	mov al,' '
	call writeCHar

RET
CLEAR_SCREEN ENDP

MOVE_BALL PROC

	mov ah,BALL_VELOCITY_X    
	add BALL_X,ah
	
	cmp BALL_X,0
	jbe NEG_VELOCITY_X
	
	cmp BALL_X,29
	jae NEG_VELOCITY_X  
	
	mov al,BALL_VELOCITY_Y    
	add BALL_Y,al
	
	cmp BALL_Y,0
	jbe RESET_POSITION
	
	cmp BALL_Y,78
	jae RESET_POSITION 
	
	CMP BALL_Y,76
	jne CHECK_COLLISION_WITH_LEFT_PADDLE
	mov eax,0
	mov ebx,0

	mov al,BALL_X
	mov bl,PADDLE_RIGHT_X

	cmp BALL_X,bl
	jae RIGHT_PADDLE_COLLIDE_CHECKER

	jmp CHECK_COLLISION_WITH_LEFT_PADDLE

	RIGHT_PADDLE_COLLIDE_CHECKER:
	add bl,7
	cmp BALL_X,bl
	jbe NEG_VELOCITY_Y

	CHECK_COLLISION_WITH_LEFT_PADDLE:

	CMP BALL_Y,2
	jne EXIT_COLLISION_CHECK 
	mov eax,0
	mov ebx,0

	mov al,BALL_X
	mov bl,PADDLE_LEFT_X

	cmp BALL_X,bl
	jae LEFT_PADDLE_COLLIDE_CHECKER

	jmp EXIT_COLLISION_CHECK 

	LEFT_PADDLE_COLLIDE_CHECKER:
	add bl,7
	cmp BALL_X,bl
	jbe NEG_VELOCITY_Y
	jmp EXIT_COLLISION_CHECK 

RET
	
	RESET_POSITION :
	call RESET_BALL_POS
RET
	
	NEG_VELOCITY_X:
	NEG BALL_VELOCITY_X
RET
	
	NEG_VELOCITY_Y:
	NEG BALL_VELOCITY_Y
	EXIT_COLLISION_CHECK:
RET

MOVE_BALL ENDP

RESET_BALL_POS PROC

cmp BALL_Y,0
jnz player1_scorecard
inc PLAYER2
cmp PLAYER2,2
jne INCREMENT
call GAME_OVER


jmp skip
player1_scorecard:
cmp BALL_Y,77
jb skip
INC PLAYER1
cmp PLAYER1,2
jne INCREMENT
call GAME_OVER
INCREMENT:
call DRAW_TEXT
skip:

	mov BALL_X,14
	mov BALL_Y,39
	mov dh,BALL_X
	mov dl,BALL_Y
	call gotoxy
	mov al,'O'
	call writeChar

RET
RESET_BALL_POS ENDP

DRAW_TEXT PROC

mov dh,12
mov dl,87
call Gotoxy
mov edx,OFFSET Player1_Score
mov eax, BLUE
call SetTextColor
call writeString

mov dh,14
mov dl,87
call Gotoxy

mov edx,OFFSET Player2_Score
mov eax, RED
call SetTextColor
call writeString

mov dh,12
mov dl,104
call Gotoxy
mov eax, WHITE
call SetTextColor
mov eax,0
mov al,PLAYER1
call writeDec


mov dh,14
mov dl,104
call Gotoxy
mov eax, WHITE
call SetTextColor
mov eax,0
mov al,PLAYER2
call writedec

RET
DRAW_TEXT ENDP


GAME_OVER PROC

call clrscr

MOV COUNT,0

RET
GAME_OVER ENDP


END main