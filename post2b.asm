; post2b.asm - Escritura directa en B800h
; Parte 2, Paso 2 (Checkpoint 2)
; Compilar: nasm -f bin post2b.asm -o post2b.com
ORG 100h

VIDEO_SEG equ 0B800h                    ; segmento de video en modo texto color
COLUMNAS  equ 80
; offset de la celda (fila, col) = (fila * 80 + col) * 2
%define VIDEO_OFFSET(f, c) (((f) * COLUMNAS + (c)) * 2)

ATTR_BLANCO_BRILLANTE equ 0Fh
ATTR_AMARILLO         equ 0Eh
ATTR_VERDE_CLARO      equ 0Ah
ATTR_ROJO_CLARO       equ 0Ch

COL_LETRAS equ 35

section .text
start:
    mov ax, VIDEO_SEG
    mov es, ax                          ; ES apunta a la memoria de video

    ; fila 10, col 35 -> offset 1670
    mov di, VIDEO_OFFSET(10, COL_LETRAS)
    mov byte [es:di], "H"               ; byte par: caracter ASCII
    mov byte [es:di+1], ATTR_BLANCO_BRILLANTE   ; byte impar: atributo

    ; fila 11, col 35 -> offset 1830
    mov di, VIDEO_OFFSET(11, COL_LETRAS)
    mov byte [es:di], "O"
    mov byte [es:di+1], ATTR_AMARILLO

    ; fila 12, col 35 -> offset 1990
    mov di, VIDEO_OFFSET(12, COL_LETRAS)
    mov byte [es:di], "L"
    mov byte [es:di+1], ATTR_VERDE_CLARO

    ; fila 13, col 35 -> offset 2150
    mov di, VIDEO_OFFSET(13, COL_LETRAS)
    mov byte [es:di], "A"
    mov byte [es:di+1], ATTR_ROJO_CLARO

    ; Esperar tecla y salir
    mov ah, 07h
    int 21h
    mov ah, 4Ch
    xor al, al
    int 21h
