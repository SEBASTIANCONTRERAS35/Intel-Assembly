.model small    ; Definimos el modelo de memoria
.stack 100h     ; Definimos el tamaño de la pila

.data           ; Segmento de datos
x dw 60         ; Variable x inicializada con 60 (palabra de 16 bits)
y dw 162        ; Variable y inicializada con 162 (palabra de 16 bits)
z dw ?          ; Variable z inicializada con un valor desconocido (palabra de 16 bits)

.code           ; Segmento de código
main PROC       ; Inicio del procedimiento principal

    mov ax, [x]     ; Cargamos el valor de x en ax
    imul ax, [x]    ; Multiplicamos ax por x (x * x)
    mov bx, 6       ; Multiplicamos por 6
    imul ax, bx     ; Resultado de 6*x*x en ax

    mov bx, [y]     ; Cargamos el valor de y en bx
    mov cx, 12      ; Movemos 12 a cx
    idiv cx         ; Dividimos dx:ax (resultado de la multiplicación) por 12
                    ; El resultado queda en ax (cociente) y el residuo en dx
    mov dx, 5       ; Movemos 5 a dx
    idiv dx         ; Dividimos ax (resultado de la división anterior) por 5
                    ; El resultado queda en ax (cociente) y el residuo en dx
    sub ax, [x]     ; Restamos el valor de x al resultado anterior
    imul bx, ax     ; Multiplicamos y por el resultado anterior

    mov ax, [x]     ; Cargamos el valor de x en ax
    mov bx, 15      ; Movemos 15 a bx
    imul ax, bx     ; Multiplicamos ax por 15
    add ax, bx      ; Sumamos el resultado anterior a bx (15*x)

    mov bx, 3000    ; Movemos 3000 a bx
    sub ax, bx      ; Restamos bx al resultado anterior (15*x - 3000)

    mov [z], ax     ; Almacenamos el resultado final en la variable z

    mov ah, 4Ch     ; Función para terminar el programa
    int 21h         ; Interrupción 21h (servicio de DOS)

main ENDP       ; Fin del procedimiento principal
end main        ; Fin del programa
