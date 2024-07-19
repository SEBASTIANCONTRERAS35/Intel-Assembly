.model small
.386
.stack 64
.data

; Definición de constantes
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

; Atributos de color de BIOS
cNegro          equ     00h
cBlanco         equ     0Fh
cRojoClaro      equ     0Ch


bgNegro         equ     00h
col     db      40
ren     db      22

; Posición y dirección de la pelota
ball_col    db      20
ball_ren    db      12
dir_col     db      1   ; 1: derecha, -1: izquierda
dir_ren     db      1   ; 1: abajo, -1: arriba

; Tiempo de ticks para el movimiento de la pelota
ticks_inicial dw 0
ticks_actual dw 0
ticks_deseados dw 10  

;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;Macros;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;
clear macro
    mov ax,0003h
    int 10h
endm

imprime_caracter_color macro caracter,color,bg_color
    mov ah,09h
    mov al,caracter
    mov bh,0
    mov bl,color
    or bl,bg_color
    mov cx,1
    int 10h
endm

posiciona_cursor macro renglon,columna
    mov dh,renglon
    mov dl,columna
    mov bx,0
    mov ax,0200h
    int 10h
endm

oculta_cursor_teclado   macro
    mov ah,01h
    mov cx,2607h
    int 10h
endm

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
    mov ax,@data
    mov ds,ax

    clear
    oculta_cursor_teclado
    apaga_cursor_parpadeo

    ; Leer el contador de ticks inicial
    mov ah,00h
    int 1Ah
    mov ticks_inicial,dx

lee_teclado:
    call DIBUJA_BARRA
    call MOVER_PELOTA

    mov ah,01h
    int 16h
    jz lee_teclado

    mov ah,00h
    int 16h

    cmp al,27d
    je salir

    cmp al, 'z'
    je mover_z

    cmp al, 'c'
    je mover_c

    jmp lee_teclado

mover_z:
    cmp col, 2
    jle lee_teclado
    call BORRA_BARRA
    sub col, 1
    jmp lee_teclado

mover_c:
    cmp col, 77
    jge lee_teclado
    call BORRA_BARRA
    add col, 1
    jmp lee_teclado

salir:
    clear
    mov ax,4C00h
    int 21h

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;PROCEDIMIENTOS;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DIBUJA_BARRA proc
    posiciona_cursor ren,col
    imprime_caracter_color 219,cRojoClaro,bgNegro

    inc col
    posiciona_cursor ren,col
    imprime_caracter_color 219,cRojoClaro,bgNegro
    inc col
    posiciona_cursor ren,col
    imprime_caracter_color 219,cRojoClaro,bgNegro

    sub col,3
    posiciona_cursor ren,col
    imprime_caracter_color 219,cRojoClaro,bgNegro
    dec col
    posiciona_cursor ren,col
    imprime_caracter_color 219,cRojoClaro,bgNegro

    add col,2
    ret
endp

BORRA_BARRA proc
    posiciona_cursor ren,col
    imprime_caracter_color ' ',cNegro,bgNegro
    
    inc col
    posiciona_cursor ren,col
    imprime_caracter_color ' ',cNegro,bgNegro
    inc col
    posiciona_cursor ren,col
    imprime_caracter_color ' ',cNegro,bgNegro

    sub col,3
    posiciona_cursor ren,col
    imprime_caracter_color ' ',cNegro,bgNegro
    dec col
    posiciona_cursor ren,col
    imprime_caracter_color ' ',cNegro,bgNegro

   
add col,2
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
    mov ax, ticks_actual
    mov ticks_inicial, ax

    ; Borrar la pelota en la posición actual
    posiciona_cursor ball_ren, ball_col
    imprime_caracter_color ' ', cNegro, bgNegro

    ; Calcular la nueva posición de la pelota
    mov al, ball_col
    add al, dir_col
    mov ah, ball_ren
    add ah, dir_ren

    ; Leer el carácter en la nueva posición
    push ax
    mov bh, 0
    mov dh, ah
    mov dl, al
    mov ah, 08h
    int 10h
    pop ax

    ; Verificar si choca con la barra (carácter 219d)
    cmp al, 219d
    je colision_barra

    ; Verificar colisión con las paredes y cambiar dirección si es necesario
    ; Colisión con el borde izquierdo
    cmp al, 0
    je colision_pared_izq

    ; Colisión con el borde derecho
    cmp al, 79
    jge colision_pared_der

    ; Colisión con el borde superior
    cmp ah, 0
    je colision_pared_sup

    ; Colisión con el borde inferior
    cmp ah, 24
    jge colision_pared_inf

    ; Dibujar la pelota en la nueva posición
    mov ball_col, al
    mov ball_ren, ah
    posiciona_cursor ball_ren, ball_col
    imprime_caracter_color 254, cBlanco, bgNegro

    jmp fin_mover_pelota

colision_barra:
    neg dir_ren
    jmp fin_mover_pelota

colision_pared_izq:
    neg dir_col
    jmp fin_mover_pelota

colision_pared_der:
    neg dir_col
    jmp fin_mover_pelota

colision_pared_sup:
    neg dir_ren
    jmp fin_mover_pelota

colision_pared_inf:
    neg dir_ren

fin_mover_pelota:
    ret

no_mover:
    ret
endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;FIN PROCEDIMIENTOS;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
end inicio
