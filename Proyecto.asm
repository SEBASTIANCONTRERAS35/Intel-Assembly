title "Proyecto: Ponj" ;codigo opcional. Descripcion breve del programa, el texto entrecomillado se imprime como cabecera en cada pagina de codigo
    .model small    ;directiva de modelo de memoria, small => 64KB para memoria de programa y 64KB para memoria de datos
    .386            ;directiva para indicar version del procesador
    .stack 64       ;Define el tamano del segmento de stack, se mide en bytes
    .data           ;Definicion del segmento de datos
;Definición de constantes
;Valor ASCII de caracteres para el marco del programa
marcoEsqInfIzq      equ     200d    ;'╚'
marcoEsqInfDer      equ     188d    ;'╝'
marcoEsqSupDer      equ     187d    ;'╗'
marcoEsqSupIzq      equ     201d    ;'╔'
marcoCruceVerSup    equ     203d    ;'╦'
marcoCruceHorDer    equ     185d    ;'╣'
marcoCruceVerInf    equ     202d    ;'╩'
marcoCruceHorIzq    equ     204d    ;'╠'
marcoCruce          equ     206d    ;'╬'
marcoHor            equ     205d    ;'═'
marcoVer            equ     186d    ;'║'
;Atributos de color de BIOS
;Valores de color para carácter
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
;Valores de color para fondo de carácter
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

;Definicion de variables
titulo          db      "PONJ"
player1         db      "Player 1"
player2         db      "Player 2"
p1_score        db      0
p2_score        db      0
game_over db 0   ; Bandera para indicar fin del juego (0 = en curso, 1 = fin de juego)


;variables para guardar la posición del player 1
p1_col          db      78 
p1_ren          db      15



;variables para guardar la posición del player 2
p2_col          db      1
p2_ren          db      15

;variables para guardar una posición auxiliar
;sirven como variables globales para algunos procedimientos
col_aux         db      0
ren_aux         db      0

;variable que se utiliza como valor 10 auxiliar en divisiones
diez            dw      10

;Una variable contador para algunos loops
conta           db      0

;Variables que sirven de parametros para el procedimiento IMPRIME_BOTON
boton_caracter  db      0
boton_renglon   db      0
boton_columna   db      0
boton_color     db      0
boton_bg_color  db      0

;Auxiliar para calculo de coordenadas del mouse
ocho        db      8
;Cuando el driver del mouse no esta disponible
no_mouse        db  'No se encuentra driver de mouse. Presione [enter] para salir$'


;variables para guardar la posicion del mensaje comenzar el juego
mensaje_inicio db 'Presione Enter para iniciar el juego', 0  ; Mensaje para mostrar
longitud_mensaje_inicio equ $-mensaje_inicio                ; Longitud del mensaje
color_mensaje equ 0x0F                                      ; Color del texto (blanco sobre negro)


ticks_inicio dw 5 ;tiempo de espera para la bola

pel_col  db      40       ; posición inicial de la columna de la pelota
pel_ren  db      12       ; posición inicial del renglón de la pelota
despel_h db      1        ; desplazamiento horizontal de la pelota 
despel_v db      1        ; desplazamiento vertical de la pelota

caracter db 2d


; Variables para las posiciones de los obstáculos
obstaculo1_ren db 20
obstaculo1_col db 20
obstaculo2_ren db 12
obstaculo2_col db 30
obstaculo3_ren db 14
obstaculo3_col db 40

;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;Macros;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;
;clear - Limpia pantalla
clear macro
    mov ax,0003h    ;ah = 00h, selecciona modo video
                    ;al = 03h. Modo texto, 16 colores
    int 10h     ;llama interrupcion 10h con opcion 00h. 
                ;Establece modo de video limpiando pantalla
endm

;posiciona_cursor - Cambia la posición del cursor a la especificada con 'renglon' y 'columna' 
posiciona_cursor macro renglon,columna
    mov dh,renglon  ;dh = renglon
    mov dl,columna  ;dl = columna
    mov bx,0
    mov ax,0200h    ;preparar ax para interrupcion, opcion 02h
    int 10h         ;interrupcion 10h y opcion 02h. Cambia posicion del cursor
endm 

;inicializa_ds_es - Inicializa el valor del registro DS y ES
inicializa_ds_es    macro
    mov ax,@data
    mov ds,ax
    mov es,ax       ;Este registro se va a usar, junto con BP, para imprimir cadenas utilizando interrupción 10h
endm

;muestra_cursor_mouse - Establece la visibilidad del cursor del mouser
muestra_cursor_mouse    macro
    mov ax,1        ;opcion 0001h
    int 33h         ;int 33h para manejo del mouse. Opcion AX=0001h
                    ;Habilita la visibilidad del cursor del mouse en el programa
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





imprime_caracter_color macro caracter,color,bg_color
    mov ah,09h              ;preparar AH para interrupcion, opcion 09h
    mov al,caracter         ;AL = caracter a imprimir
    mov bh,0                ;BH = numero de pagina
    mov bl,color            
    or bl,bg_color          ;BL = color del caracter
                            ;'color' define los 4 bits menos significativos 
                            ;'bg_color' define los 4 bits más significativos 
    mov cx,1                ;CX = numero de veces que se imprime el caracter
                            ;CX es un argumento necesario para opcion 09h de int 10h
    int 10h                 ;int 10h, AH=09h, imprime el caracter en AL con el color BL
endm

