IDEAL
MODEL small
STACK 100h

DATASEG
    ; most recent mouse click location
    currentX dw ?
    currentY dw ?

    ; first player selected in the turn
    chosenX dw ?
    chosenY dw ? 

    current_turn db 'b' ; 'b' => player's turn. 'r' => enemy's turn.

    color_selected db ? ; used to determine the color of the player the user clicked on. 
    ; The colors: {
    ;   blue: 'b',
    ;   red: 'r',
    ;   red queen: 'Q',
    ;   blue queen: 'q',
    ;   red player selected: 'S',
    ;   blue player selected: 's',
    ;   red queen selected: 'F',
    ;   blue queen selected: 'f',
    ;   blue double eat: 'd',
    ;   red double eat: 'D'
    ;}
    
    ; used to print all players on screen.
    xCounter dw ?
    yCounter dw ?

    
    counter dw 4
	
    ; Pictures:
    PlayerImage db 'player.bmp', 0
    EnemyImage db 'enemy.bmp', 0
    PlayerSelectedImage db 'playerb.bmp', 0
    EnemySelectedImage db 'enemyb.bmp', 0
    BoardImage db 'board.bmp', 0
    BlankSquareImage db 'black.bmp', 0
    StartImage db 'start.bmp', 0
    Player1WinImage db 'p1won.bmp', 0
    Player2WinImage db 'p2won.bmp', 0
    Instruction1Image db 'inst1.bmp', 0
    Instruction2Image db 'inst2.bmp', 0
    PlayerQueenImage db 'playerq.bmp', 0
    PlayerQueenSelectedImage db 'playeqs.bmp', 0
    EnemyQueenImage db 'enemyq.bmp', 0
    EnemyQueenSelectedImage db 'enemyqs.bmp', 0

    ; EQU Variables: 
    ; Player Colors:
    BLUE equ 0FCh
    RED equ 0F9h
    BLUE_QUEEN equ 67h
    RED_QUEEN equ 37h
    BLACK equ 0

    ; constants for true and false
    TRUE equ 1
    FALSE equ 0
    Clock equ es:6Ch ; used for the Tick procedure, for the delay between each click of the user
    ; Variables used for the CheckWin procedure.
    isRed db FALSE
    isBlue db FALSE
    ; Locations in the board (used to print players in correct rows and cols):
    Row_1_Y equ 2 
    Row_2_Y equ 27
    Row_3_Y equ 52
    Row_4_Y equ 77
    Row_5_Y equ 102
    Row_6_Y equ 127
    Row_7_Y equ 152
    Row_8_Y equ 177

    Col_1_X equ 10
    Col_2_X equ 50
    Col_3_X equ 90
    Col_4_X equ 130
    Col_5_X equ 170
    Col_6_X equ 210
    Col_7_X equ 250
    Col_8_X equ 290

    ; BMP STUFF
	BmpLeft dw ?
	BmpTop dw ?
	BmpColSize dw ?
	BmpRowSize dw ?
	 
CODESEG

include "Procs.asm" ; All BMP related procedures
include "Print.asm" ; All printing and showing images related procedures

; =======================================
; Procedure Name: Tick
; Params: None
; Description: Waits 0.5 seconds.
; =======================================
proc Tick 
    push ax es cx

    mov ax, 40h
    mov es, ax
    mov ax, [Clock]
@@FirstTick:
    cmp ax, [Clock]
    je @@FirstTick

    mov cx, 10 ; 10 * 0.055 = ~0.5
@@DelayLoop:
    mov ax, [Clock]
@@Tick:
    cmp ax, [Clock]
    je @@Tick
    loop @@DelayLoop

    pop cx es ax 
    ret
endp Tick

; =======================================
; Procedure Name: CheckWin
; Params: None
; Description: Procedure to check a if there is a winner. if there is a winner display a winner screen accordingly
; Returns:  RED WON => AX = 2
;           BLUE WON => AX = 1
;           NO WIN => AX = 0
; =======================================
proc CheckWin
    ; Checking all black columns for blue players. if it encounters a red player it exits the procedure. if it doesn't encounter red players
    ; it assumes the blue player won.

    mov [isRed], FALSE
    mov [isBlue], FALSE

    ; check all odd number rows (1, 3, 5, 7)
    mov [counter], 4 ; 4 odd numbers
    mov [currentX], 10
    mov [currentY], 2
