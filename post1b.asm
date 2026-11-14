; post1b.asm - INT 10h: cursor y color
; Parte 1, Paso 2 (Checkpoint 2)
; Compilar: nasm -f bin post1b.asm -o post1b.com
ORG 100h

; Atributos de color: [fondo (4 bits)][texto (4 bits)]
ATTR_BLANCO_SOBRE_NEGRO  equ 07h
ATTR_AMARILLO_SOBRE_AZUL equ 1Eh        ; 0001 1110b
ATTR_ROJO_CLARO          equ 0Ch        ; 0000 1100b

section .text
start:
    ; Limpiar pantalla con scroll (INT 10h / AH=06h, AL=0 limpia la ventana)
    mov ah, 06h
    xor al, al
    xor cx, cx                          ; esquina superior izquierda: fila 0, col 0
    mov dx, 184Fh                       ; esquina inferior derecha: fila 24, col 79
    mov bh, ATTR_BLANCO_SOBRE_NEGRO     ; atributo de relleno
    int 10h

    ; Posicionar cursor en fila 2, columna 10 (INT 10h / AH=02h)
    mov ah, 02h
    xor bh, bh                          ; pagina 0
    mov dh, 02h                         ; fila
    mov dl, 0Ah                         ; columna
    int 10h

    ; Escribir "A" amarillo sobre azul (INT 10h / AH=09h)
    mov ah, 09h
    mov al, "A"
    xor bh, bh
    mov bl, ATTR_AMARILLO_SOBRE_AZUL
    mov cx, 1                           ; una repeticion
    int 10h

    ; Posicionar cursor en fila 3, columna 10
    mov ah, 02h
    xor bh, bh
    mov dh, 03h
    mov dl, 0Ah
    int 10h

    ; Escribir "U" rojo claro sobre negro
    mov ah, 09h
    mov al, "U"
    xor bh, bh
    mov bl, ATTR_ROJO_CLARO
    mov cx, 1
    int 10h

    ; AH=09h no avanza el cursor: se mueve a mano a la columna 11
    mov ah, 02h
    xor bh, bh
    mov dh, 03h
    mov dl, 0Bh
    int 10h

    ; Escribir "7" con el mismo atributo
    mov ah, 09h
    mov al, "7"
    xor bh, bh
    mov bl, ATTR_ROJO_CLARO
    mov cx, 1
    int 10h

    ; Esperar tecla (sin eco) y salir
    mov ah, 07h
    int 21h
    mov ah, 4Ch
    xor al, al
    int 21h