;imprime_caracter_color - Imprime un caracter de cierto color en pantalla, especificado por 'caracter', 'color' y 'bg_color'. 
; utiliza int 10h opcion 09h
; 'cadena' - nombre de la cadena en memoria que se va a imprimir
; 'long_cadena' - longitud (en caracteres) de la cadena a imprimir
; 'color' - color que tomarán los caracteres de la cadena
; 'bg_color' - color de fondo para los caracteres en la cadena
imprime_cadena_color macro cadena,long_cadena,color,bg_color
    mov ah,13h              ;preparar AH para interrupcion, opcion 13h
    lea bp,cadena           ;BP como apuntador a la cadena a imprimir
    mov bh,0                ;BH = numero de pagina
    mov bl,color            
    or bl,bg_color          ;BL = color del caracter
                            ;'color' define los 4 bits menos significativos 
                            ;'bg_color' define los 4 bits más significativos 
    mov cx,long_cadena      ;CX = longitud de la cadena, se tomarán este número de localidades a partir del apuntador a la cadena
    int 10h                 ;int 10h, AH=09h, imprime el caracter en AL con el color BL
endm

;lee_mouse - Revisa el estado del mouse
;Devuelve:
;;BX - estado de los botones
;;;Si BX = 0000h, ningun boton presionado
;;;Si BX = 0001h, boton izquierdo presionado
;;;Si BX = 0002h, boton derecho presionado
;;;Si BX = 0003h, boton izquierdo y derecho presionados
; (400,120) => 80x25 =>Columna: 400 x 80 / 640 = 50; Renglon: (120 x 25 / 200) = 15 => 50,15
;;CX - columna en la que se encuentra el mouse en resolucion 640x200 (columnas x renglones)
;;DX - renglon en el que se encuentra el mouse en resolucion 640x200 (columnas x renglones)
lee_mouse   macro
    mov ax,0003h
    int 33h
endm

;comprueba_mouse - Revisa si el driver del mouse existe
comprueba_mouse     macro
    mov ax,0        ;opcion 0
    int 33h         ;llama interrupcion 33h para manejo del mouse, devuelve un valor en AX
                    ;Si AX = 0000h, no existe el driver. Si AX = FFFFh, existe driver
endm
;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;Fin Macros;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;
    .code
inicio:                 ;etiqueta inicio
    inicializa_ds_es
    ;mensaje de inicio para poner [enter]
    clear 
    posiciona_cursor 12, 30
    imprime_cadena_color mensaje_inicio, longitud_mensaje_inicio, cBlanco, bgNegro
    call esperar_tecla
    clear 



    ; Inicializar temporizadores
    call CONTEO_TICKS
    mov [ticks_inicio], dx


    comprueba_mouse     ;macro para revisar driver de mouse
    xor ax,0FFFFh       ;compara el valor de AX con FFFFh, si el resultado es zero, entonces existe el driver de mouse
    jz imprime_ui       ;Si existe el driver del mouse, entonces salta a 'imprime_ui'
    ;Si no existe el driver del mouse entonces se muestra un mensaje
    lea dx,[no_mouse]
    mov ax,0900h    ;opcion 9 para interrupcion 21h
    int 21h         ;interrupcion 21h. Imprime cadena.
    jmp teclado     ;salta a 'teclado'
imprime_ui:
    clear                   ;limpia pantalla
    oculta_cursor_teclado   ;oculta cursor del mouse
    apaga_cursor_parpadeo   ;Deshabilita parpadeo del cursor
    call DIBUJA_UI  ;procedimiento que dibuja marco de la interfaz
    muestra_cursor_mouse    ;hace visible el cursor del mouse



;Revisar que el boton izquierdo del mouse no esté presionado
;Si el botón no está suelto, no continúa
mouse_no_clic:
    lee_mouse
    test bx,0001h
    jnz mouse_no_clic
;Lee el mouse y avanza hasta que se haga clic en el boton izquierdo
mouse:
    lee_mouse
    test bx,0001h       ;Para revisar si el boton izquierdo del mouse fue presionado
    jz mouse            ;Si el boton izquierdo no fue presionado, vuelve a leer el estado del mouse

    ;Leer la posicion del mouse y hacer la conversion a resolucion
    ;80x25 (columnas x renglones) en modo texto
    mov ax,dx           ;Copia DX en AX. DX es un valor entre 0 y 199 (renglon)
    div [ocho]          ;Division de 8 bits
                        ;divide el valor del renglon en resolucion 640x200 en donde se encuentra el mouse
                        ;para obtener el valor correspondiente en resolucion 80x25
    xor ah,ah           ;Descartar el residuo de la division anterior
    mov dx,ax           ;Copia AX en DX. AX es un valor entre 0 y 24 (renglon)

    mov ax,cx           ;Copia CX en AX. CX es un valor entre 0 y 639 (columna)
    div [ocho]          ;Division de 8 bits
                        ;divide el valor de la columna en resolucion 640x200 en donde se encuentra el mouse
                        ;para obtener el valor correspondiente en resolucion 80x25
    xor ah,ah           ;Descartar el residuo de la division anterior
    mov cx,ax           ;Copia AX en CX. AX es un valor entre 0 y 79 (columna)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Aqui va la lógica de la posicion del mouse;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;Si el mouse fue presionado en el renglon 0
    ;se va a revisar si fue dentro del boton [X]
    cmp dx,0
    je boton_x
    
    ; Revisar si el mouse fue presionado en el renglón 2
    cmp dx,2
    jne mouse_no_clic


    ; Revisar si el mouse fue presionado en el botón Stop (columna 34 a 36)
    cmp cx,34
    jle check_start ;Quizas jmp
    cmp cx,36
    jle boton_stop