@@Odd:
    push [counter]
    mov [counter], 8
    @@Col:
        mov bh, 0
        mov cx, [currentX]
        add cx, 10 ; get to center of column
        mov dx, [currentY]
        add dx, 6 ; get to center of column
        mov ah, 0Dh
        int 10h
        ; al = pixel that was read
        cmp al, BLUE
        je @@isBlue
        cmp al, RED
        je @@isRed
        jmp @@continue
    @@isBlue:
        mov [isBlue], TRUE
        jmp @@continue
    @@isRed:
        mov [isRed], TRUE
    @@continue:
        dec [counter]
        add [currentX], 40
        cmp [counter], 0
        jne @@Col
    pop [counter]
    dec [counter]
    mov [currentX], 10
    add [currentY], 50
    cmp [counter], 0
    jne @@Odd

    ; Rows 2, 4, 6, 8
    mov [counter], 4
    mov [currentX], 50
    mov [currentY], 2
@@Even:
    push [counter]
    mov [counter], 0
    @@Column:
        mov bh, 0
        mov cx, [currentX]
        add cx, 10 ; get to center of column
        mov dx, [currentY]
        add dx, 6 ; get to center of column
        mov ah, 0Dh
        int 10h
        ; al = pixel that was read
        cmp al, BLUE
        je @@isBlue2
        cmp al, RED
        je @@isRed2
        jmp @@continue2
    @@isBlue2:
        mov [isBlue], TRUE
        jmp @@continue2
    @@isRed2:
        mov [isRed], TRUE
    @@continue2:
        dec [counter]
        add [currentX], 40
        cmp [counter], 0
        jne @@Column
    pop [counter]
    dec [counter]
    mov [currentX], 50
    add [currentY], 50
    cmp [counter], 0
    jne @@Even

    mov al, [isBlue]
    ; cmp al, [isRed]
    test al, [isRed]
    jnz @@NoWin

    cmp [isRed], TRUE ; 1
    je @@RedWin

    cmp [isBlue], TRUE ; 1
    je @@BlueWin

    jmp @@NoWin

    ; RED WON => AX = 2
    ; BLUE WON => AX = 1
    ; NO WIN => AX = 0
@@RedWin:
    mov ax, 2
    ret 
@@BlueWin:
    mov ax, 1
    ret
@@NoWin:
    mov ax, 0
    ret
endp CheckWin

; =======================================
; Procedure Name: GetMouseInput
; Params: None
; Description: Gets the mouse position in perspective of the board.
; Returns:  1. pressed column & row x and y in variables currentX and currentY. For example the player clicked on the 3rd column, it will return 90 in the currentX variable
;           2. al = the color of the player the mouse clicked on (not actual number but a char).
; =======================================
proc GetMouseInput
@@WaitForPress:
    mov ax, 3h ; wait for mouse press
    int 33h
    cmp bx, 1
    jne @@WaitForPress
    shr cx, 1 ; adjust cx to range 0-319
    ; CX = MOUSE PRESS X
    ; DX = MOUSE PRESS Y
    
    ; GETTING COLUMN
    push dx ; save value of Y. currently working on X
    xor dx, dx ; DIV CX => DX:AX / CX
    mov ax, cx ; i want to div cx by 40 (40 = width of a column in the board)
    mov cx, 40
    div cx
    ; cmp ax, 0 ; if ax / cx = 0 => there is a remainder but we don't want to add 1 because the column is the first one (0)
    ; je @@continueX
@@continueX:
    mov [currentX], ax

    ; NOW GETTING THE ROW
    pop dx ; we pushed it on line 241 to save value because we changed DX's value
    mov cx, dx ; the div function uses DX so just like before i'm using CX instead of DX.
    xor dx, dx
    mov ax, cx ; 200px / 8rows = 25
    mov cx, 25
    div cx
    cmp ax, 0
    je @@continueY
@@continueY:
    mov [currentY], ax

    mov ax, 40
    mul [currentX]
    ; DX:AX = AX * currentX. we don't need DX because the result will never be more than 2 bytes long.
    add ax, 10 ; we start drawing in the column from the 10th pixel inside of it
    mov [currentX], ax

    mov ax, 25
    mul [currentY]
    add ax, 2
    mov [currentY], ax

    mov bh, 0
    mov cx, [currentX] 
    add cx, 10 ; center of image
    mov dx, [currentY]
    add dx, 6 ; center of image
    mov ah, 0Dh
    int 10h
    cmp al, RED
    je @@red
    cmp al, BLUE
    je @@blue
    cmp al, RED_QUEEN
    je @@RedQueen
    cmp al, BLUE_QUEEN
    je @@BlueQueen
    mov al, 'n' ; null. color that we are not interested in. here i use 2 "if" statements because if it's not blue AND not red i want it have a different value.
    jmp @@ExitProc
