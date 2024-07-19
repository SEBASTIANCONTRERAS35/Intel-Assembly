title "Operaciones de transferencia"

.model small
.386
.stack 64

.data
temp1 dw ? ; Variable temporal para almacenar valores temporales
temp2 dw ? ; Variable temporal para almacenar valores temporales

.code
inicio:
    ; Inicializar los registros AX, BX, CX y DX con los valores dados
    mov ax, 5AC0h   ; AX = 5AC0h
    mov bx, 0F3C1h  ; BX = F3C1h (Asegúrate de usar el prefijo 0x para valores hexadecimales)
    mov cx, 0E16Dh  ; CX = E16Dh (Asegúrate de usar el prefijo 0x para valores hexadecimales)
    mov dx, 0021h   ; DX = 0021h

    ; Intercambio de valores entre registros utilizando variables temporales
    mov temp1, ax   ; Guardar el valor de AX en temp1
    mov ax, bx      ; Cargar el valor de BX en AX
    mov bx, dx      ; Cargar el valor de DX en BX
    mov temp2, cx   ; Guardar el valor de CX en temp2
    mov cx, temp1   ; Cargar el valor original de AX (guardado en temp1) en CX
    mov dx, temp2   ; Cargar el valor original de CX (guardado en temp2) en DX

    ; Mostrar los valores finales de los registros (opcional)
    ; Puedes agregar aquí código adicional para mostrar los valores de los registros

    ; Terminar el programa
    mov ah, 4Ch     ; AH = 4Ch, opción para terminar programa
    mov al, 0       ; AL = 0, Exit Code, código devuelto al finalizar el programa
    int 21h         ; Interrupción 21h para terminar el programa

end inicio          ; Fin del programa y especificación del punto de inicio

