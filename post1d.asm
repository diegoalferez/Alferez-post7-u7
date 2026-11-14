; post1d.asm - INT 10h: modo de video (AH=0Fh) y relectura de celda (AH=08h)
; Parte 1, Paso 4 (Checkpoint 4)
; Compilar: nasm -f bin post1d.asm -o post1d.com
ORG 100h

MODO_TEXTO_80X25  equ 03h
ATTR_BLANCO_NEGRO equ 07h
ATTR_PRUEBA       equ 2Fh               ; fondo verde (2), texto blanco brillante (F)
CHAR_PRUEBA       equ "Z"
FILA_PRUEBA       equ 08h
COL_PRUEBA        equ 0Ah

section .data
msgModo    db "Modo de video: $"
msgSufijo  db "h$"
msgOk      db 0Dh, 0Ah, "Modo texto 80x25 confirmado (03h)", 0Dh, 0Ah, "$"
msgNook    db 0Dh, 0Ah, "Modo inesperado, se continua de todas formas", 0Dh, 0Ah, "$"
msgVerOk   db 0Dh, 0Ah, "Verificacion OK: caracter y atributo releidos coinciden", "$"
msgVerBad  db 0Dh, 0Ah, "ERROR: la relectura no coincide con lo escrito", "$"
modoActual db 0                         ; modo de video consultado con AH=0Fh

section .text
start:
    ; Limpiar pantalla y llevar el cursor al origen (capturas mas limpias)
    mov ah, 06h
    xor al, al
    xor cx, cx
    mov dx, 184Fh
    mov bh, ATTR_BLANCO_NEGRO
    int 10h
    mov ah, 02h
    xor bh, bh
    xor dx, dx
    int 10h

    ; AH=0Fh: obtener el modo de video activo
    mov ah, 0Fh
    int 10h                             ; AL=modo, AH=columnas, BH=pagina activa
    mov [modoActual], al                ; se guarda en memoria: INT 21h destruye AX y DX

    mov ah, 09h
    mov dx, msgModo
    int 21h
    mov al, [modoActual]
    call impHex                         ; imprime el modo en hexadecimal
    mov ah, 09h
    mov dx, msgSufijo
    int 21h

    cmp byte [modoActual], MODO_TEXTO_80X25
    jne .modo_raro

    mov ah, 09h
    mov dx, msgOk
    int 21h
    jmp .escribir

.modo_raro:
    mov ah, 09h
    mov dx, msgNook
    int 21h

.escribir:
    ; Posicionar cursor en la celda de prueba
    mov ah, 02h
    xor bh, bh
    mov dh, FILA_PRUEBA
    mov dl, COL_PRUEBA
    int 10h

    ; AH=09h: escribir "Z" con atributo conocido
    mov ah, 09h
    mov al, CHAR_PRUEBA
    xor bh, bh
    mov bl, ATTR_PRUEBA
    mov cx, 1
    int 10h

    ; Reposicionar el cursor en la misma celda antes de leer
    mov ah, 02h
    xor bh, bh
    mov dh, FILA_PRUEBA
    mov dl, COL_PRUEBA
    int 10h

    ; AH=08h: leer caracter y atributo bajo el cursor (pagina 0)
    mov ah, 08h
    xor bh, bh
    int 10h                             ; AH=atributo, AL=caracter

    ; Comparar contra lo escrito
    cmp al, CHAR_PRUEBA
    jne .no_coincide
    cmp ah, ATTR_PRUEBA
    jne .no_coincide

    mov ah, 09h
    mov dx, msgVerOk
    int 21h
    jmp .fin

.no_coincide:
    mov ah, 09h
    mov dx, msgVerBad
    int 21h

.fin:
    mov ah, 07h
    int 21h
    mov ah, 4Ch
    xor al, al
    int 21h

; ---- Subrutina: imprime AL como 2 digitos hexadecimales (INT 21h / AH=02h) ----
impHex:
    push ax
    shr al, 4                           ; nibble alto
    call nibbleToChar
    mov dl, al
    mov ah, 02h
    int 21h
    pop ax
    and al, 0Fh                         ; nibble bajo
    call nibbleToChar
    mov dl, al
    mov ah, 02h
    int 21h
    ret

nibbleToChar:
    cmp al, 9
    jle .digito
    add al, 37h                         ; 10..15 -> "A".."F"
    ret
.digito:
    add al, 30h                         ; 0..9 -> "0".."9"
    ret