@@RedQueen:
    mov al, 'Q'
    jmp @@ExitProc
@@BlueQueen:
    mov al, 'q'
    jmp @@ExitProc
@@blue:
    mov al, 'b'
    jmp @@ExitProc
@@red:
    mov al, 'r' ; red
    jmp @@ExitProc
@@ExitProc:
    ret
endp GetMouseInput

; =======================================
; Procedure Name: StartScreen
; Params: None
; Description: Displays start screen and instructions screen until player presses the enter key, then starts the game.
; =======================================
proc StartScreen
    mov [BmpLeft], 0
    mov [BmpTop], 0
    mov [BmpColSize], 320
    mov [BmpRowSize], 200
    mov dx, offset StartImage
    call OpenShowBmp
@@WaitForKey: 
    mov ah, 1
    int 16h
    jz @@WaitForKey
    mov ah, 0
    int 16h
    cmp ah, 1Ch ; enter
    je @@ExitStart
    cmp ah, 17h ; I key
    je @@Instruction1
    cmp ah, 1
    je @@ExitProc
    jmp @@WaitForKey ; if none of the recognized keys was clicked, check for another input
    
@@Instruction1:
    mov [BmpLeft], 0
    mov [BmpTop], 0
    mov [BmpColSize], 320
    mov [BmpRowSize], 200
    mov dx, offset Instruction1Image
    call OpenShowBmp
@@WaitInst1:
    mov ah, 1
    int 16h
    jz @@WaitInst1
    mov ah, 0
    int 16h
    cmp ah, 4Dh ; right arrow => next page
    je @@Instruction2
    cmp ah, 1Ch ; enter => start game
    je @@ExitStart
    cmp ah, 1 ; esc => exit
    je @@ExitProc
    jmp @@WaitInst1 ; if none of the recognized keys was clicked, check for another input

@@Instruction2:
    mov [BmpLeft], 0
    mov [BmpTop], 0
    mov [BmpColSize], 320
    mov [BmpRowSize], 200
    mov dx, offset Instruction2Image
    call OpenShowBmp
@@WaitInst2:
    mov ah, 1
    int 16h
    jz @@WaitInst2
    mov ah, 0
    int 16h
    cmp ah, 4Bh ; left arrow
    je @@Instruction1
    cmp ah, 1Ch ; enter => start game
    je @@ExitStart
    cmp ah, 1 ; esc => exit
    je @@ExitProc
    jmp @@WaitInst2 ; if none of the recognized keys was clicked, check for another input

@@ExitStart: ; exit procedure and start game
    mov ax, 1
    jmp @@Return

@@ExitProc: ; exit procedure and exit game
    mov ax, 0 
    jmp @@Return

@@Return:
    ret
endp StartScreen

; =======================================
; Procedure Name: CheckMove
; =======================================
; CHECK IF MOVE WAS VALID
proc CheckMove
    ; check if clicked on same position
    mov ax, [chosenX]
    cmp ax, [currentX]
    je @@JmpToExitProc
    mov ax, [chosenY]
    cmp ax, [currentY]
    je @@JmpToExitProc

    ; BLUE CAN ONLY MOVE UP. RED CAN ONLY MOVE DOWN. QUEENS CAN MOVE ANYWHERE
    cmp [color_selected], 'b'
    je @@CheckForBlue
    cmp [color_selected], 'r'
    je @@CheckForRed
    cmp [color_selected], 'q'
    je @@CheckForQueen
    cmp [color_selected], 'Q'
    je @@CheckForQueen
@@CheckForBlue:
    ; Check if the move was according to the rules
    mov ax, [chosenY] ; y that got clicked now (the location the player wants to go to)
    ; i want to check if the Y selected is in range. a player can only go one row forward or one row backwards
    sub ax, 25 ; checking if in row above
    cmp ax, [currentY]
    jne @@JmpToExitProc
    jmp @@CheckForAll
