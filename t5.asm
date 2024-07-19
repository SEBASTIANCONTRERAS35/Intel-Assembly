title "Tarea 4- Contreras Colmenero Emilio Sebastian"
.model small
.stack 64
.386

.data
; Valores de color para carácter
Negro      equ 00h
Blanco     equ 0Fh
; Valores de color para fondo de carácter
bgNegro    equ 00h

col        db 40      ; posición de la columna de la barra
ren        db 22      ; posición del renglón de la barra

; Posición y dirección inicial de la pelota
pelota_col db 40
pelota_ren db 12
dx_dir     db 1       ; 1: derecha, -1: izquierda
dy_dir     db 1       ; 1: abajo, -1: arriba

clear macro
    mov ax, 0003h
    int 10h
endm

imprime_caracter_color macro caracter, color, bg_color
    mov ah, 09h
    mov al, caracter
    mov bh, 0
    mov bl, color
    or  bl, bg_color
    mov cx, 1
    int 10h
endm

posiciona_cursor macro renglon, columna
    mov dh, renglon
    mov dl, columna
    mov bx, 0
    mov ax, 0200h
    int 10h
endm

oculta_cursor_teclado macro
    mov ah, 01h
    mov cx, 2607h
    int 10h
endm

apaga_cursor_parpadeo macro
    mov ax, 1003h
    xor bl, bl
    int 10h
endm

.code
inicio:
    mov ax, @data
    mov ds, ax

    clear
    oculta_cursor_teclado
    apaga_cursor_parpadeo

main_loop:
    call DIBUJA_BARRA
    call MUEVE_PELOTA

    ; Revisa buffer del teclado
    mov ah, 01h
    int 16h
    jz main_loop

    mov ah, 00h
    int 16h

    ; Compara tecla con [ESC]
    cmp al, 27
    je salir

    ; Comparar con la tecla para mover a la izquierda "z"
    cmp al, 'z'
    je mover_izquierda

    ; Comparar con la tecla para mover a la derecha "c"
    cmp al, 'c'
    je mover_derecha

    jmp main_loop

mover_izquierda:
    cmp col, 2
    jle main_loop
    call BORRA_BARRA
    sub col, 1
    jmp main_loop

mover_derecha:
    cmp col, 77
    jge main_loop
    call BORRA_BARRA
    add col, 1
    jmp main_loop

salir:
    clear
    mov ax, 4C00h
    int 21h

DIBUJA_BARRA proc
    posiciona_cursor ren, col
    imprime_caracter_color 219, Blanco, bgNegro

    inc col
    posiciona_cursor ren, col
    imprime_caracter_color 219, Blanco, bgNegro

    inc col
    posiciona_cursor ren, col
    imprime_caracter_color 219, Blanco, bgNegro

    sub col, 3
    posiciona_cursor ren, col
    imprime_caracter_color 219, Blanco, bgNegro

    dec col
    posiciona_cursor ren, col
    imprime_caracter_color 219, Blanco, bgNegro

    add col, 2
    ret
endp

BORRA_BARRA proc
    posiciona_cursor ren, col
    imprime_caracter_color ' ', Negro, bgNegro

    inc col
    posiciona_cursor ren, col
    imprime_caracter_color ' ', Negro, bgNegro

    inc col
    posiciona_cursor ren, col
    imprime_caracter_color ' ', Negro, bgNegro

    sub col, 3
    posiciona_cursor ren, col
    imprime_caracter_color ' ', Negro, bgNegro

    dec col
    posiciona_cursor ren, col
    imprime_caracter_color ' ', Negro, bgNegro

    add col, 2
    ret
endp

MUEVE_PELOTA proc
    ; Borrar la pelota de la posición actual
    mov al, [pelota_ren]
    mov ah, [pelota_col]
    posiciona_cursor al, ah
    imprime_caracter_color ' ', Negro, bgNegro

    ; Actualizar la posición de la pelota
    mov al, [pelota_col]
    add al, [dx_dir]
    mov [pelota_col], al

    mov al, [pelota_ren]
    add al, [dy_dir]
    mov [pelota_ren], al

    ; Comprobar colisiones con los bordes de la pantalla
    cmp [pelota_col], 0
    jle rebote_horizontal

    cmp [pelota_col], 79
    jge rebote_horizontal

    cmp [pelota_ren], 0
    jle rebote_vertical

    cmp [pelota_ren], 24
    jge rebote_vertical

    ; Comprobar colisiones con la barra
    cmp [pelota_ren], ren
    jne dibuja_pelota

    ; Verificar si la pelota está en el rango de la barra
    mov al, [pelota_col]
    sub al, col
    cmp al, -2
    jl dibuja_pelota
    cmp al, 2
    jg dibuja_pelota

    ; Invertir dirección vertical si hay colisión con la barra
    neg byte ptr [dy_dir]

dibuja_pelota:
    ; Dibujar la pelota en la nueva posición
    mov al, [pelota_ren]
    mov ah, [pelota_col]
    posiciona_cursor al, ah
    imprime_caracter_color '*', Blanco, bgNegro

    ; Esperar un poco para hacer el movimiento visible
    mov cx, 30000
delay_loop:
    loop delay_loop

    ret

rebote_horizontal:
    neg byte ptr [dx_dir]
    jmp dibuja_pelota

rebote_vertical:
    neg byte ptr [dy_dir]
    jmp dibuja_pelota

endp

end inicio


