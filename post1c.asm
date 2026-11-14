; post1c.asm - Cadena en posicion exacta con color
; Parte 1, Paso 3 (Checkpoint 3)
; Compilar: nasm -f bin post1c.asm -o post1c.com
ORG 100h

FILA_TITULO     equ 5
COL_TITULO      equ 25
ATTR_VERDE_CLARO equ 0Ah                ; verde brillante sobre negro

section .data
titulo db "UNIDAD 7 - PANTALLA Y TECLADO", "$"

section .text
start:
    ; Limpiar pantalla
    mov ah, 06h
    xor al, al
    xor cx, cx
    mov dx, 184Fh
    mov bh, 07h
    int 10h

    mov si, titulo                      ; SI recorre la cadena
    mov dl, COL_TITULO                  ; columna inicial
    mov dh, FILA_TITULO                 ; fila fija

.bucle:
    mov al, [si]                        ; siguiente caracter
    cmp al, "$"                         ; fin de cadena?
    je .fin

    ; Posicionar el cursor en (DH, DL)
    mov ah, 02h
    xor bh, bh
    int 10h

    ; Escribir el caracter con atributo verde brillante
    mov ah, 09h
    xor bh, bh
    mov bl, ATTR_VERDE_CLARO
    mov cx, 1
    int 10h

    inc si                              ; siguiente caracter de la cadena
    inc dl                              ; siguiente columna
    jmp .bucle

.fin:
    mov ah, 07h
    int 21h
    mov ah, 4Ch
    xor al, al
    int 21h
