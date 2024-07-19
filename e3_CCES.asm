.model small
.386
.stack 100h

.data
X dw -132       ; Definir la variable X con valor -132 (decimal)
Y dw 120        ; Definir la variable Y con valor 120 (decimal)
res1 dw ?       ; Variable para almacenar res1
res2 dw ?       ; Variable para almacenar res2
res3 dw ?       ; Variable para almacenar res3

.code
inicio:
    mov ax, X
    add ax, Y
    sub ax, -35
    add ax, 53
    mov res1, ax
    mov ax, res1
    add ax, 1
    mov res2, ax
    mov ax, res1
    mov res3, ax
    mov ah, 4Ch     
    int 21h         

end inicio
