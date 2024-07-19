title "Ejercicio 3"
    .model small    ;small --> 64KB para memoria de programa y 64 KB para memoria de datos
    .386            ;directiva para indicar la versión del procesador
    .stack 64       ;definición del tamaño de stack en bytes
    .data           ;definición del segmento de dato
num1        dw      6790h,0BF93h,0C642h,078Ah,1D53h,40B7h,0E50Ah,75B9h      ;num1 = 75B9E50A40B71D53078AC642BF936790h
num2        dw      0F58Dh,75B3h,07E3h,5F31h,70D7h,85E2h,076Ch,0BC40h       ;num1 = BC40076C85E270D75F3107E375B3F58Dh
suma        dw      0,0,0,0,0,0,0,0,0       ;se agrega un noveno espacio para el acarreo
resta       dw      0,0,0,0,0,0,0,0,0       ;se agrega un noveno espacio para el acarreo
    .code               ;segmento de código
inicio:                 ;etiqueta de inicio
    mov ax,@data        ;AX = directova @data
    mov ds,ax           ;DS = AX, inicializa segmento de datos
    
    ;SUMA
    clc                     ;C=0
    mov ax,[num1]           ;AX = 6790h
    adc ax,[num2]           ;AX = 6790h + F58Dh + 0
    mov [suma],ax           ;suma = 5D1Dh
    ;C=1
    mov ax,[num1+2]         ;AX = BF93h
    adc ax,[num2+2]         ;AX = BF93h + 75B3h + 1 
    mov [suma+2],ax         ;suma = 5D1D 3547h
    ;C=1
    mov ax,[num1+4]         ;AX = C642h
    adc ax,[num2+4]         ;AX = C642h + 07E3h + 1
    mov [suma+4],ax         ;suma = 5D1D 3547 CE26h
    ;C=0
    mov ax,[num1+6]         ;AX = 078Ah
    adc ax,[num2+6]         ;AX = 078Ah + 5F31h + 0
    mov [suma+6],ax         ;suma = 5D1D 3547 CE26 66BBh
    ;C=0
    mov ax,[num1+8]         ;AX = 1D53h
    adc ax,[num2+8]         ;AX = 1D53h + 70D7h + 0
    mov [suma+8],ax         ;suma = 5D1D 3547 CE26 66BB 8E2Ah
    ;C=0
    mov ax,[num1+10]        ;AX = 40B7h
    adc ax,[num2+10]        ;AX = 40B7h + 85E2h + 0
    mov [suma+10],ax        ;suma = 5D1D 3547 CE26 66BB 8E2A C699h
    ;C=0
    mov ax,[num1+12]        ;AX = E50Ah
    adc ax,[num2+12]        ;AX = E50Ah + 076Ch + 0
    mov [suma+12],ax        ;suma = 5D1D 3547 CE26 66BB 8E2A C699 EC76h
    ;C=0
    mov ax,[num1+14]        ;AX = 75B9h
    adc ax,[num2+14]        ;AX = 75B9h + BC40h + 0
    mov [suma+14],ax        ;suma = 5D1D 3547 CE26 66BB 8E2A C699 EC76 31F9h
    ;C=1
    adc [suma+16],0000h     ;suma = 5D1D 3547 CE26 66BB 8E2A C699 EC76 31F9 0001h

    ;RESTA
    clc                     ;C=0
    mov ax,[num1]           ;AX = 6790h
    sbb ax,[num2]           ;AX = 6790h - F58Dh - 0
    mov [resta],ax          ;resta = 7203h
    ;C=1
    mov ax,[num1+2]         ;AX = BF93h
    sbb ax,[num2+2]         ;AX = BF93h - 75B3h - 1 
    mov [resta+2],ax        ;resta = 7203 49DFh
    ;C=0
    mov ax,[num1+4]         ;AX = C642h
    sbb ax,[num2+4]         ;AX = C642h - 07E3h - 0
    mov [resta+4],ax        ;resta = 7203 49DF BE5Fh
    ;C=0
    mov ax,[num1+6]         ;AX = 078Ah
    sbb ax,[num2+6]         ;AX = 078Ah - 5F31h - 0
    mov [resta+6],ax        ;resta = 7203 49DF BE5F A859h
    ;C=1
    mov ax,[num1+8]         ;AX = 1D53h
    sbb ax,[num2+8]         ;AX = 1D53h - 70D7h - 1
    mov [resta+8],ax        ;resta = 7203 49DF BE5F A859 AC7Bh 
    ;C=1
    mov ax,[num1+10]        ;AX = 40B7h
    sbb ax,[num2+10]        ;AX = 40B7h - 85E2h - 1
    mov [resta+10],ax       ;resta = 7203 49DF BE5F A859 AC7B BAD4h
    ;C=1
    mov ax,[num1+12]        ;AX = E50Ah
    sbb ax,[num2+12]        ;AX = E50Ah - 076Ch - 1
    mov [resta+12],ax       ;resta = 7203 49DF BE5F A859 AC7B BAD4 DD9Dh
    ;C=0
    mov ax,[num1+14]        ;AX = 75B9h
    sbb ax,[num2+14]        ;AX = 75B9h - BC40h - 0
    mov [resta+14],ax       ;resta = 7203 49DF BE5F A859 AC7B BAD4 DD9D B979h
    ;C=1
    sbb [resta+16],0000h    ;resta = 7203 49DF BE5F A859 AC7B BAD4 DD9D B979 FFFFh
    
salir:                  ;inicia etiqueta salir
    mov ah,4Ch          ;AH = 4Ch, opcion para terminar programa
    mov al,0            ;AL = 0 Exit Code, codigo devuelto al finalizar el programa
                        ;AX es un argumento necesario para interrupciones
    int 21h             ;señal 21h de interrupcion, pasa el control al sistema operativo
    end inicio          ;fin del programa