title "Tarea 4- Contreras Colmenero Emilio Sebastian" ;codigo opcional. Descripcion breve del programa, el texto entrecomillado se imprime como cabecera en cada pagina de codigo
.model small    ;directiva de modelo de memoria, small => 64KB para memoria de programa y 64KB para memoria de datos
.386            ;directiva para indicar version del procesador
.stack 64       ;Define el tamano del segmento de stack, se mide en bytes
.data           ;Definicion del segmento de datos

;Valores de color para carácter
Negro          equ     00h
Blanco         equ     0Fh
;Valores de color para fondo de carácter
bgNegro         equ     00h

col     db      40       ;posicion de la columna
ren     db      22       ;posicion del renglon



clear macro.       ;clear - Limpia pantalla
    mov ax,0003h    ;ah = 00h, selecciona modo video
                    ;al = 03h. Modo texto, 16 colores
    int 10h     ;llama interrupcion 10h con opcion 00h. 
                ;Establece modo de video limpiando pantalla
endm

; imprime_caracter_color - Imprime un carácter en la pantalla con un color especificado.
; Parámetros:
; 'caracter' - El carácter a imprimir.
; 'color' - El color del carácter.
; 'bg_color' - El color de fondo del carácter.
; Colores disponibles:
; 0h: Negro
; Fh: Blanco
; Uso:
; Esta macro utiliza la interrupción 10h, función 09h de BIOS para imprimir el carácter.
; - 'caracter' se coloca en el registro AL.
; - 'color' se coloca en los 4 bits menos significativos de BL.
; - 'bg_color' se coloca en los 4 bits más significativos de BL.
; La impresión se realiza una vez (CX = 1).
; int 10h con AH=09h imprime el carácter en AL con el color especificado en BL.

imprime_caracter_color macro caracter, color, bg_color
    mov ah, 09h              ; AH = 09h, función de BIOS para imprimir un carácter
    mov al, caracter         ; AL = carácter a imprimir
    mov bh, 0                ; BH = número de página (0 por defecto)
    mov bl, color            
    or bl, bg_color          ; BL = combinación de color de carácter y color de fondo
                            ; Los 4 bits menos significativos de BL = color del carácter
                            ; Los 4 bits más significativos de BL = color de fondo
    mov cx, 1                ; CX = número de veces que se imprime el carácter (1 vez)
    int 10h                  ; Llamada a la interrupción 10h con la función 09h
endm


; posiciona_cursor - Cambia la posición del cursor a la especificada por 'renglon' y 'columna'.
; Parámetros:
; 'renglon' - El renglón al que se moverá el cursor (0-24 en modo de texto estándar).
; 'columna' - La columna a la que se moverá el cursor (0-79 en modo de texto estándar).
; Uso:
; Esta macro utiliza la interrupción 10h, función 02h de BIOS para cambiar la posición del cursor.
; - 'renglon' se coloca en el registro DH.
; - 'columna' se coloca en el registro DL.
; - AX se configura con el valor 0200h para seleccionar la función de mover el cursor.
; int 10h con AH=02h cambia la posición del cursor a los valores especificados en DH y DL.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;PROCEDIMIENTOS;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Procedimiento para dibujar la pelota en pantalla
DIBUJA_PELOTA proc
    ; Dibuja la pelota en pantalla
    posiciona_cursor pos_ren, pos_col
    imprime_caracter_color '*', Blanco, bgNegro

    ret
endp

; Procedimiento para borrar la pelota de la pantalla
BORRA_PELOTA proc
    ; Borra la pelota de la pantalla
    posiciona_cursor pos_ren, pos_col
    imprime_caracter_color ' ', Negro, bgNegro

    ret
endp

; Procedimiento para mover la pelota
MOVER_PELOTA proc
    ; Borra la pelota de la posición actual
    call BORRA_PELOTA

    ; Actualiza la posición de la pelota
    add pos_col, dir_pelota_x
    add pos_ren, dir_pelota_y

    ; Dibuja la pelota en la nueva posición
    call DIBUJA_PELOTA

    ; Espera un tiempo antes de mover la pelota nuevamente
    call ESPERAR

    ret
endp

; Procedimiento para verificar y corregir las colisiones de la pelota con las paredes
VERIFICAR_COLISION_PAREDES proc
    ; Comprueba y corrige la colisión con las paredes horizontales
    cmp pos_ren, 1
    jg sin_colision_paredes  ; No hay colisión con la parte superior

    mov dir_pelota_y, 1  ; Cambia la dirección hacia abajo
    jmp sin_colision_paredes

    cmp pos_ren, 24
    jl sin_colision_paredes  ; No hay colisión con la parte inferior

    mov dir_pelota_y, -1  ; Cambia la dirección hacia arriba
    jmp sin_colision_paredes

    ; Comprueba y corrige la colisión con las paredes verticales
    cmp pos_col, 2
    jg sin_colision_paredes  ; No hay colisión con el lado izquierdo

    mov dir_pelota_x, 1  ; Cambia la dirección hacia la derecha
    jmp sin_colision_paredes

    cmp pos_col, 78
    jl sin_colision_paredes  ; No hay colisión con el lado derecho

    mov dir_pelota_x, -1  ; Cambia la dirección hacia la izquierda
    jmp sin_colision_paredes

sin_colision_paredes:
    ret
endp

