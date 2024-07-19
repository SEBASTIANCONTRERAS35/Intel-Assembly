title "Comparación de Números" ; Descripción breve del programa
.model small   
.stack 64       
.data           

; Definición de variables
num1 db 25      
num2 db 20      

msg1 db 'El primer numero es mayor al segundo', '$'
msg2 db 'El segundo numero es mayor al primero', '$'
msg3 db 'Los dos numeros son iguales', '$'

.code          
inicio:         
    mov ax, @data    
    mov ds, ax

    ; Cargar los valores de las variables en los registros
    mov al, num1    
    mov bl, num2    

    ; Comparar los dos números
    cmp al, bl
    jg primer_mayor 
    jl segundo_mayor 

    
    mov dx, offset msg3
    jmp imprimir

primer_mayor:
    mov dx, offset msg1
    jmp imprimir

segundo_mayor:
    mov dx, offset msg2

imprimir:
  
    mov ah, 09h       
    int 21h           

salir:              
    mov ax, 4C00h    
    int 21h          

end inicio          





