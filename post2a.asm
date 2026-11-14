; post2a.asm - INT 16h: leer scan codes
; Parte 2, Paso 1 (Checkpoint 1)
; Compilar: nasm -f bin post2a.asm -o post2a.com
ORG 100h

SCAN_ESC equ 01h

section .data
prompt   db "Pulse una tecla (ESC para salir): $"
msgScan  db " Scan: $"
msgAscii db " ASCII: $"
crlf     db 0Dh, 0Ah, "$"

section .text
start:
    mov ah, 09h
    mov dx, prompt
    int 21h

.leer:
    mov ah, 00h                         ; INT 16h / AH=00h: espera una tecla
    int 16h                             ; AH = scan code, AL = ASCII
    mov bl, ah                          ; guardar scan code en BL
    mov bh, al                          ; guardar ASCII en BH

    cmp bl, SCAN_ESC                    ; Escape termina el programa
    je .fin

    mov ah, 09h
    mov dx, msgScan
    int 21h
    mov al, bl
    call impHex                         ; scan code en hexadecimal

    mov ah, 09h
    mov dx, msgAscii
    int 21h
    mov al, bh
    call impHex                         ; ASCII en hexadecimal

    mov ah, 09h
    mov dx, crlf
    int 21h
    jmp .leer

.fin:
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