check_start:
    ; Revisar si el mouse fue presionado en el botón Start (columna 43 a 45)
    cmp cx,43
    jl mouse_no_clic
    cmp cx,45
    jle boton_start

    jmp mouse_no_clic


boton_x:
    jmp boton_x1

;Lógica para revisar si el mouse fue presionado en [X]
;[X] se encuentra en renglon 0 y entre columnas 76 y 78
boton_x1:
    cmp cx,76
    jge boton_x2
    jmp mouse_no_clic
boton_x2:
    cmp cx,78
    jbe boton_x3
    jmp mouse_no_clic
boton_x3:
    ;Se cumplieron todas las condiciones
    jmp salir



boton_stop:
    ; Lógica para reiniciar el juego
    jmp inicio 
    
boton_start:
    ; Lógica para iniciar el juego
    ; Dibujar barra del primer jugador
    call DIBUJA_BARRA1
    ; Dibujar barra del segundo jugador
    call DIBUJA_BARRA2
    ; Mover pelota
    call MOVER_PELOTA
    ; Imprimir la pelota en su nueva posición
    call IMPRIME_BOLA

    ;Imprime los obstaculos
    call IMPRIME_OBSTACULO



    ; Verificar estado del mouse periódicamente para botones X y Stop
    call verificar_botones




    ; Revisar si hay tecla presionada
    mov ah, 01h
    int 16h
    jz continuar
    ; Leer tecla presionada
    mov ah, 00h
    int 16h

    ; Comparar tecla con ESC para salir
    cmp al, 1Bh
    je salir

    ; Comparar tecla con 'l' para mover barra del primer jugador hacia abajo
    cmp al, 'l'
    je mover_abajo1

    ; Comparar tecla con 'j' para mover barra del primer jugador hacia arriba
    cmp al, 'j'
    je mover_arriba1

    ; Comparar tecla con 'd' para mover barra del segundo jugador hacia abajo
    cmp al, 'd'
    je mover_abajo2

    ; Comparar tecla con 'a' para mover barra del segundo jugador hacia arriba
    cmp al, 'a'
    je mover_arriba2

continuar:
    ; Verificar si el juego ha terminado
    cmp game_over, 1
    jne boton_start   ; Si el juego no ha terminado, continuar con el bucle principal

    ; Si el juego ha terminado, saltar a juego_terminado
    jmp juego_terminado

juego_terminado:
    ; Código para mostrar fin del juego y permitir reiniciar
    ; Lógica para reiniciar el juego
    jmp reiniciar_juego

reiniciar_juego:
    mov p1_score, 0    ; Reiniciar la puntuación del jugador 1
    mov p2_score, 0    ; Reiniciar la puntuación del jugador 2
    mov game_over, 0   ; Restablecer la bandera de fin del juego

    call DIBUJA_BARRA1
    call DIBUJA_BARRA2
    call MOVER_PELOTA
    call IMPRIME_BOLA

    jmp boton_start    ; Volver al inicio del bucle principal para reiniciar el juego


verificar_botones:
    ; Verificar el estado del mouse
    lee_mouse
    test bx, 0001h
    jz fin_verificar

    ; Determinar la posición del mouse
    lee_mouse
    test bx, 0001h
    jz fin_verificar

    mov ax, dx
    div [ocho]
    xor ah, ah
    mov dx, ax

    mov ax, cx
    div [ocho]
    xor ah, ah
    mov cx, ax

    cmp dx, 0
    je boton_x
    cmp dx, 2
    jne fin_verificar
    cmp cx, 34
    jle fin_verificar
    cmp cx, 36
    jle boton_stop
    cmp cx, 43
    jl fin_verificar
    cmp cx, 45
    jle boton_start

fin_verificar:
    ret

mover_abajo1:
    ; Verificar que no se salga de los límites
    cmp p1_ren, 20
    jge continuar

    ; Borrar barra actual
    call BORRAR_BARRA1

    ; Mover barra hacia abajo
    inc p1_ren

    jmp continuar

mover_arriba1:
    ; Verificar que no se salga de los límites
    cmp p1_ren, 10
    jle continuar

    ; Borrar barra actual
    call BORRAR_BARRA1

    ; Mover barra hacia arriba
    dec p1_ren

    jmp continuar

mover_arriba2:
    ; Verificar que no se salga de los límites
    cmp p2_ren, 10
    jle continuar

    ; Borrar barra actual del segundo jugador
    call BORRAR_BARRA2

    ; Mover barra hacia arriba
    dec p2_ren

    jmp continuar

mover_abajo2:
    ; Verificar que no se salga de los límites
    cmp p2_ren, 20
    jge continuar

    ; Borrar barra actual del segundo jugador
    call BORRAR_BARRA2

    ; Mover barra hacia abajo
    inc p2_ren

    jmp continuar

;Si no se encontró el driver del mouse, muestra un mensaje y el usuario debe salir tecleando [enter]
teclado:
    mov ah,08h
    int 21h
    cmp al,0Dh      ;compara la entrada de teclado si fue [enter]
    jnz teclado     ;Sale del ciclo hasta que presiona la tecla [enter]


