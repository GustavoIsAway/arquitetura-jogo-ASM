section .data
    multiplicador  dd 1664525
    incremento     dd 1013904223
    max_num        dd 10      ; Números de 0 a 99
    
    msg_num        db "Número aleatório: ", 0
    len_msg        equ $ - msg_num
    newline        db 10        ; Caractere de nova linha

section .bss
    numero         resd 1
    buffer         resb 10

section .text
global _start

_start:
    ; Inicializa semente com o tempo atual
    mov eax, 13                 ; syscall time
    xor ebx, ebx
    int 0x80
    mov [numero], eax

loop_infinito:
    ; Gera e mostra um novo número
    call gerar_aleatorio
    call mostrar_numero
    
    ; Pequena pausa (opcional)
    mov eax, 162                ; syscall nanosleep
    mov ebx, tempo_espera
    xor ecx, ecx
    int 0x80
    
    jmp loop_infinito           ; Repete eternamente

; --- Funções ---
gerar_aleatorio:
    mov eax, [numero]
    mov ecx, [multiplicador]
    mul ecx
    add eax, [incremento]
    mov [numero], eax
    xor edx, edx
    div dword [max_num]
    mov [numero], edx
    ret

mostrar_numero:
    ; Mostra mensagem
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_num
    mov edx, len_msg
    int 0x80
    
    ; Converte número para ASCII
    mov eax, [numero]
    lea edi, [buffer + 9]
    mov byte [edi], 0
    mov ecx, 10
.converte:
    dec edi
    xor edx, edx
    div ecx
    add dl, '0'
    mov [edi], dl
    test eax, eax
    jnz .converte
    
    ; Mostra número
    mov esi, edi
    mov edx, buffer + 10
    sub edx, esi
    mov eax, 4
    mov ebx, 1
    mov ecx, esi
    int 0x80
    
    ; Nova linha
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    ret

section .data
  tempo_espera:
    dd 1    ; 1 segundo
    dd 0    ; 0 nanossegundos