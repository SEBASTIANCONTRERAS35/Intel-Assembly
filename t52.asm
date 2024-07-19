title "Tarea 5"

.model small
.386
.stack 64
.data

; Definición de constantes para los caracteres de los bordes del marco
marcoEsqInfIzq      equ     200d
marcoEsqInfDer      equ     188d
marcoEsqSupDer      equ     187d
marcoEsqSupIzq      equ     201d
marcoCruceVerSup    equ     203d
marcoCruceHorDer    equ     185d
marcoCruceVerInf    equ     202d
marcoCruceHorIzq    equ     204d
marcoCruce          equ     206d
marcoHor            equ     205d
marcoVer            equ     186d

; Definición de constantes para los atributos de color de BIOS
cNegro          equ     00h
cAzul           equ     01h
cVerde          equ     02h
cCyan           equ     03h
cRojo           equ     04h
cMagenta        equ     05h
cCafe           equ     06h
cGrisClaro      equ     07h
cGrisOscuro     equ     08h
cAzulClaro      equ     09h
cVerdeClaro     equ     0Ah
cCyanClaro      equ     0Bh
cRojoClaro      equ     0Ch
cMagentaClaro   equ     0Dh
cAmarillo       equ     0Eh
cBlanco         equ     0Fh

bgNegro         equ     00h
bgAzul          equ     10h
bgVerde         equ     20h
bgCyan          equ     30h
bgRojo          equ     40h
bgMagenta       equ     50h
bgCafe          equ     60h
bgGrisClaro     equ     70h
bgGrisOscuro    equ     80h
bgAzulClaro     equ     90h
bgVerdeClaro    equ     0A0h
bgCyanClaro     equ     0B0h
bgRojoClaro     equ     0C0h
bgMagentaClaro  equ     0D0h
bgAmarillo      equ     0E0h
bgBlanco        equ     0F0h

; Variables de la posición de la barra
pos_col     db      40
pos_ren     db      22

; Variables de la posición y dirección de la pelota
ball_col    db      20
ball_ren    db      12
dir_ball_col     db      1   ; 1: derecha, -1: izquierda
dir_ball_ren     db      1   ; 1: abajo, -1: arriba

; Variables para la barra
pos_barra_x     db      40       ; posición X inicial de la barra
pos_barra_y     db      22       ; posición Y inicial de la barra

; Tiempo de ticks para el movimiento de la pelota
ticks_inicial dw 0
ticks_actual dw 0
ticks_deseados dw 1

;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;Macros;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;

; Macro para limpiar la pantalla
clear macro
    mov ax,0003h
    int 10h
endm

; Macro para imprimir un carácter con color
imprime_caracter_color macro caracter,color,bg_color
    mov ah,09h
    mov al,caracter
    mov bh,0
    mov bl,color
    or bl,bg_color
    mov cx,1
    int 10h
endm

; Macro para posicionar el cursor
posiciona_cursor macro renglon,columna
    mov dh,renglon
    mov dl,columna
    mov bx,0
    mov ax,0200h
    int 10h
endm

; Macro para ocultar el cursor del teclado
oculta_cursor_teclado   macro
    mov ah,01h
    mov cx,2607h
    int 10h
endm

; Macro para apagar el parpadeo del cursor
apaga_cursor_parpadeo   macro
    mov ax,1003h
    xor bl,bl
    int 10h
endm

;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;Fin Macros;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;

.code
inicio:
    ; Inicialización del segmento de datos
    mov ax,@data
    mov ds,ax

    ; Limpiar la pantalla y configurar el cursor
    clear
    oculta_cursor_teclado
    apaga_cursor_parpadeo

    ; Dibujar la barra inicial
    call DIBUJA_BARRA

    ; Leer el contador de ticks inicial
    mov ah,00h
    int 1Ah
    mov ticks_inicial,dx

lee_teclado:
    ; Mover la pelota y verificar colisiones
    call MOVER_PELOTA   
    call VERIFICAR_COLISION_BARRA
    call DIBUJA_BARRA

    ; Leer la entrada del teclado
    mov ah,01h
    int 16h
    jz lee_teclado

    mov ah,00h
    int 16h
    cmp al, 'a'
    je mover_izquierda

    cmp al, 'd'
    je mover_derecha

    cmp al,27d
    je salir

    jmp lee_teclado

mover_izquierda:
    ; Mover la barra a la izquierda si no está en el borde
    cmp pos_barra_x, 2
    jle lee_teclado
    call BORRA_BARRA
    sub pos_barra_x, 1
    jmp lee_teclado