@@CheckForRed:
    ; Check if the move was according to the rules
    mov ax, [chosenY]
    add ax, 25 ; checking if in row below
    cmp ax, [currentY]
    jne @@JmpToExitProc
    jmp @@CheckForAll   
@@CheckForQueen:
    call CheckSquareDifferences ; ax = x square diff. bx = y square diff
    ; only if x square diff and y square diff are equal the queen can move, because she can only move in a diagonal line.
    cmp al, bl
    jne @@JmpToExitProc
    jmp @@CheckEat ; not going to @@CheckForAll because it checks the x rule for red and blue players, and queens have different rules.

@@JmpToExitProc:
    jmp @@ExitProc

@@CheckForAll: ; the x rule in both players is the same (player/enemy can move one square right/left)
    mov ax, [chosenX]
    sub ax, 40
    cmp ax, [currentX]
    je @@CheckEat
    mov ax, [chosenX]
    add ax, 40
    cmp ax, [currentX]
    je @@CheckEat
    jmp @@ExitProc

@@JmpToCanMove:
    jmp @@CanMove

@@CheckEat:
    call CheckEat
    cmp ax, 1 ; player can move
    je @@JmpToCanMove 
    cmp ax, 0 ; player can't move
    je @@JmpToExitProc
    cmp ax, 2 ; player ate
    je @@CheckAnotherEat
    jmp @@ExitProc

@@CheckAnotherEat:
    ; when double-eating in checkers the player can eat up and down and his color doesn't matter. so i call the player 'd' (blue) or 'D' (red)
    ; to indicate that it can move like a queen (can eat up and down).
    cmp [color_selected], 'r'
    je @@TurnToRedQueen 
    cmp [color_selected], 'b'
    je @@TurnToBlueQueen
    jmp @@Continue
    
@@TurnToBlueQueen:
    mov [color_selected], 'd'
    jmp @@Continue
@@TurnToRedQueen:
    mov [color_selected], 'D'
    jmp @@Continue
@@Continue:
    call Tick
    
    ; cannot eat again if the player is on the edges of the board
    cmp [currentX], 10
    je @@JmpToExitEat
    cmp [currentX], 290
    je @@JmpToExitEat
    cmp [currentY], 2
    je @@JmpToExitEat
    cmp [currentY], 177
    je @@JmpToExitEat

    ; move chosenX and chosenY to currentX and currentY, and change the currentX and currentY to check double eat.
    mov ax, [currentX]
    mov [chosenX], ax
    mov ax, [currentY]
    mov [chosenY], ax
    add [currentY], 25
    add [currentX], 40 ; check right down
    call CheckEat
    cmp ax, 2
    je @@EatAgain
    ; player didn't eat, checking another eating scenario
    sub [currentX], 80 ; check left down
    call CheckEat
    cmp ax, 2
    je @@EatAgain
    ; player didn't eat, checking another eating scenario
    sub [currentY], 50 ; check left up
    call CheckEat
    cmp ax, 2
    je @@EatAgain
    add [currentX], 80 ; check right up
    call CheckEat
    cmp ax, 2
    je @@EatAgain
    ; if code gets here it means there is no double eat. only a single eat.
    jmp @@JmpToExitEat

@@JmpToExitEat:
    jmp @@ExitEat

@@EatAgain:
    ; revert 'd' to 'b' and 'D' to 'r'
    cmp [color_selected], 'd'
    je @@RevertBlue
    cmp [color_selected], 'D'
    je @@RevertRed
    jmp @@ExitEat
@@RevertBlue:
    mov [color_selected], 'b'
    jmp @@ExitEat
@@RevertRed:
    mov [color_selected], 'r'
    jmp @@ExitEat

