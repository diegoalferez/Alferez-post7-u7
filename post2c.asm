; post2c.asm - Limpiar pantalla con REP STOSW en B800h
; Parte 2, Paso 3 (Checkpoint 3)
; Compilar: nasm -f bin post2c.asm -o post2c.com
ORG 100h

VIDEO_SEG equ 0B800h
COLUMNAS  equ 80
FILAS     equ 25
%define VIDEO_OFFSET(f, c) (((f) * COLUMNAS + (c)) * 2)

ATTR_BLANCO_SOBRE_AZUL equ 17h          ; fondo azul (1), texto gris claro (7)
ATTR_TEXTO_SOBRE_AZUL  equ 1Fh          ; fondo azul (1), texto blanco brillante (F)
CHAR_ESPACIO           equ 20h

FILA_MENSAJE equ 12
COL_MENSAJE  equ 32                     ; 16 caracteres: (80 - 16) / 2 = 32

section .data
titulo db "HOLA DESDE B800h", 0

section .text
start:
    mov ax, VIDEO_SEG
    mov es, ax

    ; AX = atributo (AH) + espacio (AL); se repite en las 2000 celdas
    mov ax, (ATTR_BLANCO_SOBRE_AZUL << 8) | CHAR_ESPACIO
    xor di, di                          ; DI = 0: inicio de la pantalla
    mov cx, COLUMNAS * FILAS            ; 2000 celdas
    cld                                 ; DF = 0: DI avanza
    rep stosw                           ; ES:[DI] = AX, DI += 2, CX -= 1

    ; Mensaje centrado en la fila 12
    mov di, VIDEO_OFFSET(FILA_MENSAJE, COL_MENSAJE)
    mov si, titulo
.bucle:
    lodsb                               ; AL = [DS:SI], SI += 1
    or al, al                           ; fin de cadena nula?
    jz .fin
    mov ah, ATTR_TEXTO_SOBRE_AZUL       ; mantiene el fondo azul
    stosw                               ; ES:[DI] = AX (caracter + atributo)
    jmp .bucle

.fin:
    mov ah, 07h
    int 21h
    mov ah, 4Ch
    xor al, al
    int 21h