mover_derecha:
    ; Mover la barra a la derecha si no está en el borde
    cmp pos_barra_x, 77
    jge lee_teclado
    call BORRA_BARRA
    add pos_barra_x, 1
    jmp lee_teclado

salir:
    ; Limpiar la pantalla y salir del programa
    clear
    mov ax,4C00h
    int 21h

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;PROCEDIMIENTOS;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DIBUJA_BARRA proc
    ; Dibujar la barra en la posición actual
    posiciona_cursor pos_barra_y,pos_barra_x
    imprime_caracter_color 219,cAzul,bgNegro

    inc pos_barra_x
    posiciona_cursor pos_barra_y,pos_barra_x
    imprime_caracter_color 219,cAzul,bgNegro
    inc pos_barra_x
    posiciona_cursor pos_barra_y,pos_barra_x
    imprime_caracter_color 219,cAzul,bgNegro

    sub pos_barra_x,3
    posiciona_cursor pos_barra_y,pos_barra_x
    imprime_caracter_color 219,cAzul,bgNegro
    dec pos_barra_x
    posiciona_cursor pos_barra_y,pos_barra_x
    imprime_caracter_color 219,cAzul,bgNegro

    add pos_barra_x,2
    ret
endp

BORRA_BARRA proc
    ; Borrar la barra en la posición actual
    posiciona_cursor pos_barra_y,pos_barra_x
    imprime_caracter_color ' ',cNegro,bgNegro
    
    inc pos_barra_x
    posiciona_cursor pos_barra_y,pos_barra_x
    imprime_caracter_color ' ',cNegro,bgNegro
    inc pos_barra_x
    posiciona_cursor pos_barra_y,pos_barra_x
    imprime_caracter_color ' ',cNegro,bgNegro

    sub pos_barra_x,3
    posiciona_cursor pos_barra_y,pos_barra_x
    imprime_caracter_color ' ',cNegro,bgNegro
    dec pos_barra_x
    posiciona_cursor pos_barra_y,pos_barra_x
    imprime_caracter_color ' ',cNegro,bgNegro

    add pos_barra_x,2
    ret
endp

MOVER_PELOTA proc
    ; Leer el contador de ticks actual
    mov ah,00h
    int 1Ah
    mov ticks_actual,dx

    ; Comparar el tiempo transcurrido con los ticks deseados
    mov ax,ticks_actual
    sub ax,ticks_inicial
    cmp ax,ticks_deseados
    jb no_mover

    ; Actualizar el tiempo inicial
    mov ticks_inicial, dx

    ; Borrar la pelota en la posición actual
    posiciona_cursor ball_ren, ball_col
    imprime_caracter_color ' ', cNegro, bgNegro

    ; Calcular la nueva posición de la pelota
    mov al, ball_col
    add al, dir_ball_col
    mov ball_col, al

    mov ah, ball_ren
    add ah, dir_ball_ren
    mov ball_ren, ah

    ; Verificar colisión con las paredes y cambiar dirección si es necesario
    ; Colisión con los bordes
    cmp ball_col, 2
    jge no_izq
    neg dir_ball_col
no_izq:
    cmp ball_col, 77
    jle no_der
    neg dir_ball_col
no_der:
    cmp ball_ren, 2
    jge no_arr
    neg dir_ball_ren
no_arr:
    cmp ball_ren, 24
    jle no_abj
    neg dir_ball_ren

no_abj:

    ; Dibujar la pelota en la nueva posición
    posiciona_cursor ball_ren, ball_col
    imprime_caracter_color 254, cBlanco, bgNegro

no_mover:
    ret
endp

VERIFICAR_COLISION_BARRA proc
    ; Verifica la colisión entre la pelota y la barra
    ; Primero verifica si la pelota está en la misma fila que la barra
    mov ah, ball_ren
    cmp ah, pos_barra_y
    jne sin_colision_barra

    ; Comprueba si la pelota está en la misma columna que la barra
    mov al, ball_col
    cmp al, pos_barra_x - 3
    jb sin_colision_barra

    cmp al, pos_barra_x + 3
    ja sin_colision_barra

    ; Si está en el rango de la barra, cambia la dirección de la pelota
    jmp cambio_direccion

cambio_direccion:
    ; Cambia la dirección de la pelota
    neg dir_ball_ren
    jmp sin_colision_barra

sin_colision_barra:
    ret
endp

; Termina el programa
end inicio