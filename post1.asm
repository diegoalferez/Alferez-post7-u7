; post1.asm - INT 21h: salida de texto basica
; Parte 1, Paso 1 (Checkpoint 1)
; Compilar: nasm -f bin post1.asm -o post1.com
; Ejecutar: post1.com
ORG 100h

section .data
msg1 db "Arquitectura de Computadores", 0Dh, 0Ah, "$"
msg2 db "Unidad 7: Pantalla y Teclado", 0Dh, 0Ah, "$"
msg3 db "Laboratorio POST-1", 0Dh, 0Ah, "$"

section .text
start:
    ; INT 21h / AH=09h: imprime la cadena apuntada por DS:DX hasta "$"
    mov ah, 09h
    mov dx, msg1
    int 21h

    ; AH conserva 09h, solo cambia DX
    mov dx, msg2
    int 21h

    mov dx, msg3
    int 21h

    ; INT 21h / AH=4Ch: terminar el proceso con codigo de retorno 0
    mov ah, 4Ch
    xor al, al
    int 21h
