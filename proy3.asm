  title "Proyecto: Jazlaga" ;codigo opcional. Descripcion breve del programa, el texto entrecomillado se imprime como cabecera en cada página de código
    .model small  ;directiva de modelo de memoria, small => 64KB para memoria de programa y 64KB para memoria de datos
    .386      ;directiva para indicar version del procesador
    .stack 128    ;Define el tamano del segmento de stack, se mide en bytes
    .data     ;Definicion del segmento de datos
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;Definición de constantes
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;Valor ASCII de caracteres para el marco del programa
  marcoEsqInfIzq    equ   200d  ;'╚'
  marcoEsqInfDer    equ   188d  ;'╝'
  marcoEsqSupDer    equ   187d  ;'╗'
  marcoEsqSupIzq    equ   201d  ;'╔'
  marcoCruceVerSup  equ   203d  ;'╦'
  marcoCruceHorDer  equ   185d  ;'╣'
  marcoCruceVerInf  equ   202d  ;'╩'
  marcoCruceHorIzq  equ   204d  ;'╠'
  marcoCruce      equ   206d  ;'╬'
  marcoHor      equ   205d  ;'═'
  marcoVer      equ   186d  ;'║'
  ;Atributos de color de BIOS
  ;Valores de color para carácter
  cNegro      equ   00h
  cAzul       equ   01h
  cVerde      equ   02h
  cCyan       equ   03h
  cRojo       equ   04h
  cMagenta    equ   05h
  cCafe       equ   06h
  cGrisClaro    equ   07h
  cGrisOscuro   equ   08h
  cAzulClaro    equ   09h
  cVerdeClaro   equ   0Ah
  cCyanClaro    equ   0Bh
  cRojoClaro    equ   0Ch
  cMagentaClaro equ   0Dh
  cAmarillo     equ   0Eh
  cBlanco     equ   0Fh
  ;Valores de color para fondo de carácter
  bgNegro     equ   00h
  bgAzul      equ   10h
  bgVerde     equ   20h
  bgCyan      equ   30h
  bgRojo      equ   40h
  bgMagenta     equ   50h
  bgCafe      equ   60h
  bgGrisClaro   equ   70h
  bgGrisOscuro  equ   80h
  bgAzulClaro   equ   90h
  bgVerdeClaro  equ   0A0h
  bgCyanClaro   equ   0B0h
  bgRojoClaro   equ   0C0h
  bgMagentaClaro  equ   0D0h
  bgAmarillo    equ   0E0h
  bgBlanco    equ   0F0h
  ;Valores para delimitar el área de juego
  lim_superior  equ   1
  lim_inferior  equ   23
  lim_izquierdo   equ   1
  lim_derecho   equ   39
  ;Valores de referencia para la posición inicial del jugador
  ini_columna   equ   lim_derecho/2
  ini_renglon   equ   22

  ;Valores para la posición de los controles e indicadores dentro del juego
  ;Lives
  lives_col     equ   lim_derecho+7
  lives_ren     equ   4

  ;Scores
  hiscore_ren   equ   11
  hiscore_col   equ   lim_derecho+7
  score_ren   equ   13
  score_col     equ   lim_derecho+7

  ;Botón STOP
  stop_col    equ   lim_derecho+10
  stop_ren    equ   19
  stop_izq    equ   stop_col-1
  stop_der    equ   stop_col+1
  stop_sup    equ   stop_ren-1
  stop_inf    equ   stop_ren+1

  ;Botón PAUSE
  pause_col     equ   stop_col+10
  pause_ren     equ   19
  pause_izq     equ   pause_col-1
  pause_der     equ   pause_col+1
  pause_sup     equ   pause_ren-1
  pause_inf     equ   pause_ren+1

  ;Botón PLAY
  play_col    equ   pause_col+10
  play_ren    equ   19
  play_izq    equ   play_col-1
  play_der    equ   play_col+1
  play_sup    equ   play_ren-1
  play_inf    equ   play_ren+1

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;////////////////////////////////////////////////////
  ;Definición de variables
  ;////////////////////////////////////////////////////
  titulo      db    "GALAGA"
  scoreStr      db    "SCORE"
  hiscoreStr    db    "HI-SCORE"
  livesStr      db    "LIVES"
  blank       db    "     "
  player_lives    db    3
  player_score    dw    0
  player_hiscore  dw    0

  player_col    db    ini_columna   ;posicion en columna del jugador
  player_ren    db    ini_renglon   ;posicion en renglon del jugador

  enemy_col   db    ini_columna   ;posicion en columna del enemigo
  enemy_ren   db    3         ;posicion en renglon del enemigo

  col_aux     db    0     ;variable auxiliar para operaciones con posicion - columna
  ren_aux     db    0     ;variable auxiliar para operaciones con posicion - renglon

  conta       db    0     ;contador

  ;; Variables de ayuda para lectura de tiempo del sistema
  tick_ms     dw    55    ;55 ms por cada tick del sistema, esta variable se usa para operación de MUL convertir ticks a segundos
  mil       dw    1000  ;1000 auxiliar para operación DIV entre 1000
  diez        dw    10    ;10 auxiliar para operaciones
  sesenta     db    60    ;60 auxiliar para operaciones
  status      db    0     ;0 stop, 1 play, 2 pause
  ticks       dw    0     ;Variable para almacenar el número de ticks del sistema y usarlo como referencia

  ;Variables que sirven de parámetros de entrada para el procedimiento IMPRIME_BOTON
  boton_caracter  db    0
  boton_renglon   db    0
  boton_columna   db    0
  boton_color   db    0
  boton_bg_color  db    0


  ;Auxiliar para calculo de coordenadas del mouse en modo Texto
  ocho      db    8
  ;Cuando el driver del mouse no está disponible
  no_mouse    db  'No se encuentra driver de mouse. Presione [enter] para salir$'



  ;Variables agregadas
  bool_tecla_buffer  equ   00FFh   ; Variable para determinar si se ha presionado una tecla
  lim_mov_izq   equ   05h   ; Variable que guarda el limite de desplazamiento izquierdo de las naves
  lim_mov_der   equ   lim_derecho - 4h  ; Variable que guarda el limite de desplazamiento derecho de las naves
  temp_cx     dw    0h    ; Variable que guarda el estado de CX de manera temporal, esto debido al uso del registro
                  ; en posiciona_cursor, alterando loops declarados

  bool_mov_enemigo_abajo    db   0h ;
  mov_nave_enemiga_aux     db    0h    ; Auxiliar para indicar el movimiento del enemigo
  disparo_enemigo     equ     207d ; Gráfico del disparo del enemigo
  disparo_jugador     equ     42d ; Gráfico del disparo del enemigo

  disparo_ren_enemigo   db  6h ;    
  disparo_col_enemigo   db  ini_columna ;

  disparo_ren_jugador   db  ini_renglon - 3 ; 
  disparo_col_jugador   db  ini_columna ;

  mov_disparo_jugador_aux db 0h ;

  numero_ticks        dw  0h ;
  segundos_sistema    dw  0h ; 
  ;milisegundos_100_sistema dw 0h ;

  milisegundos_sistema  dw  0h;

  momento_mueve_disparo_enemigo_ticks  dw  0h ;
  momento_mueve_enemigo_ticks dw  0h ;

  temp_general  dw  0h ;


  bool_juego_iniciado   db  0h ;
  bool_pausa            db  0h ;
  bool_stop             db  0h ;

  tecla_buffer          db  0h ;

  momento_milisegundos_leido  dw  0h;
  momento_segundos_leido      dw  0h;

  hitbox_ren_aux_enemigo  db    0
  hitbox_col_aux_enemigo  db    0
  hitbox_ren_aux_jugador  db    0
  hitbox_col_aux_jugador  db    0




  ;////////////////////////////////////////////////////

  ;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;Macros;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;
  ;clear - Limpia pantalla
  clear macro
    mov ax,0003h  ;ah = 00h, selecciona modo video
            ;al = 03h. Modo texto, 16 colores
    int 10h   ;llama interrupcion 10h con opcion 00h. 
          ;Establece modo de video limpiando pantalla
  endm

  ;posiciona_cursor - Cambia la posición del cursor a la especificada con 'renglon' y 'columna' 
  posiciona_cursor macro renglon,columna
    mov dh,renglon  ;dh = renglon
    mov dl,columna  ;dl = columna
    mov bx,0
    mov ax,0200h  ;preparar ax para interrupcion, opcion 02h
    int 10h     ;interrupcion 10h y opcion 02h. Cambia posicion del cursor
  endm 

  ;inicializa_ds_es - Inicializa el valor del registro DS y ES
  inicializa_ds_es  macro
    mov ax,@data
    mov ds,ax
    mov es,ax
        ;Este registro se va a usar, junto con BP, para imprimir cadenas utilizando interrupción 10h
  endm

  ;muestra_cursor_mouse - Establece la visibilidad del cursor del mouser
  muestra_cursor_mouse  macro
    mov ax,1    ;opcion 0001h
    int 33h     ;int 33h para manejo del mouse. Opcion AX=0001h
            ;Habilita la visibilidad del cursor del mouse en el programa
  endm

  ;posiciona_cursor_mouse - Establece la posición inicial del cursor del mouse
  posiciona_cursor_mouse  macro columna,renglon
    mov dx,renglon
    mov cx,columna
    mov ax,4    ;opcion 0004h
    int 33h     ;int 33h para manejo del mouse. Opcion AX=0001h
            ;Habilita la visibilidad del cursor del mouse en el programa
  endm

  ;oculta_cursor_teclado - Oculta la visibilidad del cursor del teclado
  oculta_cursor_teclado macro
    mov ah,01h    ;Opcion 01h
    mov cx,2607h  ;Parametro necesario para ocultar cursor
    int 10h     ;int 10, opcion 01h. Cambia la visibilidad del cursor del teclado
  endm

  ;apaga_cursor_parpadeo - Deshabilita el parpadeo del cursor cuando se imprimen caracteres con fondo de color
  ;Habilita 16 colores de fondo
  apaga_cursor_parpadeo macro
    mov ax,1003h    ;Opcion 1003h
    xor bl,bl       ;BL = 0, parámetro para int 10h opción 1003h
      int 10h       ;int 10, opcion 01h. Cambia la visibilidad del cursor del teclado
  endm

  ;imprime_caracter_color - Imprime un caracter de cierto color en pantalla, especificado por 'caracter', 'color' y 'bg_color'. 
  ;Los colores disponibles están en la lista a continuacion;
  ; Colores:
  ; 0h: Negro
  ; 1h: Azul
  ; 2h: Verde
  ; 3h: Cyan
  ; 4h: Rojo
  ; 5h: Magenta
  ; 6h: Cafe
  ; 7h: Gris Claro
  ; 8h: Gris Oscuro
  ; 9h: Azul Claro
  ; Ah: Verde Claro
  ; Bh: Cyan Claro
  ; Ch: Rojo Claro
  ; Dh: Magenta Claro
  ; Eh: Amarillo
  ; Fh: Blanco
  ; utiliza int 10h opcion 09h
  ; 'caracter' - caracter que se va a imprimir
  ; 'color' - color que tomará el caracter
  ; 'bg_color' - color de fondo para el carácter en la celda
  ; Cuando se define el color del carácter, éste se hace en el registro BL:
  ; La parte baja de BL (los 4 bits menos significativos) define el color del carácter
  ; La parte alta de BL (los 4 bits más significativos) define el color de fondo "background" del carácter
  imprime_caracter_color macro caracter,color,bg_color
    mov ah,09h        ;preparar AH para interrupcion, opcion 09h
    mov al,caracter     ;AL = caracter a imprimir
    mov bh,0        ;BH = numero de pagina
    mov bl,color      
    or bl,bg_color      ;BL = color del caracter
                ;'color' define los 4 bits menos significativos 
                ;'bg_color' define los 4 bits más significativos 
    mov cx,1        ;CX = numero de veces que se imprime el caracter
                ;CX es un argumento necesario para opcion 09h de int 10h
    int 10h         ;int 10h, AH=09h, imprime el caracter en AL con el color BL
  endm

  ;imprime_caracter_color - Imprime un caracter de cierto color en pantalla, especificado por 'caracter', 'color' y 'bg_color'. 
  ; utiliza int 10h opcion 09h
  ; 'cadena' - nombre de la cadena en memoria que se va a imprimir
  ; 'long_cadena' - longitud (en caracteres) de la cadena a imprimir
  ; 'color' - color que tomarán los caracteres de la cadena
  ; 'bg_color' - color de fondo para los caracteres en la cadena
  imprime_cadena_color macro cadena,long_cadena,color,bg_color
    mov ah,13h        ;preparar AH para interrupcion, opcion 13h
    lea bp,cadena       ;BP como apuntador a la cadena a imprimir
    mov bh,0        ;BH = numero de pagina
    mov bl,color      
    or bl,bg_color      ;BL = color del caracter
                ;'color' define los 4 bits menos significativos 
                ;'bg_color' define los 4 bits más significativos 
    mov cx,long_cadena    ;CX = longitud de la cadena, se tomarán este número de localidades a partir del apuntador a la cadena
    int 10h         ;int 10h, AH=09h, imprime el caracter en AL con el color BL
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
  lee_mouse macro
    mov ax,0003h
    int 33h
  endm

  ;comprueba_mouse - Revisa si el driver del mouse existe
  comprueba_mouse   macro
    mov ax,0    ;opcion 0
    int 33h     ;llama interrupcion 33h para manejo del mouse, devuelve un valor en AX
            ;Si AX = 0000h, no existe el driver. Si AX = FFFFh, existe driver
  endm

  comprueba_teclado macro
    posiciona_cursor player_ren, player_col
    imprime_caracter_color 219,cBlanco,bgNegro
    mov ah, 0Bh
    int 21h
    cmp al, bool_tecla_buffer
  endm

  ; Lee un caracter del teclado o almacenado en el buffer de caracteres, guardandolo en AL
  lee_teclado   macro
    mov ax, 0100h
    int 21h
    mov tecla_buffer, al
    posiciona_cursor [player_ren],[player_col]
    imprime_caracter_color 219,cBlanco,bgNegro
  endm

  ; Realiza un delay en el programa de 30ms
  delay macro
    mov temp_cx, cx
    mov cx, 00h
    mov dx, 7530h
    mov ah, 86h
    int 15h
    mov cx, temp_cx
  endm



  reseto_reloj    macro
    mov ah, 01h
    mov cx, 00h
    mov dx, 00h
    int 1Ah
  endm

  lee_reloj macro
    mov ah, 00h
    int 1Ah
    mov ticks, dx

    mov ax, ticks
    mul tick_ms

    mov ticks, ax
  endm

  ;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;Fin Macros;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;

    .code
  inicio:         ;etiqueta inicio
    inicializa_ds_es
    reseto_reloj
    comprueba_mouse   ;macro para revisar driver de mouse
    xor ax,0FFFFh   ;compara el valor de AX con FFFFh, si el resultado es zero, entonces existe el driver de mouse
    jz imprime_ui   ;Si existe el driver del mouse, entonces salta a 'imprime_ui'
    ;Si no existe el driver del mouse entonces se muestra un mensaje
    lea dx,[no_mouse]
    mov ax,0900h  ;opcion 9 para interrupcion 21h
    int 21h     ;interrupcion 21h. Imprime cadena.
    jmp teclado   ;salta a 'teclado'
  imprime_ui:
    clear           ;limpia pantalla
    oculta_cursor_teclado ;oculta cursor del mouse
    apaga_cursor_parpadeo   ;Deshabilita parpadeo del cursor
    call DIBUJA_UI      ;procedimiento que dibuja marco de la interfaz
    muestra_cursor_mouse  ;hace visible el cursor del mouse

  empieza_juego:
    reseto_reloj
    call mouse_no_clic

  ; Comprueba si se ha ingresado un tecla, de otro modo comprueba el estado del mouse
  tecla_ingresada:
    cmp bool_juego_iniciado, 00h
    je empieza_juego
    call momento_sistema
    call mov_disparo_jugador

  comprobacion_teclado:
    comprueba_teclado
    jne mouse_no_clic
    je tecla_presionada

  ; Si se ha ingresado una tecla, se decida si la nave se mueve a la izquierda o a la derecha
  tecla_presionada:
    lee_teclado
    cmp tecla_buffer, 61h
    je permitir_movimiento_izquierdo_jugador

    cmp tecla_buffer, 64h
    je permitir_movimiento_derecho_jugador

    cmp tecla_buffer, 112d
    je shoot_player

    jmp tecla_ingresada

  ; En caso de que la posicion de la nave sea mayor que el limite izquierdo, la nave se mueve a la izquierda
  permitir_movimiento_izquierdo_jugador:
    cmp player_col, lim_mov_izq
    jg mov_izquierda_jugador
    je tecla_ingresada

  ; En caso de que la posicion de la nave sea menor que el limite derecho, la nave se mueve a la derecha
  permitir_movimiento_derecho_jugador:
    cmp player_col, lim_mov_der
    jb mov_derecha_jugador
    je tecla_ingresada


  ; En caso de que la posicion de la nave sea mayor que el limite izquierdo, la nave se mueve a la izquierda
  permitir_movimiento_izquierdo_enemigo:
    cmp enemy_col, lim_mov_izq
    jg mov_izquierda_enemigo
    je cambia_estado_direccion_derecha
    ret

  ; En caso de que la posicion de la nave sea menor que el limite derecho, la nave se mueve a la derecha
  permitir_movimiento_derecho_enemigo:
    cmp enemy_col, lim_mov_der
    jb mov_derecha_enemigo
    je cambia_estado_direccion_izquierda
    ret

  ; En caso se que haya un cambio de dirección, se altera mov_nave_enemiga_aux para determinar el movimiento del enemigo
  cambia_estado_direccion_izquierda:
    call BORRA_ENEMIGO
    mov mov_nave_enemiga_aux, 01h
    inc enemy_ren
    call mov_izquierda_enemigo
    ret

  ; En caso se que haya un cambio de dirección, se altera mov_nave_enemiga_aux para determinar el movimiento del enemigo
  cambia_estado_direccion_derecha:
    call BORRA_ENEMIGO
    mov mov_nave_enemiga_aux, 00h 
    inc enemy_ren
    call mov_derecha_enemigo
    ret

  ; Verifica el estado de mov_nave_enemiga_aux para definir hacia donde se mueve el enemigo
  mueve_enemigo:
    mov ax, milisegundos_sistema
    mov momento_segundos_leido, ax

    cmp mov_nave_enemiga_aux, 00h
    je permitir_movimiento_derecho_enemigo
    jne permitir_movimiento_izquierdo_enemigo
    ret

  shoot_player:
    cmp mov_disparo_jugador_aux, 01h
    je tecla_ingresada
    mov al, player_col
    mov disparo_col_jugador, al
    mov disparo_ren_jugador, ini_renglon - 3
    mov mov_disparo_jugador_aux, 01h
    ret


  ; Cuando se golpea al enemigo, se aumenta el score en 1 y se reinicia la posición del enemigo
  golpe_enemigo:
    inc [player_score]
    call IMPRIME_SCORE
    call BORRA_ENEMIGO
    call IMPRIME_ENEMIGO_POS_ORIGINAL
    call reiniciar_disparo_jugador
    ret

  ; Cuando el jugador es golpeado por un disparo enemigo se le resta 1 a las vidas hasta que estas llegan a 0
  golpe_jugador:
    cmp player_lives, 1
    je cero_vidas

    call BORRAR_LIVES
    dec player_lives
    call IMPRIME_LIVES
    call reiniciar_disparo_enemigo
    ret   

  ; Cuando el jugador se queda sin vidas, estas se reinician a su valor inicial antes de terminar el juego para la siguienrte ronda
  cero_vidas:
    mov player_lives, 3
    call IMPRIME_LIVES
    mov bool_juego_iniciado, 00h
    jmp boton_stop

  ;En "mouse_no_clic" se revisa que el boton izquierdo del mouse no esté presionado
  ;Si el botón está suelto, continúa a la sección "mouse"
  ;si no, se mantiene indefinidamente en "mouse_no_clic" hasta que se suelte

  mouse_no_clic:
    lee_mouse
    test bx,0001h
    jz tecla_ingresada

  ;Lee el mouse y avanza hasta que se haga clic en el boton izquierdo
  mouse:
    lee_mouse
  conversion_mouse:
    ;Leer la posicion del mouse y hacer la conversion a resolucion
    ;80x25 (columnas x renglones) en modo texto
    mov ax,dx       ;Copia DX en AX. DX es un valor entre 0 y 199 (renglon)
    div [ocho]      ;Division de 8 bits
              ;divide el valor del renglon en resolucion 640x200 en donde se encuentra el mouse
              ;para obtener el valor correspondiente en resolucion 80x25
    xor ah,ah       ;Descartar el residuo de la division anterior
    mov dx,ax       ;Copia AX en DX. AX es un valor entre 0 y 24 (renglon)

    mov ax,cx       ;Copia CX en AX. CX es un valor entre 0 y 639 (columna)
    div [ocho]      ;Division de 8 bits
              ;divide el valor de la columna en resolucion 640x200 en donde se encuentra el mouse
              ;para obtener el valor correspondiente en resolucion 80x25
    xor ah,ah       ;Descartar el residuo de la division anterior
    mov cx,ax       ;Copia AX en CX. AX es un valor entre 0 y 79 (columna)

    ;Aquí se revisa si se hizo clic en el botón izquierdo
    test bx,0001h     ;Para revisar si el boton izquierdo del mouse fue presionado
    jz mouse      ;Si el boton izquierdo no fue presionado, vuelve a leer el estado del mouse

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;Aqui va la lógica de la posicion del mouse;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;Si el mouse fue presionado en el renglon 0
    ;se va a revisar si fue dentro del boton [X]
    
    ;comp pausa
    cmp bool_pausa, 1h
    je play_pausa
    cmp bool_stop, 1h
    je play_stop

    
    cmp dx,0
    je boton_x
    cmp dx,20
    je mas_botones

    cmp bool_juego_iniciado, 00h
    je empieza_juego
    jne tecla_ingresada
    jmp mouse_no_clic
  play_pausa:
    cmp dx,0
    je boton_x
    cmp dx, 20
    je pausa1
    jne mouse
  pausa1:
    cmp cx, play_col+1
    je boton_play
    jne pausa2
  pausa2:
    cmp cx, stop_col+1
    je boton_stop
    jne mouse
  play_stop:
    cmp dx,0
    je boton_x
    cmp dx, 20
    je stop1
    jne mouse
  stop1:
    cmp cx, play_col+1
    je boton_play
    jne mouse
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

  mas_botones:
    cmp cx, stop_col+1
    je  boton_stop
    cmp cx, pause_col+1
    je boton_pause
    cmp cx, play_col+1
    je boton_play
    jmp mouse_no_clic
  boton_stop:
    mov bool_stop, 1h
    mov bool_pausa, 0h
    call BORRA_DISPARO_ENEMIGO
    call BORRA_DISPARO_JUGADOR
    call BORRA_JUGADOR
    call BORRA_ENEMIGO
    mov bl, ini_columna
    mov bh, 3h
    mov enemy_col, bl
    mov enemy_ren, bh
    mov player_col, bl
    mov ax, player_score
    cmp player_hiscore, ax
    jb cambia_hiscore
    cmp bool_juego_iniciado, 00h
    je reinicio_juego
    mov bool_juego_iniciado, 00h
    jmp reinicio_juego
  cambia_hiscore:
    mov player_hiscore,ax
    jmp reinicio_juego
  reinicio_juego:
    mov player_lives, 03h
    mov player_score, 00h
    call IMPRIME_JUGADOR
    call IMPRIME_ENEMIGO
    call IMPRIME_SCORES
    call IMPRIME_LIVES
    jmp empieza_juego
  boton_pause:
    mov bool_pausa, 1h
    cmp bool_juego_iniciado, 00h
    je empieza_juego
    jne mouse
  boton_play:
    mov bool_pausa, 0h
    mov bool_stop, 0h
    mov bool_juego_iniciado, 01h
    jmp tecla_ingresada

  ;Si no se encontró el driver del mouse, muestra un mensaje y el usuario debe salir tecleando [enter]
  teclado:
    mov ah,08h
    int 21h
    cmp al,0Dh    ;compara la entrada de teclado si fue [enter]
    jnz teclado   ;Sale del ciclo hasta que presiona la tecla [enter]

  salir:        ;inicia etiqueta salir
    clear       ;limpia pantalla
    mov ax,4C00h  ;AH = 4Ch, opción para terminar programa, AL = 0 Exit Code, código devuelto al finalizar el programa
    int 21h     ;señal 21h de interrupción, pasa el control al sistema operativo

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;PROCEDIMIENTOS;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    momento_sistema proc
      call segundos
      call mueve_enemigo_ticks
      call mueve_disparo_enemigo_ticks
      ret
    endp

    mueve_disparo_enemigo_ticks  proc
      mov temp_general, 1d
      mov ax, milisegundos_sistema
      mov dx, 0h
      div temp_general

      cmp dx, 0000h
      je mueve_disparo_enemigo_ticks_true
      jne mueve_disparo_enemigo_ticks_false
      ret
    endp

    mueve_disparo_enemigo_ticks_true proc
      mov momento_mueve_disparo_enemigo_ticks, 01h
      mov ax, momento_milisegundos_leido
      cmp milisegundos_sistema, ax
      jne mov_disparo_enemigo
      ret
    endp

    mueve_disparo_enemigo_ticks_false proc
      mov momento_mueve_disparo_enemigo_ticks, 00h
      ;delay
      ret
    endp

    mueve_enemigo_ticks  proc
      mov temp_general, 2d
      mov ax, milisegundos_sistema
      mov dx, 0h
      div temp_general

      cmp dx, 0000h
      je mueve_enemigo_ticks_true
      jne mueve_enemigo_ticks_false
      ret
    endp

    mueve_enemigo_ticks_true proc
      mov momento_mueve_enemigo_ticks, 01h
      mov ax, momento_segundos_leido
      cmp milisegundos_sistema, ax
      jne mueve_enemigo
      ret
    endp

    mueve_enemigo_ticks_false proc
      mov momento_mueve_enemigo_ticks, 00h
      ;delay
      ret
    endp

    


    ; Obtiene el numero de ticks que han pasado desde el inicio del sistema, convirtiendolos a segundos y guardando el resultado en segundos_sistema
    segundos    proc  
      ;delay
      ;inc milisegundos_sistema
      lee_reloj
      ; mov numero_ticks, 18d
      ; mov ax, ticks
      ; mov dx, 0
      ; div numero_ticks

      ; mov segundos_sistema, ax

      ; mov numero_ticks, 2d
      ; mov ax, ticks
      ; mov dx, 0
      ; div numero_ticks

      mov ax, ticks
      mov milisegundos_sistema, ax


      ret
    endp

    ; Mueve una posicion a la izquierda la nave
    mov_izquierda_jugador proc
      call BORRA_JUGADOR

      sub player_col, 2h

      call IMPRIME_JUGADOR
      call mov_disparo_jugador
      jmp tecla_ingresada 
    endp

    ; Mueve una posicion a la derecha la nave
    mov_derecha_jugador proc
      call BORRA_JUGADOR

      add player_col, 2h

      call IMPRIME_JUGADOR
      call mov_disparo_jugador
      jmp tecla_ingresada
    endp

    ; Mueve una posicion a la izquierda la nave enemiga
    mov_izquierda_enemigo proc
      
      call BORRA_ENEMIGO
      dec enemy_col
      call IMPRIME_ENEMIGO
      call CALCULAR_HITBOX_JUGADOR
      ret
    endp

    ; Mueve una posicion a la derecha la nave enemiga
    mov_derecha_enemigo proc
      
      call BORRA_ENEMIGO
      inc enemy_col
      call IMPRIME_ENEMIGO
      call CALCULAR_HITBOX_JUGADOR
      ret
    endp

    IMPRIME_DISPARO_ENEMIGO proc
      mov al,[disparo_col_enemigo]
      mov ah,[disparo_ren_enemigo]
      mov [col_aux],al
      mov [ren_aux],ah
      posiciona_cursor [ren_aux],[col_aux]
      imprime_caracter_color disparo_enemigo,cRojo,bgNegro
      ret
    endp

    BORRA_DISPARO_ENEMIGO proc
      mov al,[disparo_col_enemigo]
      mov ah,[disparo_ren_enemigo]
      mov [col_aux],al
      mov [ren_aux],ah
      posiciona_cursor [ren_aux],[col_aux]
      imprime_caracter_color disparo_enemigo,cNegro,bgNegro
      ret
    endp

    mov_disparo_enemigo proc
      mov ax, milisegundos_sistema
      mov momento_milisegundos_leido, ax
      ;cmp mov_disparo_jugador_aux, 00h
      ;je tecla_ingresada
      call BORRA_DISPARO_ENEMIGO
      cmp disparo_ren_enemigo, 23d
      je reiniciar_disparo_enemigo
      inc disparo_ren_enemigo
      call IMPRIME_DISPARO_ENEMIGO
      ;delay
      ret
    endp

    reiniciar_disparo_enemigo proc
      call BORRA_DISPARO_ENEMIGO
      mov al, enemy_col
      mov ah, enemy_ren
      add ah, 3h
      mov disparo_ren_enemigo, ah
      mov disparo_col_enemigo, al
      call IMPRIME_JUGADOR
      jmp tecla_ingresada
    endp
  
    IMPRIME_DISPARO_JUGADOR proc
      mov al,[disparo_col_jugador]
      mov ah,[disparo_ren_jugador]
      mov [col_aux],al
      mov [ren_aux],ah
      posiciona_cursor [ren_aux],[col_aux]
      imprime_caracter_color disparo_jugador,cBlanco,bgNegro
      ret
    endp

    BORRA_DISPARO_JUGADOR proc
      mov al,[disparo_col_jugador]
      mov ah,[disparo_ren_jugador]
      mov [col_aux],al
      mov [ren_aux],ah
      posiciona_cursor [ren_aux],[col_aux]
      imprime_caracter_color disparo_jugador,cNegro,bgNegro
      ret
    endp

    mov_disparo_jugador proc
      cmp mov_disparo_jugador_aux, 01h
      jne comprobacion_teclado
      call BORRA_DISPARO_JUGADOR
      call CALCULAR_HITBOX_ENEMIGO
      cmp disparo_ren_jugador, 1h 
      je reiniciar_disparo_jugador
      dec disparo_ren_jugador
      call IMPRIME_DISPARO_JUGADOR
      delay
      ret
    endp

    reiniciar_disparo_jugador proc
      call BORRA_DISPARO_JUGADOR
      mov al, player_col
      mov disparo_col_jugador, al
      mov disparo_ren_jugador, ini_renglon - 3
      mov mov_disparo_jugador_aux, 00h
      jmp tecla_ingresada
    endp


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
      mov cx,78     ;CX = 004Eh => CH = 00h, CL = 4Eh 
    marcos_horizontales:
      mov [col_aux],cl
      ;Superior
      posiciona_cursor 0,[col_aux]
      imprime_caracter_color marcoHor,cAmarillo,bgNegro
      ;Inferior
      posiciona_cursor 24,[col_aux]
      imprime_caracter_color marcoHor,cAmarillo,bgNegro

      mov cl,[col_aux]
      loop marcos_horizontales

      ;imprimir marcos verticales, derecho e izquierdo
      mov cx,23     ;CX = 0017h => CH = 00h, CL = 17h 
    marcos_verticales:
      mov [ren_aux],cl
      ;Izquierdo
      posiciona_cursor [ren_aux],0
      imprime_caracter_color marcoVer,cAmarillo,bgNegro
      ;Inferior
      posiciona_cursor [ren_aux],79
      imprime_caracter_color marcoVer,cAmarillo,bgNegro
      ;Limite mouse
      posiciona_cursor [ren_aux],lim_derecho+1
      imprime_caracter_color marcoVer,cAmarillo,bgNegro

      mov cl,[ren_aux]
      loop marcos_verticales

      ;imprimir marcos horizontales internos
      mov cx,79-lim_derecho-1     
    marcos_horizontales_internos:
      push cx
      mov [col_aux],cl
      add [col_aux],lim_derecho
      ;Interno superior 
      posiciona_cursor 8,[col_aux]
      imprime_caracter_color marcoHor,cAmarillo,bgNegro

      ;Interno inferior
      posiciona_cursor 16,[col_aux]
      imprime_caracter_color marcoHor,cAmarillo,bgNegro

      mov cl,[col_aux]
      pop cx
      loop marcos_horizontales_internos

      ;imprime intersecciones internas  
      posiciona_cursor 0,lim_derecho+1
      imprime_caracter_color marcoCruceVerSup,cAmarillo,bgNegro
      posiciona_cursor 24,lim_derecho+1
      imprime_caracter_color marcoCruceVerInf,cAmarillo,bgNegro

      posiciona_cursor 8,lim_derecho+1
      imprime_caracter_color marcoCruceHorIzq,cAmarillo,bgNegro
      posiciona_cursor 8,79
      imprime_caracter_color marcoCruceHorDer,cAmarillo,bgNegro

      posiciona_cursor 16,lim_derecho+1
      imprime_caracter_color marcoCruceHorIzq,cAmarillo,bgNegro
      posiciona_cursor 16,79
      imprime_caracter_color marcoCruceHorDer,cAmarillo,bgNegro

      ;imprimir [X] para cerrar programa
      posiciona_cursor 0,76
      imprime_caracter_color '[',cAmarillo,bgNegro
      posiciona_cursor 0,77
      imprime_caracter_color 'X',cRojoClaro,bgNegro
      posiciona_cursor 0,78
      imprime_caracter_color ']',cAmarillo,bgNegro

      ;imprimir título
      posiciona_cursor 0,37
      imprime_cadena_color [titulo],6,cAmarillo,bgNegro

      call IMPRIME_TEXTOS

      call IMPRIME_BOTONES

      call IMPRIME_DATOS_INICIALES

      call IMPRIME_SCORES

      call IMPRIME_LIVES

      ret
    endp

    IMPRIME_TEXTOS proc
      ;Imprime cadena "LIVES"
      posiciona_cursor lives_ren,lives_col
      imprime_cadena_color livesStr,5,cGrisClaro,bgNegro

      ;Imprime cadena "SCORE"
      posiciona_cursor score_ren,score_col
      imprime_cadena_color scoreStr,5,cGrisClaro,bgNegro

      ;Imprime cadena "HI-SCORE"
      posiciona_cursor hiscore_ren,hiscore_col
      imprime_cadena_color hiscoreStr,8,cGrisClaro,bgNegro
      ret
    endp

    IMPRIME_BOTONES proc
      ;Botón STOP
      mov [boton_caracter],254d   ;Carácter '■'
      mov [boton_color],bgAmarillo  ;Background amarillo
      mov [boton_renglon],stop_ren  ;Renglón en "stop_ren"
      mov [boton_columna],stop_col  ;Columna en "stop_col"
      call IMPRIME_BOTON        ;Procedimiento para imprimir el botón
      ;Botón PAUSE
      mov [boton_caracter],19d    ;Carácter '‼'
      mov [boton_color],bgAmarillo  ;Background amarillo
      mov [boton_renglon],pause_ren   ;Renglón en "pause_ren"
      mov [boton_columna],pause_col   ;Columna en "pause_col"
      call IMPRIME_BOTON        ;Procedimiento para imprimir el botón
      ;Botón PLAY
      mov [boton_caracter],16d      ;Carácter '►'
      mov [boton_color],bgAmarillo  ;Background amarillo
      mov [boton_renglon],play_ren  ;Renglón en "play_ren"
      mov [boton_columna],play_col  ;Columna en "play_col"
      call IMPRIME_BOTON        ;Procedimiento para imprimir el botón
      ret
    endp

    IMPRIME_SCORES proc
      ;Imprime el valor de la variable player_score en una posición definida
      call IMPRIME_SCORE
      ;Imprime el valor de la variable player_hiscore en una posición definida
      call IMPRIME_HISCORE
      ret
    endp

    IMPRIME_SCORE proc
      ;Imprime "player_score" en la posición relativa a 'score_ren' y 'score_col'
      mov [ren_aux],score_ren
      mov [col_aux],score_col+20
      mov bx,[player_score]
      call IMPRIME_BX
      ret
    endp

    IMPRIME_HISCORE proc
    ;Imprime "player_score" en la posición relativa a 'hiscore_ren' y 'hiscore_col'
      mov [ren_aux],hiscore_ren
      mov [col_aux],hiscore_col+20
      mov bx,[player_hiscore]
      call IMPRIME_BX
      ret
    endp

    ;BORRA_SCORES borra los marcadores numéricos de pantalla sustituyendo la cadena de números por espacios
    BORRA_SCORES proc
      call BORRA_SCORE
      call BORRA_HISCORE
      ret
    endp

    BORRA_SCORE proc
      posiciona_cursor score_ren,score_col+20     ;posiciona el cursor relativo a score_ren y score_col
      imprime_cadena_color blank,5,cBlanco,bgNegro  ;imprime cadena blank (espacios) para "borrar" lo que está en pantalla
      ret
    endp

    BORRA_HISCORE proc
      posiciona_cursor hiscore_ren,hiscore_col+20   ;posiciona el cursor relativo a hiscore_ren y hiscore_col
      imprime_cadena_color blank,5,cBlanco,bgNegro  ;imprime cadena blank (espacios) para "borrar" lo que está en pantalla
      ret
    endp

    ;Imprime el valor del registro BX como entero sin signo (positivo)
    ;Se imprime con 5 dígitos (incluyendo ceros a la izquierda)
    ;Se usan divisiones entre 10 para obtener dígito por dígito en un LOOP 5 veces (una por cada dígito)
    IMPRIME_BX proc
      mov temp_cx, cx
      mov ax,bx
      mov cx,5
    div10:
      xor dx,dx
      div [diez]
      push dx
      loop div10
      mov cx,5
    imprime_digito:
      mov [conta],cl
      posiciona_cursor [ren_aux],[col_aux]
      pop dx
      or dl,30h
      imprime_caracter_color dl,cBlanco,bgNegro
      xor ch,ch
      mov cl,[conta]
      inc [col_aux]
      loop imprime_digito
      mov cx, temp_cx
      ret
    endp

    IMPRIME_DATOS_INICIALES proc
      call DATOS_INICIALES    ;inicializa variables de juego
      ;imprime la 'nave' del jugador
      ;borra la posición actual, luego se reinicia la posición y entonces se vuelve a imprimir  -----> Se eliminó la linea ya que no tenia utilidad
      mov [player_col], ini_columna
      mov [player_ren], ini_renglon
      ;Imprime jugador
      call IMPRIME_JUGADOR

      ;Borrar posicion actual del enemigo y reiniciar su posicion

      ;Imprime enemigo
      call IMPRIME_ENEMIGO

      ret
    endp

    ;Inicializa variables del juego
    DATOS_INICIALES proc
      mov [player_score],0
      mov [player_lives], 3
      ret
    endp

    ;Imprime los caracteres ☻ que representan vidas. Inicialmente se imprime el número de 'player_lives'
    IMPRIME_LIVES proc
      xor cx,cx
      mov di,lives_col+20
      mov cl,[player_lives]
    imprime_live:
      push cx
      mov ax,di
      posiciona_cursor lives_ren,al
      imprime_caracter_color 3d,cRojo,bgNegro
      add di,3
      pop cx
      loop imprime_live
      ret
    endp

    ;Imprime la nave del jugador, que recibe como parámetros las variables ren_aux y col_aux, que indican la posición central inferior
    PRINT_PLAYER proc

      posiciona_cursor [ren_aux],[col_aux]
      imprime_caracter_color 219,cBlanco,bgNegro
      dec [ren_aux]
      posiciona_cursor [ren_aux],[col_aux]
      imprime_caracter_color 219,cBlanco,bgNegro
      dec [ren_aux]
      posiciona_cursor [ren_aux],[col_aux]
      imprime_caracter_color 219,cBlanco,bgNegro
      add [ren_aux],2

      dec [col_aux]
      posiciona_cursor [ren_aux],[col_aux]
      imprime_caracter_color 219,cBlanco,bgNegro
      dec [ren_aux]
      posiciona_cursor [ren_aux],[col_aux]
      imprime_caracter_color 219,cBlanco,bgNegro
      inc [ren_aux]

      dec [col_aux]
      posiciona_cursor [ren_aux],[col_aux]
      imprime_caracter_color 219,cBlanco,bgNegro

      add [col_aux],3
      posiciona_cursor [ren_aux],[col_aux]
      imprime_caracter_color 219,cBlanco,bgNegro
      dec [ren_aux]
      posiciona_cursor [ren_aux],[col_aux]
      imprime_caracter_color 219,cBlanco,bgNegro
      inc [ren_aux]

      inc [col_aux]
      posiciona_cursor [ren_aux],[col_aux]
      imprime_caracter_color 219,cBlanco,bgNegro
      ret
    endp

    ;Borra la nave del jugador, que recibe como parámetros las variables ren_aux y col_aux, que indican la posición central de la barra
    ;Imprime caracteres negros para borrar la nave
    DELETE_PLAYER proc
      posiciona_cursor [ren_aux],[col_aux]
      imprime_caracter_color 219,cNegro,bgNegro
      dec [ren_aux]
      posiciona_cursor [ren_aux],[col_aux]
      imprime_caracter_color 219,cNegro,bgNegro
      dec [ren_aux]
      posiciona_cursor [ren_aux],[col_aux]
      imprime_caracter_color 219,cNegro,bgNegro
      add [ren_aux],2

      dec [col_aux]
      posiciona_cursor [ren_aux],[col_aux]
      imprime_caracter_color 219,cNegro,bgNegro
      dec [ren_aux]
      posiciona_cursor [ren_aux],[col_aux]
      imprime_caracter_color 219,cNegro,bgNegro
      inc [ren_aux]

      dec [col_aux]
      posiciona_cursor [ren_aux],[col_aux]
      imprime_caracter_color 219,cNegro,bgNegro

      add [col_aux],3
      posiciona_cursor [ren_aux],[col_aux]
      imprime_caracter_color 219,cNegro,bgNegro
      dec [ren_aux]
      posiciona_cursor [ren_aux],[col_aux]
      imprime_caracter_color 219,cNegro,bgNegro
      inc [ren_aux]

      inc [col_aux]
      posiciona_cursor [ren_aux],[col_aux]
      imprime_caracter_color 219,cNegro,bgNegro

      ret
    endp

    ;Imprime la nave del enemigo
    PRINT_ENEMY proc

      posiciona_cursor [ren_aux],[col_aux]
      imprime_caracter_color 178,cRojo,bgNegro
      inc [ren_aux]
      posiciona_cursor [ren_aux],[col_aux]
      imprime_caracter_color 178,cRojo,bgNegro
      inc [ren_aux]
      posiciona_cursor [ren_aux],[col_aux]
      imprime_caracter_color 178,cRojo,bgNegro
      sub [ren_aux],2

      dec [col_aux]
      posiciona_cursor [ren_aux],[col_aux]
      imprime_caracter_color 178,cRojo,bgNegro
      inc [ren_aux]
      posiciona_cursor [ren_aux],[col_aux]
      imprime_caracter_color 178,cRojo,bgNegro
      dec [ren_aux]

      dec [col_aux]
      posiciona_cursor [ren_aux],[col_aux]
      imprime_caracter_color 178,cRojo,bgNegro

      add [col_aux],3
      posiciona_cursor [ren_aux],[col_aux]
      imprime_caracter_color 178,cRojo,bgNegro
      inc [ren_aux]
      posiciona_cursor [ren_aux],[col_aux]
      imprime_caracter_color 178,cRojo,bgNegro
      dec [ren_aux]

      inc [col_aux]
      posiciona_cursor [ren_aux],[col_aux]
      imprime_caracter_color 178,cRojo,bgNegro
      ret
    endp

    DELETE_ENEMY proc

      posiciona_cursor [ren_aux],[col_aux]
      imprime_caracter_color 178,cNegro,bgNegro
      inc [ren_aux]
      posiciona_cursor [ren_aux],[col_aux]
      imprime_caracter_color 178,cNegro,bgNegro
      inc [ren_aux]
      posiciona_cursor [ren_aux],[col_aux]
      imprime_caracter_color 178,cNegro,bgNegro
      sub [ren_aux],2

      dec [col_aux]
      posiciona_cursor [ren_aux],[col_aux]
      imprime_caracter_color 178,cNegro,bgNegro
      inc [ren_aux]
      posiciona_cursor [ren_aux],[col_aux]
      imprime_caracter_color 178,cNegro,bgNegro
      dec [ren_aux]

      dec [col_aux]
      posiciona_cursor [ren_aux],[col_aux]
      imprime_caracter_color 178,cNegro,bgNegro

      add [col_aux],3
      posiciona_cursor [ren_aux],[col_aux]
      imprime_caracter_color 178,cNegro,bgNegro
      inc [ren_aux]
      posiciona_cursor [ren_aux],[col_aux]
      imprime_caracter_color 178,cNegro,bgNegro
      dec [ren_aux]

      inc [col_aux]
      posiciona_cursor [ren_aux],[col_aux]
      imprime_caracter_color 178,cNegro,bgNegro
      ret
    endp

    ;procedimiento IMPRIME_BOTON
    ;Dibuja un boton que abarca 3 renglones y 5 columnas
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
      ;background de botón
      mov ax,0600h    ;AH=06h (scroll up window) AL=00h (borrar)
      mov bh,cRojo    ;Caracteres en color amarillo
      xor bh,[boton_color]
      mov ch,[boton_renglon]
      mov cl,[boton_columna]
      mov dh,ch
      add dh,2
      mov dl,cl
      add dl,2
      int 10h
      mov [col_aux],dl
      mov [ren_aux],dh
      dec [col_aux]
      dec [ren_aux]
      posiciona_cursor [ren_aux],[col_aux]
      imprime_caracter_color [boton_caracter],cRojo,[boton_color]
      ret       ;Regreso de llamada a procedimiento
    endp        ;Indica fin de procedimiento UI para el ensamblador

    BORRA_JUGADOR proc
      mov temp_cx, cx
      mov al,[player_col]
      mov ah,[player_ren]
      mov [col_aux],al
      mov [ren_aux],ah
      call DELETE_PLAYER
      mov cx, temp_cx
      ret
    endp

    IMPRIME_JUGADOR proc
      mov temp_cx, cx
      mov al,[player_col]
      mov ah,[player_ren]
      mov [col_aux],al
      mov [ren_aux],ah
      call PRINT_PLAYER
      mov cx, temp_cx
      ret
    endp

    IMPRIME_ENEMIGO proc
      mov al,[enemy_col]
      mov ah,[enemy_ren]
      mov [col_aux],al
      mov [ren_aux],ah
      call PRINT_ENEMY
      ret
    endp

    BORRA_ENEMIGO proc
      mov temp_cx, cx
      mov al,[enemy_col]
      mov ah,[enemy_ren]
      mov [col_aux],al
      mov [ren_aux],ah
      call DELETE_ENEMY
      mov cx, temp_cx
      ret
    endp

  CALCULAR_HITBOX_ENEMIGO proc
        mov bl, [enemy_ren]
        mov hitbox_ren_aux_enemigo, bl
        mov bh, [enemy_col]
        mov hitbox_col_aux_enemigo, bh

        mov al, disparo_ren_jugador
        mov ah, disparo_col_jugador

        add hitbox_ren_aux_enemigo, 2
        cmp al, hitbox_ren_aux_enemigo    ; cmp al, hitbox_ren_aux_enemigo+2
        jne ren1_enemigo
        cmp ah, hitbox_col_aux_enemigo    ; cmp ah, hitbox_col_aux_enemigo
        je golpe_enemigo
        jne ren1_enemigo

      ren1_enemigo:
        mov hitbox_ren_aux_enemigo, bl
        add hitbox_ren_aux_enemigo, 1
        cmp al, hitbox_ren_aux_enemigo    ; cmp al, hitbox_ren_aux_enemigo+1
        jne ren_enemigo
        cmp ah, hitbox_col_aux_enemigo    ; cmp ah, hitbox_col_aux_enemigo
        je golpe_enemigo
        dec hitbox_col_aux_enemigo
        cmp ah, hitbox_col_aux_enemigo    ; cmp ah, hitbox_col_aux_enemigo-1
        je golpe_enemigo
        add hitbox_col_aux_enemigo, 2
        cmp ah, hitbox_col_aux_enemigo    ; cmp ah, hitbox_col_aux_enemigo+1
        je golpe_enemigo
        jne ren_enemigo

      ren_enemigo:
        mov hitbox_ren_aux_enemigo, bl
        mov hitbox_col_aux_enemigo, bh
        cmp al, hitbox_ren_aux_enemigo    ; cmp al, hitbox_ren_aux_enemigo
        jne no_golpe_enemigo
        cmp ah, hitbox_col_aux_enemigo    ; cmp ah, hitbox_col_aux_enemigo
        je golpe_enemigo
        dec hitbox_col_aux_enemigo
        cmp ah, hitbox_col_aux_enemigo    ; cmp ah, hitbox_col_aux_enemigo-1
        je golpe_enemigo
        dec hitbox_col_aux_enemigo
        cmp ah, hitbox_col_aux_enemigo    ; cmp ah, hitbox_col_aux_enemigo-2
        je golpe_enemigo  
        add hitbox_col_aux_enemigo, 3
        cmp ah, hitbox_col_aux_enemigo    ; cmp ah, hitbox_col_aux_enemigo+1
        je golpe_enemigo
        inc hitbox_col_aux_enemigo
        cmp ah, hitbox_col_aux_enemigo    ; cmp ah, hitbox_col_aux_enemigo+2
        je golpe_enemigo  

      no_golpe_enemigo:
        ret
    endp

    IMPRIME_ENEMIGO_POS_ORIGINAL proc
      call BORRA_ENEMIGO
      call BORRA_DISPARO_ENEMIGO
      mov bl, ini_columna
      mov bh, 3h
      mov enemy_col, bl
      mov enemy_ren, 3h
      call IMPRIME_ENEMIGO
      ret 
    endp

    CALCULAR_HITBOX_JUGADOR proc
      mov bl, [player_ren]
        mov hitbox_ren_aux_jugador, bl
        mov bh, [player_col]
        mov hitbox_col_aux_jugador, bh

        mov al, disparo_ren_enemigo
        mov ah, disparo_col_enemigo

        sub hitbox_ren_aux_jugador, 2
        cmp al, hitbox_ren_aux_jugador    
        jne ren1_jugador
        cmp ah, hitbox_col_aux_jugador    
        je golpe_jugador
        jne ren1_jugador

      ren1_jugador:
        mov hitbox_ren_aux_jugador, bl
        sub hitbox_ren_aux_jugador, 1
        cmp al, hitbox_ren_aux_jugador    
        jne ren_jugador
        cmp ah, hitbox_col_aux_jugador    
        je golpe_jugador
        dec hitbox_col_aux_jugador
        cmp ah, hitbox_col_aux_jugador    
        je golpe_jugador
        add hitbox_col_aux_jugador, 2
        cmp ah, hitbox_col_aux_jugador    
        je golpe_jugador
        jne ren_jugador

      ren_jugador:
        mov hitbox_ren_aux_jugador, bl
        mov hitbox_col_aux_jugador, bh
        cmp al, hitbox_ren_aux_jugador    
        jne no_golpe_jugador
        cmp ah, hitbox_col_aux_jugador    
        je golpe_jugador
        dec hitbox_col_aux_jugador
        cmp ah, hitbox_col_aux_jugador    
        je golpe_jugador
        dec hitbox_col_aux_jugador
        cmp ah, hitbox_col_aux_jugador    
        je golpe_jugador  
        add hitbox_col_aux_jugador, 3
        cmp ah, hitbox_col_aux_jugador    
        je golpe_jugador
        inc hitbox_col_aux_jugador
        cmp ah, hitbox_col_aux_jugador
        je golpe_jugador

      no_golpe_jugador:
        ret
    endp

    CALCULAR_HITBOX_COLISION proc
      mov bl, [player_ren]
      mov bh, [player_col] 

      mov al, [enemy_ren]
      mov bh, [enemy_col]
      add al, 2

      sub bl, 2h
      cmp al, bl
      jne ren1_col
      cmp ah, bh
      je cero_vidas
      jne ren1_col

    ren1_col:
      mov bl, [player_ren]
      sub bl, 1
      cmp al, bl    
      jne ren_col
      cmp ah, bh    
      je cero_vidas
      dec bh
      cmp ah, bh    
      je cero_vidas
      add bh, 2
      cmp ah, bh    
      je cero_vidas
      jne ren_col

    ren_col:
      mov bl, [player_ren]
      mov bh, [player_col]
      cmp al, bl    
      jne no_colision
      cmp ah, bh 
      je cero_vidas
      dec bh
      cmp ah, bh    
      je cero_vidas
      dec bh
      cmp ah, bh    
      je cero_vidas  
      add bh, 3
      cmp ah, bh    
      je cero_vidas
      inc bh
      cmp ah, bh
      je cero_vidas

    no_colision:
      ret
    endp

    BORRAR_LIVES proc
      xor cx,cx
        mov di,lives_col+20
        mov cl,[player_lives]
    borrar_live:
        push cx
        mov ax,di
        posiciona_cursor lives_ren,al
        imprime_caracter_color 3d,cNegro,bgNegro
        add di,3
        pop cx
        loop borrar_live
      ret
    endp

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;FIN PROCEDIMIENTOS;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
  end inicio      ;fin de etiqueta inicio, fin de programa