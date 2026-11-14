; post2e.asm - INT 16h/AH=02h: estado de Shift/Ctrl reflejado en B800h
; Parte 2, Paso 5 (Checkpoint 5)
; Compilar: nasm -f bin post2e.asm -o post2e.com
; Escape termina el programa.
ORG 100h

VIDEO_SEG equ 0B800h
COLUMNAS  equ 80
FILAS     equ 25
%define VIDEO_OFFSET(f, c) (((f) * COLUMNAS + (c)) * 2)

; Bits del byte de estado de teclado (0040h:0017h)
MASK_SHIFT equ 03h                      ; bit 0 = Shift der., bit 1 = Shift izq.
MASK_CTRL  equ 04h                      ; bit 2 = Ctrl

; Posiciones en la fila 0
COL_ETQ_SHIFT equ 0                     ; "SHIFT:" ocupa columnas 0-5
COL_VAL_SHIFT equ 6                     ; digito de Shift: offset 12
COL_ETQ_CTRL  equ 8                     ; "CTRL:" ocupa columnas 8-12
COL_VAL_CTRL  equ 13                    ; digito de Ctrl: offset 26

ATTR_PANTALLA equ 07h
ATTR_ETIQUETA equ 0Fh                   ; blanco brillante sobre negro
ATTR_SHIFT    equ 0Ah                   ; verde brillante
ATTR_CTRL     equ 0Ch                   ; rojo claro
CHAR_ESPACIO  equ 20h
SCAN_ESC      equ 01h

section .data
etiqSh db "SHIFT:"
LEN_SH equ $ - etiqSh
etiqCt db "CTRL:"
LEN_CT equ $ - etiqCt

section .text
start:
    mov ax, VIDEO_SEG
    mov es, ax
    cld

    ; Limpiar la pantalla para que la fila 0 quede libre
    mov ax, (ATTR_PANTALLA << 8) | CHAR_ESPACIO
    xor di, di
    mov cx, COLUMNAS * FILAS
    rep stosw

    ; Etiqueta "SHIFT:"
    mov si, etiqSh
    mov di, VIDEO_OFFSET(0, COL_ETQ_SHIFT)
    mov cx, LEN_SH
.etq1:
    lodsb
    mov ah, ATTR_ETIQUETA
    stosw
    loop .etq1

    ; Etiqueta "CTRL:"
    mov si, etiqCt
    mov di, VIDEO_OFFSET(0, COL_ETQ_CTRL)
    mov cx, LEN_CT
.etq2:
    lodsb
    mov ah, ATTR_ETIQUETA
    stosw
    loop .etq2

.bucle:
    ; AH=02h: byte de estado de teclas modificadoras (no bloqueante)
    mov ah, 02h
    int 16h                             ; AL = byte de 0040h:0017h
    mov bl, al                          ; conservar el byte completo

    ; Shift (bits 0-1): "1" si cualquiera de los dos esta presionado
    mov cl, "0"
    test bl, MASK_SHIFT
    jz .shift_listo
    mov cl, "1"
.shift_listo:
    mov di, VIDEO_OFFSET(0, COL_VAL_SHIFT)
    mov [es:di], cl
    mov byte [es:di+1], ATTR_SHIFT

    ; Ctrl (bit 2)
    mov cl, "0"
    test bl, MASK_CTRL
    jz .ctrl_listo
    mov cl, "1"
.ctrl_listo:
    mov di, VIDEO_OFFSET(0, COL_VAL_CTRL)
    mov [es:di], cl
    mov byte [es:di+1], ATTR_CTRL

    ; AH=01h: hay tecla en el buffer? (no bloqueante, no la consume)
    mov ah, 01h
    int 16h
    jz .bucle                           ; ZF=1: no hay tecla, seguir sondeando

    ; Hay tecla: consumirla y verificar si es Escape
    mov ah, 00h
    int 16h                             ; AH = scan code
    cmp ah, SCAN_ESC
    jne .bucle

    mov ah, 4Ch
    xor al, al
    int 21h
