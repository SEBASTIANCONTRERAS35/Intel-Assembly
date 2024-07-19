title "Hola mundo!" ; Descripción opcional del programa
.model small ; Modelo de memoria: small
.stack 64 ; Tamaño del segmento de pila: 64 bytes

.data ; Segmento de datos
hola db "Hola mundo!",0Dh,0Ah,"$" ; Cadena a imprimir
count dw 20 ; Contador para el bucle

.code ; Segmento de código
inicio: ; Etiqueta de inicio

    mov ax, @data ; Cargar la dirección del segmento de datos en AX
    mov ds, ax ; Configurar DS para que apunte al segmento de datos

    mov cx, [count] ; Cargar el valor de 'count' en CX

    ; Bucle para imprimir la cadena 20 veces
    imprimir_bucle:
        lea dx, [hola] ; Cargar la dirección de 'hola' en DX
        mov ah, 09h ; Función de impresión de cadena
        int 21h ; Llamada a la interrupción 21h (DOS)
        
        dec cx ; Decrementar CX
        jnz imprimir_bucle ; Saltar al bucle si CX no es cero

    ; Fin del programa
    mov ah, 4Ch ; Función para terminar el programa
    mov al, 0 ; Código de salida
    int 21h ; Llamada a la interrupción 21h (DOS)

end inicio ; Fin del programa
