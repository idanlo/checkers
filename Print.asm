; ALL PRINTING RELATED PROCEDURES
proc PrintPlayers
    mov [BmpColSize], 20
    mov [BmpRowSize], 20

    ;ENEMIES
    mov [xCounter], 10 ; first element in row
    mov [yCounter], 2
    ; FIRST ROW
@@firstrow:
    mov ax, [xCounter]
    mov [BmpLeft], ax
    mov ax, [yCounter]
    mov [BmpTop], ax
    mov dx, offset EnemyImage
    call OpenShowBmp
    dec [counter]
    add [xCounter], 80
    cmp [counter], 0
    jnz @@firstrow

    mov [counter], 4
    mov [xCounter], 50
    mov [yCounter], 27
@@secondrow:
    mov ax, [xCounter]
    mov [BmpLeft], ax
    mov ax, [yCounter]
    mov [BmpTop], ax
    mov dx, offset EnemyImage
    call OpenShowBmp
    dec [counter]
    add [xCounter], 80
    cmp [counter], 0
    jnz @@secondrow

    ; third row
    mov [counter], 4
    mov [xCounter], 10
    mov [yCounter], 52
@@thirdrow:
    mov ax, [xCounter]
    mov [BmpLeft], ax
    mov ax, [yCounter]
    mov [BmpTop], ax
    mov dx, offset EnemyImage
    call OpenShowBmp
    dec [counter]
    add [xCounter], 80
    cmp [counter], 0
    jnz @@thirdrow

    ; ALLIES
    ; third row
    mov [counter], 4
    mov [xCounter], 50
    mov [yCounter], 127
@@thirdrow2:
    mov ax, [xCounter]
    mov [BmpLeft], ax
    mov ax, [yCounter]
    mov [BmpTop], ax
    mov dx, offset PlayerImage
    call OpenShowBmp
    dec [counter]
    add [xCounter], 80
    cmp [counter], 0
    jnz @@thirdrow2

    ; second row
    mov [counter], 4
    mov [xCounter], 10
    add [yCounter], 25
@@secondrow2:
    mov ax, [xCounter]
    mov [BmpLeft], ax
    mov ax, [yCounter]
    mov [BmpTop], ax
    mov dx, offset PlayerImage
    call OpenShowBmp
    dec [counter]
    add [xCounter], 80
    cmp [counter], 0
    jnz @@secondrow2

    ; first row
    mov [counter], 4
    mov [xCounter], 50
    add [yCounter], 25
@@firstrow2:
    mov ax, [xCounter]
    mov [BmpLeft], ax
    mov ax, [yCounter]
    mov [BmpTop], ax
    mov dx, offset PlayerImage
    call OpenShowBmp
    dec [counter]
    add [xCounter], 80
    cmp [counter], 0
    jnz @@firstrow2


    ret
endp PrintPlayers

proc PrintPlayer 
    push bp
    mov bp, sp
    mov ax, [bp + 4]
    mov [BmpLeft], ax
    mov ax, [bp + 6]
    mov [BmpTop], ax
    mov [BmpColSize], 20
    mov [BmpRowSize], 20

    cmp [color_selected], 'b'
    je @@PrintPlayer
    cmp [color_selected], 'r'
    je @@PrintEnemy
    cmp [color_selected], 's' ; s is selected player. and S (capital) is selected enemy
    je @@PrintSelectedPlayer
    cmp [color_selected], 'S' ; selected enemy
    je @@PrintSelectedEnemy
    cmp [color_selected], 'q' ; q is player queen. and Q is enemy queen
    je @@PrintPlayerQueen
    cmp [color_selected], 'Q' ; enemy queen
    je @@PrintEnemyQueen
    cmp [color_selected], 'f' ; f is selected player queen. and F is selected enemy queen
    je @@PrintSelectedPlayerQueen
    cmp [color_selected], 'F' ; enemy selected queen
    je @@PrintSelectedEnemyQueen
    cmp [color_selected], 'd' ; player
    je @@PrintPlayer
    cmp [color_selected], 'D' ; enemy
    je @@PrintEnemy
    ; code shouldn't get here
    jmp @@Finish

@@PrintPlayer:
    mov dx, offset PlayerImage
    call OpenShowBmp
    jmp @@Finish
@@PrintSelectedEnemy:
    mov dx, offset EnemySelectedImage
    call OpenShowBmp
    jmp @@Finish
@@PrintSelectedPlayer:
    mov dx, offset PlayerSelectedImage
    call OpenShowBmp
    jmp @@Finish
@@PrintEnemy:
    mov dx, offset EnemyImage
    call OpenShowBmp
    jmp @@Finish
@@PrintSelectedEnemyQueen:
    mov dx, offset EnemyQueenSelectedImage
    call OpenShowBmp
    jmp @@Finish
@@PrintSelectedPlayerQueen:
    mov dx, offset PlayerQueenSelectedImage
    call OpenShowBmp
    jmp @@Finish
@@PrintPlayerQueen:
    mov dx, offset PlayerQueenImage
    call OpenShowBmp
    jmp @@Finish
@@PrintEnemyQueen:
    mov dx, offset EnemyQueenImage
    call OpenShowBmp

@@Finish:
    pop bp
    ret 4
endp PrintPlayer

; ========================
; PARAMS = 1. Starting X location. 2. Starting Y Location
; ========================
proc DeletePlayer
    push bp
    mov bp, sp

    mov ax, [bp + 6] ; X
    mov [BmpLeft], ax
    mov ax, [bp + 4] ; Y
    mov [BmpTop], ax
    mov [BmpColSize], 20
    mov [BmpRowSize], 20
    mov dx, offset BlankSquareImage
    call OpenShowBmp
    
    pop bp
    ret 4
endp DeletePlayer

proc PrintSelected
    cmp [color_selected], 'r'
    je @@PrintSelectedEnemy
    cmp [color_selected], 'b'
    je @@PrintSelectedPlayer
    cmp [color_selected], 'q' ; blue queen
    je @@PrintSelectedPlayerQueen
    cmp [color_selected], 'Q' ; red queen
    je @@PrintSelectedEnemyQueen
    jmp @@Finish

@@PrintSelectedEnemy:
    mov [color_selected], 'S'
    push [currentY]
    push [currentX]
    call PrintPlayer
    mov [color_selected], 'r'
    jmp @@Finish

@@PrintSelectedPlayer:
    mov [color_selected], 's'
    push [currentY]
    push [currentX]
    call PrintPlayer
    mov [color_selected], 'b'
    jmp @@Finish

@@PrintSelectedEnemyQueen:
    mov [color_selected], 'F' ; enemy queen
    push [currentY]
    push [currentX]
    call PrintPlayer
    mov [color_selected], 'Q'
    jmp @@Finish
@@PrintSelectedPlayerQueen:
    mov [color_selected], 'f' ; player queen
    push [currentY]
    push [currentX]
    call PrintPlayer
    mov [color_selected], 'q'

@@Finish:
    ret

endp PrintSelected
