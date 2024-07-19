.model small
.386
.stack 100h

.data
mensaje db 105, "Hola!", 0Dh, 0Ah, "Este es un ejercicio de programaci", 162, "n en lenguaje ensamblador.", 0Dh, 0Ah
        db 105, "Ya s", 130, " imprimir en pantalla! =)", 0Dh, 0Ah, "Fin.$"

.code
inicio:
    mov ax, @data       ; Cargar dirección de inicio de los datos en AX
    mov ds, ax          ; Cargar la dirección en el registro de segmento de datos (DS)

    lea dx, mensaje     ; Cargar la dirección del mensaje en DX
    mov ah, 09h         ; Cargar el número de la función de servicio (09h para imprimir cadena)
    int 21h             ; Llamar a la interrupción 21h para imprimir el mensaje

    mov ah, 4Ch         ; Cargar el número de la función de servicio (4Ch para terminar programa)
    mov al, 0           ; Cargar el código de retorno (0) en AL
    int 21h             ; Llamar a la interrupción 21h para terminar el programa

end inicio             ; Fin del programa y especificación del punto de inicio