salir:              ;inicia etiqueta salir
    clear           ;limpia pantalla
    mov ax,4C00h    ;AH = 4Ch, opción para terminar programa, AL = 0 Exit Code, código devuelto al finalizar el programa
    int 21h         ;señal 21h de interrupción, pasa el control al sistema operativo

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;PROCEDIMIENTOS;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



esperar_tecla:
    ; Leer la entrada del teclado para verificar si se presionó Enter
    mov ah, 01h        ; Función para verificar si se presionó una tecla
    int 16h            ; Interrupción para leer la tecla presionada
    jz esperar_tecla   ; Si no se presionó ninguna tecla, continuar esperando

    mov ah, 00h        ; Función para leer la tecla presionada
    int 16h            ; Interrupción para leer la tecla presionada
    cmp al, 0Dh        ; Verificar si se presionó la tecla Enter
    jne esperar_tecla  ; Si no se presionó Enter, continuar esperando

    ; Si se presionó Enter, llamar a la función para mover la pelota
    ret ; Si se presionó enter, retornar a flujo normal



    DIBUJA_UI proc
        ;imprimir esquina superior izquierda del marco
        posiciona_cursor 0,0
        imprime_caracter_color marcoEsqSupIzq,cAmarillo,bgNegro
        
        ;imprimir esquina superior derecha del marco
        posiciona_cursor 0,79
        imprime_caracter_color marcoEsqSupDer,cAmarillo,bgNegro
        
        ;imprimir esquina inferior izquierda del marco
        posiciona_cursor 24,0
        imprime_caracter_color marcoEsqInfIzq,cAmarillo,bgNegro
        
        ;imprimir esquina inferior derecha del marco
        posiciona_cursor 24,79
        imprime_caracter_color marcoEsqInfDer,cAmarillo,bgNegro
        
        ;imprimir marcos horizontales, superior e inferior
        mov cx,78       ;CX = 004Eh => CH = 00h, CL = 4Eh 
    marcos_horizontales:
        mov [col_aux],cl
        ;Superior
        posiciona_cursor 0,[col_aux]
        imprime_caracter_color marcoHor,cAmarillo,bgNegro
        ;Inferior
        posiciona_cursor 24,[col_aux]
        imprime_caracter_color marcoHor,cAmarillo,bgNegro
        ;Limite mouse
        posiciona_cursor 4,[col_aux]
        imprime_caracter_color marcoHor,cAmarillo,bgNegro
        mov cl,[col_aux]
        loop marcos_horizontales

        ;imprimir marcos verticales, derecho e izquierdo
        mov cx,23       ;CX = 0017h => CH = 00h, CL = 17h 
    marcos_verticales:
        mov [ren_aux],cl
        ;Izquierdo
        posiciona_cursor [ren_aux],0
        imprime_caracter_color marcoVer,cAmarillo,bgNegro
        ;Inferior
        posiciona_cursor [ren_aux],79
        imprime_caracter_color marcoVer,cAmarillo,bgNegro
        mov cl,[ren_aux]
        loop marcos_verticales

        ;imprimir marcos verticales internos
        mov cx,3        ;CX = 0003h => CH = 00h, CL = 03h 
    marcos_verticales_internos:
        mov [ren_aux],cl
        ;Interno izquierdo (marcador player 1)
        posiciona_cursor [ren_aux],7
        imprime_caracter_color marcoVer,cAmarillo,bgNegro

        ;Interno derecho (marcador player 2)
        posiciona_cursor [ren_aux],72
        imprime_caracter_color marcoVer,cAmarillo,bgNegro

        jmp marcos_verticales_internos_aux1
    marcos_verticales_internos_aux2:
        jmp marcos_verticales_internos
    marcos_verticales_internos_aux1:
        ;Interno central izquierdo (Timer)
        posiciona_cursor [ren_aux],32
        imprime_caracter_color marcoVer,cAmarillo,bgNegro

        ;Interno central derecho (Timer)
        posiciona_cursor [ren_aux],47
        imprime_caracter_color marcoVer,cAmarillo,bgNegro

        mov cl,[ren_aux]
        loop marcos_verticales_internos_aux2

        ;imprime intersecciones internas    
        posiciona_cursor 0,7
        imprime_caracter_color marcoCruceVerSup,cAmarillo,bgNegro
        posiciona_cursor 4,7
        imprime_caracter_color marcoCruceVerInf,cAmarillo,bgNegro

        posiciona_cursor 0,32
        imprime_caracter_color marcoCruceVerSup,cAmarillo,bgNegro
        posiciona_cursor 4,32
        imprime_caracter_color marcoCruceVerInf,cAmarillo,bgNegro

        posiciona_cursor 0,47
        imprime_caracter_color marcoCruceVerSup,cAmarillo,bgNegro
        posiciona_cursor 4,47
        imprime_caracter_color marcoCruceVerInf,cAmarillo,bgNegro

        posiciona_cursor 0,72
        imprime_caracter_color marcoCruceVerSup,cAmarillo,bgNegro
        posiciona_cursor 4,72
        imprime_caracter_color marcoCruceVerInf,cAmarillo,bgNegro

        posiciona_cursor 4,0
        imprime_caracter_color marcoCruceHorIzq,cAmarillo,bgNegro
        posiciona_cursor 4,79
        imprime_caracter_color marcoCruceHorDer,cAmarillo,bgNegro

        ;imprimir [X] para cerrar programa
        posiciona_cursor 0,76
        imprime_caracter_color '[',cAmarillo,bgNegro
        posiciona_cursor 0,77
        imprime_caracter_color 'X',cRojoClaro,bgNegro
        posiciona_cursor 0,78
        imprime_caracter_color ']',cAmarillo,bgNegro

        ;imprimir título
        posiciona_cursor 0,38
        imprime_cadena_color [titulo],4,cBlanco,bgNegro

        call IMPRIME_DATOS_INICIALES
        ret
    endp


    IMPRIME_DATOS_INICIALES proc
        ;mov [p1_score],0            ;inicializa el score del player 1
        ;mov [p2_score],0            ;inicializa el score del player 2

        ;Imprime el score del player 1, en la posición del col_aux
        ;la posición de ren_aux está fija en IMPRIME_SCORE_BL
        mov [col_aux],4
        mov bl,[p1_score]
        call IMPRIME_SCORE_BL

        ;Imprime el score del player 1, en la posición del col_aux
        ;la posición de ren_aux está fija en IMPRIME_SCORE_BL
        mov [col_aux],76
        mov bl,[p2_score]
        call IMPRIME_SCORE_BL

        ;imprime cadena 'Player 1'
        posiciona_cursor 2,9
        imprime_cadena_color player1,8,cBlanco,bgNegro
        
        ;imprime cadena 'Player 2'
        posiciona_cursor 2,63
        imprime_cadena_color player2,8,cBlanco,bgNegro

        ;imprime obstaculo
        ;; Deberan calcular la posicion de manera aleatoria
        ;; no debe salir del area de juego
        mov [col_aux],24
        mov [ren_aux],9
        call IMPRIME_OBSTACULO

        ;imprime obstaculo
        ;; Deberan calcular la posicion de manera aleatoria
        ;; no debe salir del area de juego
        mov [col_aux],60
        mov [ren_aux],8
        call IMPRIME_OBSTACULO

        ;imprime obstaculo
        ;; Deberan calcular la posicion de manera aleatoria
        ;; no debe salir del area de juego
        mov [col_aux],40
        mov [ren_aux],22
        call IMPRIME_OBSTACULO

        ;Botón Stop
        mov [boton_caracter],254d
        mov [boton_color],bgAmarillo
        mov [boton_renglon],1
        mov [boton_columna],34
        call IMPRIME_BOTON

        ;Botón Start
        mov [boton_caracter],16d
        mov [boton_color],bgAmarillo
        mov [boton_renglon],1
        mov [boton_columna],43d
        call IMPRIME_BOTON

        ret
    endp

    ;procedimiento IMPRIME_SCORE_BL
    ;Imprime el marcador de un jugador, poniendo la posición
    ;en renglón: 2, columna: col_aux
    ;El valor que imprime es el que se encuentre en el registro BL
    ;Obtiene cada caracter haciendo divisiones entre 10 y metiéndolos en
    ;la pila
    IMPRIME_SCORE_BL proc
        xor ah,ah
        mov al,bl
        mov [conta],0
    div10:
        xor dx,dx
        div [diez]
        push dx
        inc [conta]
        cmp ax,0
        ja div10
    imprime_digito:
        posiciona_cursor 2,[col_aux]
        pop dx
        or dl,30h
        imprime_caracter_color dl,cBlanco,bgNegro
        inc [col_aux]
        dec [conta]
        cmp [conta],0
        ja imprime_digito
        ret
    endp


    ;procedimiento para que aparezca la pelota
    ;Imprime el carácter ☻ (02h en ASCII) en la posición indicada por 
    ;las variables globales
    ;ren_aux y col_aux
    IMPRIME_BOLA proc
        posiciona_cursor [ren_aux],[col_aux]
        imprime_caracter_color 2d,cCyanClaro,bgNegro 
        ret
    endp


    BORRA_BARRA1 proc
        ; Borrar la barra actual en la posición actual
        posiciona_cursor p1_ren, p1_col
        imprime_caracter_color ' ', cNegro, bgNegro
        
        ; Borrar la barra dos posiciones a la izquierda
        posiciona_cursor p1_ren, p1_col - 2
        imprime_caracter_color ' ', cNegro, bgNegro

        ; Borrar la barra una posición a la izquierda
        posiciona_cursor p1_ren, p1_col - 1
        imprime_caracter_color ' ', cNegro, bgNegro

        ; Borrar la barra una posición a la derecha
        posiciona_cursor p1_ren, p1_col + 1
        imprime_caracter_color ' ', cNegro, bgNegro

        ; Borrar la barra dos posiciones a la derecha
        posiciona_cursor p1_ren, p1_col + 2
        imprime_caracter_color ' ', cNegro, bgNegro

        ret
    endp

    BORRA_BARRA2 proc
        ; Borrar la barra actual en la posición actual
        posiciona_cursor p2_ren, p2_col
        imprime_caracter_color ' ', cNegro, bgNegro
        
        ; Borrar la barra dos posiciones a la izquierda
        posiciona_cursor p2_ren, p2_col - 2
        imprime_caracter_color ' ', cNegro, bgNegro

        ; Borrar la barra una posición a la izquierda
        posiciona_cursor p2_ren, p2_col - 1
        imprime_caracter_color ' ', cNegro, bgNegro

        ; Borrar la barra una posición a la derecha
        posiciona_cursor p2_ren, p2_col + 1
        imprime_caracter_color ' ', cNegro, bgNegro

        ; Borrar la barra dos posiciones a la derecha
        posiciona_cursor p2_ren, p2_col + 2
        imprime_caracter_color ' ', cNegro, bgNegro

        ret
    endp

    ;Proc para que la pelota se mueva
    MOVER_PELOTA proc
        ; Verificar si es tiempo de mover la pelota
        call CONTEO_TICKS
        call TIEMPO_ESPERA    ;Asegura que la pelota se mueva a intervalos de tiempo específicos
        ;intervalo de espera que regula la frecuencia del movimiento de la pelota.mov cx, dx
        sub cx, [ticks_inicio] ;obtener el tiempo transcurrido.

        ; Borrar posición actual de la pelota
        posiciona_cursor pel_ren, pel_col
        imprime_caracter_color ' ', cBlanco, bgNegro

        ; Calcular nueva posición de la pelota
        mov al, [pel_ren]
        add al, [despel_v]
        mov [pel_ren], al

        mov al, [pel_col]
        add al, [despel_h]
        mov [pel_col], al

        ; Verificar colisión con bordes verticales
        cmp byte ptr [pel_col], 0    ; Borde izquierdo
        jl rebote_izquierda

        cmp byte ptr [pel_col], 78   ; Borde derecho (ajustado a 78 para evitar desbordamiento)
        jg rebote_derecha

        ; Verificar colisión con bordes horizontales
        cmp byte ptr [pel_ren], 7    ; Borde superior
        jl rebote_arriba

        cmp byte ptr [pel_ren], 21   ; Borde inferior
        jg rebote_abajo


        ; Verificar colisión con los obstáculos
        call VERIFICAR_OBSTACULOS

        ; Actualizar puntajes y verificar fin del juego
        cmp p1_score, 10    ; ¿Puntuación del jugador 1 es 10?
        je fin_del_juego    ; Saltar a fin_del_juego si es igual
        cmp p2_score, 10    ; ¿Puntuación del jugador 2 es 10?
        je fin_del_juego    ; Saltar a fin_del_juego si es igual


        jmp continuar_pelota

        fin_del_juego:
        mov [game_over], 1 ; Establecer bandera de fin del juego

        ; Reiniciar puntajes y posiciones
        mov [p1_score], 0    ; Reiniciar puntuación del jugador 1
        mov [p2_score], 0    ; Reiniciar puntuación del jugador 2
        mov [pel_col], 40    ; Posición inicial de la pelota en columna
        mov [pel_ren], 12    ; Posición inicial de la pelota en renglón

        ; Volver a dibujar la UI inicial
        call DIBUJA_UI

        ; Volver a dibujar las barras
        call DIBUJA_BARRA1
        call DIBUJA_BARRA2

        ; Volver a mover la pelota
        call MOVER_PELOTA

        cmp cx,36
        jle boton_stop

        ; Limpiar la pantalla antes de reiniciar
        clear

        ; Volver al inicio del juego
        jmp boton_start



        continuar_juego:
        ret


    rebote_izquierda:
        ; Aumentar puntos para el jugador 2
        inc [p2_score]
        ; Llama a IMPRIME_DATOS_INICIALES para actualizar la visualización del score
        call DIBUJA_UI
        ; Reiniciar posición de la pelota
        mov byte ptr [pel_col], 40
        mov byte ptr [pel_ren], 12
        jmp continuar_pelota

    rebote_derecha:
        ; Aumentar puntos para el jugador 1
        inc [p1_score]
        ; Llama a IMPRIME_DATOS_INICIALES para actualizar la visualización del score
        call DIBUJA_UI
        ; Reiniciar posición de la pelota
        mov byte ptr [pel_col], 40
        mov byte ptr [pel_ren], 12
        jmp continuar_pelota

    rebote_arriba:
        ; Invertir dirección vertical de la pelota
        neg [despel_v]
        jmp continuar_pelota

    rebote_abajo:
        ; Invertir dirección vertical de la pelota
        neg [despel_v]
        jmp continuar_pelota

    continuar_pelota:
        ; Verificar rebote en barra
        call VERIFICAR_P1

        ; Dibujar la pelota en su nueva posición
        posiciona_cursor pel_ren, pel_col
        imprime_caracter_color caracter, cCyanClaro, bgNegro

        ; Actualizar ticks
        call CONTEO_TICKS
        mov [ticks_inicio], dx

        ret
    MOVER_PELOTA endp


    OBSTACULO_RAMDONV proc
    mov al, dl
    and al, 45

    endp

    OBSTACULO_RAMDONH proc
    mov al, dl
    and al, 25
    endp




    VERIFICAR_OBSTACULOS proc
        ; Verificar colisión con el primer obstáculo
        mov al, [obstaculo1_col]
        cmp pel_col, al
        jne verificar_obstaculo2

        mov al, [obstaculo1_ren]
        cmp pel_ren, al
        je rebote_obstaculo

        verificar_obstaculo2:
        ; Verificar colisión con el segundo obstáculo
        mov al, [obstaculo2_col]
        cmp pel_col, al
        jne verificar_obstaculo3

        mov al, [obstaculo2_ren]
        cmp pel_ren, al
        je rebote_obstaculo

        verificar_obstaculo3:
        ; Verificar colisión con el tercer obstáculo
        mov al, [obstaculo3_col]
        cmp pel_col, al
        jne fin_verificar_obstaculos

        mov al, [obstaculo3_ren]
        cmp pel_ren, al
        je rebote_obstaculo

        fin_verificar_obstaculos:
        ret

    rebote_obstaculo:
        ; Invertir la dirección de la pelota (horizontal y vertical)
        neg [despel_h]
        neg [despel_v]
        ret
    VERIFICAR_OBSTACULOS endp


    ;Verificación de las colisiones con las barras
    VERIFICAR_P1 proc
        ; Verifica la colisión entre la pelota y la barra izquierda
        mov bl, p1_col
        cmp pel_col, bl
        jne verificar_p2

        ; Verificar si la pelota está en alguna de las posiciones de la barra del primer jugador
        mov bl, p1_ren
        cmp pel_ren, bl
        je rebote_der   ; Rebote hacia la derecha

        inc bl
        cmp pel_ren, bl
        je rebote_der   ; Rebote hacia la derecha

        inc bl
        cmp pel_ren, bl
        je rebote_der   ; Rebote hacia la derecha

        dec bl
        dec bl
        dec bl
        cmp pel_ren, bl
        je rebote_contrario_der   ; Rebote hacia la izquierda

        dec bl
        cmp pel_ren, bl
        je rebote_contrario_der   ; Rebote hacia la izquierda

        jmp fin_verificar_rebote

    verificar_p2:
        ; Verificar si la pelota está en la misma posición que la barra del segundo jugador
        mov bl, p2_col
        cmp pel_col, bl
        jne fin_verificar_rebote

        ; Verificar si la pelota está en alguna de las posiciones de la barra del segundo jugador
        mov bl, p2_ren
        cmp pel_ren, bl
        je rebote_contrario_der   ; Rebote hacia la izquierda

        inc bl
        cmp pel_ren, bl
        je rebote_contrario_der   ; Rebote hacia la izquierda

        inc bl
        cmp pel_ren, bl
        je rebote_contrario_der   ; Rebote hacia la izquierda

        dec bl
        dec bl
        dec bl
        cmp pel_ren, bl
        je rebote_der   ; Rebote hacia la derecha

        dec bl
        cmp pel_ren, bl
        je rebote_der   ; Rebote hacia la derecha

        jmp fin_verificar_rebote

    rebote_contrario_der:
        ; Invertir dirección horizontal de la pelota hacia la izquierda
        neg [despel_h]
        jmp fin_rebote

    rebote_der:
        ; Invertir dirección horizontal de la pelota hacia la derecha
        neg [despel_h]
        jmp fin_rebote

    fin_verificar_rebote:
        ret

    fin_rebote:
        ret
    endp


    TIEMPO_ESPERA proc
        mov ah, 86h
        mov cx, 0
        mov dx, 60000  ; representa la parte baja del tiempo en ticks. Se probo con valores de 30000 a 70000
        int 15h  ;espera por el intervalo de tiempo especificado por los valores en cx y dx
        ret
    endp


    CONTEO_TICKS proc
        ; Obtener el contador de ticks del sistema
        mov ah, 00h   ;registros cx y dx con el número de ticks del sistema, dx contiene la parte baja del contador de ticks y cx la parte alta.
        int 1Ah
        ret
    endp

    DIBUJA_BARRA1 proc
        ; Imprimir centro de la barra del primer jugador
        posiciona_cursor p1_ren, p1_col
        imprime_caracter_color 219, cBlanco, bgNegro

        ; Imprimir caracter una posición a la derecha del centro
        inc p1_ren
        posiciona_cursor p1_ren, p1_col
        imprime_caracter_color 219, cBlanco, bgNegro

        ; Imprimir caracter dos posiciones a la derecha del centro
        inc p1_ren
        posiciona_cursor p1_ren, p1_col
        imprime_caracter_color 219, cBlanco, bgNegro

        ; Restaurar valor de p1_ren
        sub p1_ren, 2

        ; Imprimir caracter una posición a la izquierda del centro
        dec p1_ren
        posiciona_cursor p1_ren, p1_col
        imprime_caracter_color 219, cBlanco, bgNegro

        ; Imprimir caracter dos posiciones a la izquierda del centro
        dec p1_ren
        posiciona_cursor p1_ren, p1_col
        imprime_caracter_color 219, cBlanco, bgNegro

        ; Restaurar valor de p1_ren
        add p1_ren, 2
        ret
    endp

    BORRAR_BARRA1 proc
        ; Imprimir espacio en el centro de la barra del primer jugador
        posiciona_cursor p1_ren, p1_col
        imprime_caracter_color ' ', cBlanco, bgNegro

        ; Imprimir espacio una posición a la derecha del centro
        inc p1_ren
        posiciona_cursor p1_ren, p1_col
        imprime_caracter_color ' ', cBlanco, bgNegro

        ; Imprimir espacio dos posiciones a la derecha del centro
        inc p1_ren
        posiciona_cursor p1_ren, p1_col
        imprime_caracter_color ' ', cBlanco, bgNegro

        ; Restaurar valor de p1_ren
        sub p1_ren, 2

        ; Imprimir espacio una posición a la izquierda del centro
        dec p1_ren
        posiciona_cursor p1_ren, p1_col
        imprime_caracter_color ' ', cBlanco, bgNegro

        ; Imprimir espacio dos posiciones a la izquierda del centro
        dec p1_ren
        posiciona_cursor p1_ren, p1_col
        imprime_caracter_color ' ', cBlanco, bgNegro

        ; Restaurar valor de p1_ren
        add p1_ren, 2
        ret
    endp

    DIBUJA_BARRA2 proc
        ; Imprimir centro de la barra del segundo jugador
        posiciona_cursor p2_ren, p2_col
        imprime_caracter_color 219, cBlanco, bgNegro

        ; Imprimir caracter una posición a la derecha del centro
        inc p2_ren
        posiciona_cursor p2_ren, p2_col
        imprime_caracter_color 219, cBlanco, bgNegro

        ; Imprimir caracter dos posiciones a la derecha del centro
        inc p2_ren
        posiciona_cursor p2_ren, p2_col
        imprime_caracter_color 219, cBlanco, bgNegro

        ; Restaurar valor de p2_ren
        sub p2_ren, 2

        ; Imprimir caracter una posición a la izquierda del centro
        dec p2_ren
        posiciona_cursor p2_ren, p2_col
        imprime_caracter_color 219, cBlanco, bgNegro

        ; Imprimir caracter dos posiciones a la izquierda del centro
        dec p2_ren
        posiciona_cursor p2_ren, p2_col
        imprime_caracter_color 219, cBlanco, bgNegro

        ; Restaurar valor de p2_ren
        add p2_ren, 2
        ret
    endp

    BORRAR_BARRA2 proc
        ; Imprimir espacio en el centro de la barra del segundo jugador
        posiciona_cursor p2_ren, p2_col
        imprime_caracter_color ' ', cBlanco, bgNegro

        ; Imprimir espacio una posición a la derecha del centro
        inc p2_ren
        posiciona_cursor p2_ren, p2_col
        imprime_caracter_color ' ', cBlanco, bgNegro

        ; Imprimir espacio dos posiciones a la derecha del centro
        inc p2_ren
        posiciona_cursor p2_ren, p2_col
        imprime_caracter_color ' ', cBlanco, bgNegro

        ; Restaurar valor de p2_ren
        sub p2_ren, 2

        ; Imprimir espacio una posición a la izquierda del centro
        dec p2_ren
        posiciona_cursor p2_ren, p2_col
        imprime_caracter_color ' ', cBlanco, bgNegro

        ; Imprimir espacio dos posiciones a la izquierda del centro
        dec p2_ren
        posiciona_cursor p2_ren, p2_col
        imprime_caracter_color ' ', cBlanco, bgNegro

        ; Restaurar valor de p2_ren
        add p2_ren, 2
        ret
    endp

    ;procedimiento IMPRIME_BOTON
    ;Dibuja un boton que abarca 3 renglones y 3 columnas
    ;con un caracter centrado dentro del boton
    ;en la posición que se especifique (esquina superior izquierda)
    ;y de un color especificado
    ;Utiliza paso de parametros por variables globales
    ;Las variables utilizadas son:
    ;boton_caracter: debe contener el caracter que va a mostrar el boton
    ;boton_renglon: contiene la posicion del renglon en donde inicia el boton
    ;boton_columna: contiene la posicion de la columna en donde inicia el boton
    ;boton_color: contiene el color del boton
    IMPRIME_BOTON proc
        ;La esquina superior izquierda se define en registro CX y define el inicio del botón
        ;La esquina inferior derecha se define en registro DX y define el final del botón
        ;utilizando opción 06h de int 10h
        ;el color del botón se define en BH
        mov ax,0600h            ;AH=06h (scroll up window) AL=00h (borrar)
        mov bh,cRojo            ;Caracteres en color rojo dentro del botón, los 4 bits menos significativos de BH
        xor bh,[boton_color]    ;Color de fondo en los 4 bits más significativos de BH
        mov ch,[boton_renglon]  ;Renglón de la esquina superior izquierda donde inicia el boton
        mov cl,[boton_columna]  ;Columna de la esquina superior izquierda donde inicia el boton
        mov dh,ch               ;Copia el renglón de la esquina superior izquierda donde inicia el botón
        add dh,2                ;Incrementa el valor copiado por 2, para poner el renglón final
        mov dl,cl               ;Copia la columna de la esquina superior izquierda donde inicia el botón
        add dl,2                ;Incrementa el valor copiado por 2, para poner la columna final
        int 10h
        ;se recupera los valores del renglón y columna del botón
        ;para posicionar el cursor en el centro e imprimir el 
        ;carácter en el centro del botón
        mov [col_aux],dl                
        mov [ren_aux],dh
        dec [col_aux]
        dec [ren_aux]
        posiciona_cursor [ren_aux],[col_aux]
        imprime_caracter_color [boton_caracter],cRojo,[boton_color]
        ret             ;Regreso de llamada a procedimiento
    endp                ;Indica fin de procedimiento para el ensamblador

    ;procedimiento IMPRIME_OBSTACULO
    ;Dibuja un obstaculo en el area de juego
    ;Utiliza paso de parametros por variables globales
    ;Las variables utilizadas son:
    ;col_aux: valor de la columna de la esquina superior izquierda en donde comienza a dibujarse el obstáculo
    ;ren_aux: valor del renglon  de la esquina superior izquierda en donde comienza a dibujarse el obstáculo
    IMPRIME_OBSTACULO proc
    ; Imprimir el primer obstáculo
    posiciona_cursor obstaculo1_ren, obstaculo1_col
    imprime_caracter_color 178, cBlanco, cNegro

    ; Imprimir el segundo obstáculo
    posiciona_cursor obstaculo2_ren, obstaculo2_col
    imprime_caracter_color 178, cBlanco, cNegro

    ; Imprimir el tercer obstáculo
    posiciona_cursor obstaculo3_ren, obstaculo3_col
    imprime_caracter_color 178, cBlanco, cNegro

    ret
    endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;FIN PROCEDIMIENTOS;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;