@@ExitEat:
    mov ax, 2
    ret
    ; IF CAN'T MOVE => AX = 0 (DON'T COLOR A NEW PLAYER AND RE-COLOR THE CURRENT ONE (SO IT WON'T BE SELECTED))
    ; IF CAN MOVE => AX = 1 (DELETE THE CURRENT PLAYER AND COLOR THE PLAYER IN THE DESIRED LOCATION)
    ; CAN EAT => AX = 2 (DON'T DO ANYTHING IN THE MAIN FUNCTION. ALL EAT LOGIC ALREADY HANDLED)

@@CanMove:
    ; Hide the mouse cursor. So that the mouse will not hide the player and he will be able to be full.
    mov ax, 2
    int 33h

    push [currentY]
    push [currentX]
    call PrintPlayer ; print player selected

    push [chosenX]
    push [chosenY]
    call DeletePlayer 

    ; Return the cursor
    mov ax, 1
    int 33h

    
    mov ax, 1
    ret

@@ExitProc:
    mov ax, 2 ; hide cursor
    int 33h
    ; delete the selected picture
    push [chosenX]
    push [chosenY]
    call DeletePlayer
    ; print the un-selected picture (player stays in same position)
    push [chosenY] ; reminder = chosen is the first selected spot
    push [chosenX]
    call PrintPlayer
    mov ax, 1 ; return cursor
    int 33h
    mov ax, 0 
    ret
endp CheckMove


; uses [currentX], [currentY], [chosenX], [chosenY], [color_selected]
proc CheckEat
    mov cx, [currentX]
    add cx, 10
    mov dx, [currentY]
    add dx, 6
    mov bh, 0
    mov ah, 0Dh
    int 10h
    cmp al, BLACK
    je @@CanMove
    cmp al, RED
    je @@red
    cmp al, BLUE
    je @@blue
    cmp al, RED_QUEEN
    je @@red
    cmp al, BLUE_QUEEN
    je @@blue
    jmp @@ExitProc ; if it's none of these colors (something that should not happen.)

@@CanMove:
    mov ax, 1
    ret

@@blue:
    cmp [color_selected], 'b' ; blue player can't eat blue player
    je @@JmpToExitProc
    cmp [color_selected], 'q' ; blue queen can't eat blue player
    je @@JmpToExitProc
    cmp [color_selected], 'd' ; blue player can't eat blue player
    je @@JmpToExitProc
    jmp @@CheckForBlankSquare ; if i get to this line it means that the player that moved is red/red queen and the player selected is blue
@@red:
    cmp [color_selected], 'r' ; red player can't eat red player
    je @@JmpToExitProc
    cmp [color_selected], 'Q' ; red queen can't eat red player
    je @@JmpToExitProc
    cmp [color_selected], 'D' ; red player can't eat red player
    je @@JmpToExitProc
    jmp @@CheckForBlankSquare ; if i get to this line it means that the player that moved is blue/blue queen and the player selected is red

@@JmpToExitProc:
    jmp @@ExitProc

@@CheckForBlankSquare:
    ; CAN'T EAT ON THE EDGES
    cmp [currentX], 10
    je @@JmpToExitProc
    cmp [currentX], 290
    je @@JmpToExitProc
    cmp [currentY], 2
    je @@JmpToExitProc
    cmp [currentY], 177
    je @@JmpToExitProc

    cmp [color_selected], 'b'
    je @@CheckBlankSquare_Blue
    cmp [color_selected], 'q'
    je @@JmpToCheckBlankSquare_Queen
    cmp [color_selected], 'Q'
    je @@JmpToCheckBlankSquare_Queen
    cmp [color_selected], 'd'
    je @@JmpToCheckBlankSquare_Queen
    cmp [color_selected], 'D'
    je @@JmpToCheckBlankSquare_Queen
    jmp @@CheckBlankSquare_Red


@@CheckBlankSquare_Blue:
    mov ax, [currentY]
    cmp ax, 2 ; first row. blue player cannot eat someone on the first row because there is no squares behind it
    je @@JmpToExitProc2
    mov ax, [chosenX]
    cmp [currentX], ax
    jb @@CheckLeft_Blue ; player moved left. check the left square if blank.
    jmp @@CheckRight_Blue ; player moved right. check the right square

@@CheckLeft_Blue:
    push -25
    push -40
    call CheckBlankSquare
    ; ax = 1 => blank square
    ; ax = 0 => not blank
    cmp ax, 1 ; black
    je @@JmpToCanEatLeftUp
    jmp @@ExitProc
@@CheckRight_Blue:
    push -25
    push 40
    call CheckBlankSquare
    cmp ax, 1
    je @@JmpToCanEatRightUp
    jmp @@ExitProc

@@JmpToCheckBlankSquare_Queen:
    jmp @@CheckBlankSquare_Queen

@@JmpToExitProc2:
    jmp @@ExitProc

@@JmpToCanEatLeftUp:
    jmp @@CanEatLeftUp
@@JmpToCanEatRightUp:
    jmp @@CanEatRightUp

@@CheckBlankSquare_Red:
    mov ax, [currentY]
    cmp ax, 177 ; square at the bottom. a red player cannot eat someone that is in the bottom square, because there is no squares behind it.
    je @@JmpToExitProc2
    mov ax, [chosenX]
    cmp [currentX], ax
    jb @@CheckLeft_Red ; player moved left. check the left square if blank.
    jmp @@CheckRight_Red ; player moved right. check the right square

@@CheckLeft_Red:
    push 25
    push -40
    call CheckBlankSquare
    cmp ax, 1 ; black
    je @@JmpToCanEatLeftDown
    jmp @@ExitProc

@@CheckRight_Red:
    push 25
    push 40
    call CheckBlankSquare
    cmp ax, 1
    je @@JmpToCanEatRightDown
    jmp @@ExitProc

@@CheckBlankSquare_Queen:
    cmp [currentY], 177
    je @@JmpToExitProc3
    cmp [currentY], 2
    je @@JmpToExitProc3

    mov ax, [chosenX]
    cmp [currentX], ax
    jb @@CheckLeft_BlueQueen ; player moved left
    jmp @@CheckRight_BlueQueen ; player moved right

@@CheckLeft_BlueQueen:
    mov ax, [chosenY]
    cmp [currentY], ax
    jb @@CheckLeftUp_BlueQueen
    ; now we check for down
    push 25
    push -40
    call CheckBlankSquare
    cmp ax, 1 ; blank square 
    je @@CanEatLeftDown
    jmp @@ExitProc

@@JmpToCanEatLeftDown:
    jmp @@CanEatLeftDown

@@CheckLeftUp_BlueQueen:
    push -25
    push -40
    call CheckBlankSquare
    cmp ax, 1
    je @@CanEatLeftUp
    jmp @@ExitProc

@@JmpToCanEatRightDown:
    jmp @@CanEatRightDown

@@JmpToExitProc3:
    jmp @@ExitProc


@@CanEatLeftUp:   
    mov ax, 2
    int 33h
    push [chosenX]
    push [chosenY]
    call DeletePlayer
    push [currentX]
    push [currentY]
    call DeletePlayer
    sub [currentX], 40
    sub [currentY], 25
    push [currentY]
    push [currentX]
    call PrintPlayer
    mov ax, 1
    int 33h
    mov ax, 2
    ret
@@CanEatLeftDown:
    mov ax, 2
    int 33h
    push [chosenX]
    push [chosenY]
    call DeletePlayer
    push [currentX]
    push [currentY]
    call DeletePlayer
    sub [currentX], 40
    add [currentY], 25
    push [currentY]
    push [currentX]
    call PrintPlayer
    mov ax, 1
    int 33h
    mov ax, 2
    ret

; =======================

@@CheckRight_BlueQueen:
    mov ax, [chosenY]
    cmp ax, [currentY]
    ja @@CheckRightUp
    ; now we check for down
    push 25
    push 40
    call CheckBlankSquare
    cmp ax, 1 ; blank square 
    je @@CanEatRightDown
    jmp @@ExitProc

@@CheckRightUp:
    push -25
    push 40
    call CheckBlankSquare
    cmp ax, 1
    je @@CanEatRightUp
    jmp @@ExitProc

@@CanEatRightUp:   
    mov ax, 2
    int 33h
    push [chosenX]
    push [chosenY]
    call DeletePlayer
    push [currentX]
    push [currentY]
    call DeletePlayer
    add [currentX], 40
    sub [currentY], 25
    push [currentY]
    push [currentX]
    call PrintPlayer
    mov ax, 1
    int 33h
    mov ax, 2
    ret
@@CanEatRightDown:
    mov ax, 2
    int 33h
    push [chosenX]
    push [chosenY]
    call DeletePlayer
    push [currentX]
    push [currentY]
    call DeletePlayer
    add [currentX], 40
    add [currentY], 25
    push [currentY]
    push [currentX]
    call PrintPlayer
    mov ax, 1
    int 33h
    mov ax, 2
    ret

@@ExitProc:
    mov ax, 0
    ret
endp CheckEat



; return ax = x square diff. bx = y square diff
proc CheckSquareDifferences
@@CheckXMax:
    mov ax, [currentX]
    cmp ax, [chosenX]
    ja @@CurrentXBigger
    mov ax, [chosenX]
    jmp @@ChosenXBigger

@@CurrentXBigger:
    ; ax = max (currentX)
    sub ax, [chosenX]
    ; ax = currentX - chosenX
    jmp @@CheckYMax

@@ChosenXBigger:
    ; ax = max (chosenX)
    sub ax, [currentX]
    ; ax = chosenX - currentX
    jmp @@CheckYMax

@@CheckYMax:
    mov bx, [currentY]
    cmp bx, [chosenY]
    ja @@CurrentYBigger
    mov bx, [chosenY]
    jmp @@ChosenYBigger

@@CurrentYBigger:
    ; bx = max (currentY)
    sub bx, [chosenY]
    ; bx = currentY - chosenY
    jmp @@ExitProc

@@ChosenYBigger:
    ; bx = max (chosenY)
    sub bx, [currentY]
    ; bx = chosenY - currentY

@@ExitProc:
    ; dividing the x(ax) by 40 (evey square is 40 px wide) so that we get the square differences, not pixel differences.
    mov dl, 40
    div dl ; al = ax(x diff) / 40
    mov cl, al ; moving the x diff to cl so that we can do another div without losing the x diff.
    ; dividing the y(bx) by 25 (evey square is 25 px tall) so that we get the square differences, not pixel differences.
    mov dl, 25 
    mov ax, bx ; moving the y diff (in pixels) to ax (div works with ax)
    div dl ; al = ax(y diff) / 25

    mov bl, al ; bl = y diff in squares
    mov al, cl ; al = x diff in squares ( we saved it in cl a few lines above )

    ret
endp CheckSquareDifferences

; ============================ 
; checks for blank square => returns ax = 1 if it is a blank square, and ax = 0 if it is not a blank space.
; works with the [currentX] and [currentY] variables and receives 2 parameters to add/subtract from the variables.
; for example if it received first parameter 40 it means to go 40 pixels right (check the square to the right of the place clicked).
; can also work with numbers below zero because it adds them. for example if it receives -40 it will subtract 40 from the [currentX]
proc CheckBlankSquare
    push bp
    mov bp, sp

    ; [BP + 4] => X TO ADD/SUBTRACT FROM THE CURRENTX 
    ; [BP + 6] => Y TO ADD/SUBTRACT FROM THE CURRENTY

    mov cx, [currentX]
    add cx, [bp + 4] ; x param
    add cx, 10 ; middle of square
    mov dx, [currentY]
    add dx, [bp + 6] ; y param
    add dx, 6 ; middle of square
    mov bh, 0
    mov ah, 0Dh
    int 10h

    cmp al, BLACK
    je @@isBlack
    ; not black
    mov ax, 0
    pop bp
    ret 4

@@isBlack:
    mov ax, 1
    pop bp 
    ret 4
endp CheckBlankSquare

proc SwitchTurns
    cmp [current_turn], 'b'
    je @@SwitchToRed
    cmp [current_turn], 'q'
    je @@SwitchToRed
    mov [current_turn], 'b'
    ret

@@SwitchToRed:
    mov [current_turn], 'r'

    ret
endp SwitchTurns

proc CheckForQueens
    mov [counter], 4
    mov [currentX], 10 ; first element in row
    mov [currentY], 2
    ; FIRST ROW
@@firstrow:
    mov cx, [currentX]
    add cx, 10
    mov dx, [currentY]
    add dx, 6
    mov bh, 0
    mov ah, 0Dh
    int 10h 
    cmp al, BLUE
    je @@MakePlayerQueen
@@ContinueLoop1:
    dec [counter]
    add [currentX], 80
    cmp [counter], 0
    jnz @@firstrow
    
    ; last row
    mov [counter], 4
    mov [currentX], 50
    add [currentY], 177
@@firstrow2:
    mov cx, [currentX]
    add cx, 10
    mov dx, [currentY]
    add dx, 6
    mov bh, 0
    mov ah, 0Dh
    int 10h
    
    cmp al, RED
    je @@MakeEnemyQueen
@@ContinueLoop2:
    dec [counter]
    add [currentX], 80
    cmp [counter], 0
    jnz @@firstrow2
    ret
@@MakePlayerQueen:
    mov ax, 2
    int 33h
    mov [color_selected], 'q' ; player queen
    push [currentY]
    push [currentX]
    call PrintPlayer
    mov [color_selected], 'b'
    mov ax, 1
    int 33h
    jmp @@ContinueLoop1
@@MakeEnemyQueen:
    mov ax, 2
    int 33h
    mov [color_selected], 'Q' ; enemy queen
    push [currentY]
    push [currentX]
    call PrintPlayer
    mov [color_selected], 'r'
    mov ax, 1
    int 33h
    jmp @@ContinueLoop2
endp CheckForQueens
   
proc SetGraphic
	mov ax,13h   ; 320 X 200 
	;Mode 13h is an IBM VGA BIOS mode. It is the specific standard 256-color mode 
	int 10h
	ret
endp SetGraphic 
start:
	mov ax, @data
	mov ds, ax
	
	call SetGraphic

@@Game_Start:

    call StartScreen

    cmp ax, 0
    je @@JmpToExit


    mov [BmpLeft], 0
    mov [BmpTop], 0
    mov [BmpColSize], 320
    mov [BmpRowSize], 200
    mov dx, offset BoardImage
    call OpenShowBmp

    call PrintPlayers
    
    ; 37H = RED QUEEN
    ; 67H = BLUE QUEEN

    ; MOUSE SETUP
    mov ax, 0
    int 33h 
    mov ax, 1
    int 33h
    jmp @@GetInput
@@JmpToExit:
    jmp exit
@@GetInput:
    ; wait 1 seconds before doing the next procedure. they are called so fast so what happens is the last mouse click counts as the future one.
    call Tick

    call GetMouseInput
    mov [color_selected], al

    ; al -color selected
    cmp al, [current_turn]
    je @@CanMove
    jmp @@CheckQueens

@@CheckQueens:
    cmp [current_turn], 'b'
    je @@CheckBlueQueen
    cmp [current_turn], 'r'
    je @@CheckRedQueen
    jmp @@GetInput

@@CheckRedQueen:
    cmp [color_selected], 'Q' ; current turn is red && color selected is queen red => can move.
    je @@CanMove
    jmp @@GetInput
@@CheckBlueQueen:
    cmp [color_selected], 'q' ; current turn is blue && color selected is queen blue => can move.
    je @@CanMove
    jmp @@GetInput

@@CanMove:
    ; print the selected bmp file according to player selected:
    mov ax, 2
    int 33h    

    call PrintSelected

    mov ax, 1
    int 33h
    
    ; Put currentX in chosenX and currentY in chosenY
    mov ax, [currentX]
    mov [chosenX], ax
    mov ax, [currentY]
    mov [chosenY], ax

    ; wait 0.5 seconds before doing the next procedure. they are called so fast so what happens is the last mouse click counts as the future one.
    call Tick

    call GetMouseInput
    
    call CheckMove
    cmp ax, 0
    je @@GetInput
    ; here ax != 0, means that the move is valid and the CheckMove procedure already moved the player
    
    call CheckForQueens

    call SwitchTurns

    call CheckWin
    jmp @@ContinueCheckWin ; skip the jump to game start, it is a jump to prevent an error

@@JmpToGameStart:
    jmp @@Game_Start

@@ContinueCheckWin:
    cmp ax, 2
    je @@RedWin
    cmp ax, 1
    je @@BlueWin

    jmp @@GetInput

@@RedWin:
    mov ax, 2
    int 33h
    mov [BmpLeft], 0
    mov [BmpTop], 0
    mov [BmpColSize], 320
    mov [BmpRowSize], 200
    mov dx, offset Player2WinImage
    call OpenShowBmp
    mov ax, 1
    int 33h
@@Wait_Red:
    mov ah, 0 ; ah = 1 didn't work for some reason
    int 16h
    jz @@Wait_Red
    mov ah, 1
    int 16
    cmp ah, 1 ; ESC
    je exit
    jmp @@Wait_Red

@@BlueWin:
    mov ax, 2
    int 33h
    mov [BmpLeft], 0
    mov [BmpTop], 0
    mov [BmpColSize], 320
    mov [BmpRowSize], 200
    mov dx, offset Player1WinImage
    call OpenShowBmp
    mov ax, 1
    int 33h
@@Wait_Blue:
    mov ah, 0 ; ah = 1 didn't work for some reason
    int 16h
    jz @@Wait_Blue
    mov ah, 1
    int 16
    cmp ah, 1 ; ESC
    je exit
    jmp @@Wait_Blue

    ; no error handling right now
exit:
	mov ax,2
	int 10h
	
	mov ax, 4c00h
	int 21h
 
END start