; Procedimiento para esperar un período de tiempo
ESPERAR proc
    mov cx, 60000  ; Ajusta este valor para controlar la duración de la espera
espera_bucle:
    loop espera_bucle  ; Decrementa cx hasta que sea 0
    ret
endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;Fin PROCEDIMIENTOS;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

posiciona_cursor macro renglon, columna
    mov dh, renglon          ; DH = renglón al que se moverá el cursor
    mov dl, columna          ; DL = columna a la que se moverá el cursor
    mov bx, 0                ; BH = número de página (0 por defecto)
    mov ax, 0200h            ; AX = 0200h, función de BIOS para mover el cursor
    int 10h                  ; Llamada a la interrupción 10h con la función 02h
endm


;oculta_cursor_teclado - Oculta la visibilidad del cursor del teclado
oculta_cursor_teclado   macro
    mov ah,01h      ;Opcion 01h
    mov cx,2607h    ;Parametro necesario para ocultar cursor
    int 10h         ;int 10, opcion 01h. Cambia la visibilidad del cursor del teclado
endm

;apaga_cursor_parpadeo - Deshabilita el parpadeo del cursor cuando se imprimen caracteres con fondo de color
;Habilita 16 colores de fondo
apaga_cursor_parpadeo   macro
    mov ax,1003h        ;Opcion 1003h
    xor bl,bl           ;BL = 0, parámetro para int 10h opción 1003h
    int 10h             ;int 10, opcion 01h. Cambia la visibilidad del cursor del teclado
endm


    .code
inicio:                 ;etiqueta inicio
    mov ax,@data
    mov ds,ax

    ;Limpiar pantalla
    clear

    ;quitar el cursor de pantalla
    oculta_cursor_teclado
    apaga_cursor_parpadeo

lee_teclado:
    ;Dibujar una barra en pantalla con caracteres
    call DIBUJA_BARRA

    ;Revisa buffer del teclado
    mov ah,01h
    int 16h
    ;Si bandera Z=0, entonces hay algo en el buffer, si Z=1, entonces el buffer esta vacio
    jz lee_teclado

    ;vacia buffer
    mov ah,00h
    int 16h

    ;compara tecla con [ESC], si no es entonces revisa para movimiento
    cmp al,27d
    je salir

    ;Comparar con la tecla para mover a la izquierda  "z "
    cmp al, 'z'
    je mover_izquierda

    ;Comparar con la tecla para mover a la derecha "c"
    cmp al, 'c'
    je mover_derecha

    ;Regresar a la espera del teclado
    jmp lee_teclado

mover_izquierda:
    ; Verificar que la barra no se salga del límite izquierdo
    cmp col, 2
    jle lee_teclado  ; Si está en el borde, no moverse

    ; Borrar la barra actual
    call BORRA_BARRA

    ; Mover la posición de la barra a la izquierda
    sub col, 1

    ; Dibujar la barra en la nueva posición
    jmp lee_teclado

mover_derecha:
    ; Verificar que la barra no se salga del límite derecho
    cmp col, 77
    jge lee_teclado  ; Si está en el borde, no moverse

    ; Borrar la barra actual
    call BORRA_BARRA

    ; Mover la posición de la barra a la derecha
    add col, 1

    ; Dibujar la barra en la nueva posición
    jmp lee_teclado

salir:              ;inicia etiqueta salir
    clear           ;limpia pantalla
    mov ax,4C00h    ;AH = 4Ch, opción para terminar programa, AL = 0 Exit Code, código devuelto al finalizar el programa
    int 21h         ;señal 21h de interrupción, pasa el control al sistema operativo


DIBUJA_BARRA proc
    ;imprime centro de la barra
    posiciona_cursor ren,col
    imprime_caracter_color 219,Blanco,bgNegro
    
    ;imprime caracter una posicion a la derecha del centro
    inc col
    posiciona_cursor ren,col
    imprime_caracter_color 219,Blanco,bgNegro

    ;imprime caracter dos posiciones a la derecha del centro
    inc col
    posiciona_cursor ren,col
    imprime_caracter_color 219,Blanco,bgNegro

    ;imprime caracter una posicion a la izquierda del centro
    sub col,3
    posiciona_cursor ren,col
    imprime_caracter_color 219,Blanco,bgNegro

    ;imprime caracter dos posiciones a la izquierda del centro
    dec col
    posiciona_cursor ren,col
    imprime_caracter_color 219,Blanco,bgNegro

    ;suma final para recuperar el valor inicial de pos_col
    add col,2
    ret
endp

BORRA_BARRA proc
    ;imprime centro de la barra
    posiciona_cursor ren,col
    imprime_caracter_color ' ',Negro,bgNegro
    
    ;imprime caracter una posicion a la derecha del centro
    inc col
    posiciona_cursor ren,col
    imprime_caracter_color ' ',Negro,bgNegro

    ;imprime caracter dos posiciones a la derecha del centro
    inc col
    posiciona_cursor ren,col
    imprime_caracter_color ' ',Negro,bgNegro

    ;imprime caracter una posicion a la izquierda del centro
    sub col,3
    posiciona_cursor ren,col
    imprime_caracter_color ' ',Negro,bgNegro

    ;imprime caracter dos posiciones a la izquierda del centro
    dec col
    posiciona_cursor ren,col
    imprime_caracter_color ' ',Negro,bgNegro

    ;suma final para recuperar el valor inicial de pos_col
    add col,2
    ret
endp
    end inicio         