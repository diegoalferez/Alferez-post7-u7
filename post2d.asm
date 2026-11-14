; post2d.asm - Mini editor: INT 16h + B800h
; Parte 2, Paso 4 (Checkpoint 4)
; Compilar: nasm -f bin post2d.asm -o post2d.com
; Enter termina el programa.
ORG 100h

VIDEO_SEG equ 0B800h
COLUMNAS  equ 80
FILAS     equ 25

FILA_EDICION    equ 12                  ; fila fija de edicion
COL_INI         equ 0                   ; columna inicial
ATTR_EDITOR     equ 0Fh                 ; blanco brillante sobre negro
ATTR_PANTALLA   equ 07h
CHAR_ESPACIO    equ 20h
TECLA_ENTER     equ 0Dh

section .text
start:
    mov ax, VIDEO_SEG
    mov es, ax

    ; Limpiar la pantalla directamente en B800h
    mov ax, (ATTR_PANTALLA << 8) | CHAR_ESPACIO
    xor di, di
    mov cx, COLUMNAS * FILAS
    cld
    rep stosw

    mov cx, COL_INI                     ; CX = columna actual

.leer:
    mov ah, 00h
    int 16h                             ; AH = scan code, AL = ASCII (una sola lectura)
    cmp al, TECLA_ENTER
    je .fin
    or al, al
    jz .leer                            ; AL=0: tecla extendida, se ignora
    mov bl, al                          ; guardar el caracter antes de usar AX

    ; offset = (FILA_EDICION * 80 + columna) * 2
    mov ax, FILA_EDICION * COLUMNAS
    add ax, cx
    shl ax, 1
    mov di, ax

    mov [es:di], bl                     ; caracter
    mov byte [es:di+1], ATTR_EDITOR     ; atributo

    inc cx
    cmp cx, COLUMNAS
    jl .leer
    mov cx, COL_INI                     ; al llegar al borde, vuelve al inicio
    jmp .leer

.fin:
    mov ah, 4Ch
    xor al, al
    int 21h
