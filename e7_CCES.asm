title "Conversión de mayúsculas a minúsculas y viceversa"
.model small
.stack 100h

.data
    cadena db "Hola, Mundo! 123 ABC xyz.", 0 ; La cadena a modificar, terminada en 0 (null)
    mensaje db "La cadena modificada es: $"

.code
main proc
    ; Inicializar segmento de datos
    mov ax, @data
    mov ds, ax
    mov es, ax

    ; Cargar dirección de la cadena en SI
    lea si, cadena

convertir:
    ; Leer carácter actual
    mov al, [si]
    cmp al, 0           ; Verificar si es el final de la cadena
    je imprimir_cadena

    ; Convertir mayúscula a minúscula
    cmp al, 'A'
    jl no_mayuscula
    cmp al, 'Z'
    jg no_mayuscula
    add al, 32          ; Convertir a minúscula (A-Z -> a-z)
    jmp almacenar

no_mayuscula:
    ; Convertir minúscula a mayúscula
    cmp al, 'a'
    jl no_minuscula
    cmp al, 'z'
    jg no_minuscula
    sub al, 32          ; Convertir a mayúscula (a-z -> A-Z)
    jmp almacenar

no_minuscula:
    ; No se hace modificación
    jmp almacenar

almacenar:
    ; Almacenar el carácter modificado o no modificado
    mov [si], al

    ; Avanzar al siguiente carácter
    inc si
    jmp convertir

imprimir_cadena:
    ; Imprimir mensaje
    mov dx, offset mensaje
    mov ah, 09h
    int 21h

    ; Imprimir cadena modificada
    mov dx, offset cadena
    mov ah, 09h
    int 21h

    ; Terminar programa
    mov ax, 4C00h
    int 21h

main endp
end main
