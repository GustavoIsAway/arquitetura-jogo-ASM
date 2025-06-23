section .data
  ;-----------------DADOS DO TIMER---------------------;
  multiplicador              dd 1664525
  incremento                 dd 1013904223
  max_num                    dd 100      ; Números de 0 a 99

  ;------------INICIALIZAÇÃO DE TEXTOS------------;
  msginp1 db "Introduza uma posiçao v\xE1lida: ", 0xA, 0x0
  lenmsginp1 equ $ - msginp1

  msg_inicial                db "⚔️ THE WIZARD'S WALL ⚔️", 0, 0xA
  len_msg_inicial            equ $ - msg_inicial
  msg_instrucoes             db "Destrua a parede do mago antes de ser petrificado!", 0, 0xA
  len_msg_instucoes          equ $ - msg_instrucoes
  msg_chute_x                db "Chute X: ", 0
  len_msg_chute_x            equ $ - msg_chute_x
  msg_chute_y                db "Chute Y: ", 0
  len_msg_chute_y            equ $ - msg_chute_y
  msg_vida_jogador           db "Vida do Jogador: ", 0
  len_msg_vida_jogador       equ $ - msg_vida_jogador
  msg_vida_parede            db "Vida da Parede: ", 0
  len_msg_vida_parede        equ $ - msg_vida_parede
  msg_acerto                 db "BOOOM! Você acertou! Posicao da parede: ", 0
  len_msg_acerto             equ $ - msg_acerto
  msg_erro                   db "Errou! A parede agora esta em: ", 0
  len_msg_erro               equ $ - msg_erro
  msg_mago                   db "O mago lhe acertou com um feitico. Perdeu metade da vida.", 0, 0xA
  len_msg_mago               equ $ - msg_mago
  msg_gameover               db "💀Fim de jogo! Você perdeu! O mago lhe petrificou.💀", 0, 0xA
  len_msg_gameover           equ $ - msg_gameover
  msg_win                    db "🏆Fim de jogo! Você venceu! O mago foi derrotado.🏆", 0, 0xA
  len_msg_win                equ $ - msg_win

  ;----------------VARI\xC1VEIS COMUNS----------------;
  pos_parede  dd 500, 500
  jogador_hp  dd 10
  parede_hp   dd 3

section .bss
  buffer resb 100
  strint resb 100
  numero_aleatorio resd 1

  chute_altura resd 1
  chute_largura resd 1

section .text
  global _start

_start:
  ; Inicializa a semente com time()
  mov eax, 13
  xor ebx, ebx
  int 0x80
  mov [numero_aleatorio], eax

  ; Exibe introdu\xE7\xE3o
  mov ecx, msg_inicial
  mov edx, len_msg_inicial
  call _stdout

  mov ecx, msg_instrucoes
  mov edx, len_msg_instucoes
  call _stdout

_loop_jogo:
  mov dword [max_num], 100

  mov ecx, msg_vida_jogador
  mov edx, len_msg_vida_jogador
  call _stdout

  mov ebx, [jogador_hp]
  call _itos
  mov eax, esi
  mov byte [strint + eax], 0xA
  inc esi
  mov ecx, strint
  mov edx, esi
  call _stdout

  mov ecx, msg_vida_parede
  mov edx, len_msg_vida_parede
  call _stdout

  mov ebx, [parede_hp]
  call _itos
  mov eax, esi
  mov byte [strint + eax], 0xA
  inc esi
  mov ecx, strint
  mov edx, esi
  call _stdout

  mov ecx, msg_chute_x
  mov edx, len_msg_chute_x
  call _stdout

  mov ecx, buffer
  mov edx, 4
  call _stdin
  mov ebx, buffer
  call _stoi
  mov [chute_largura], eax

  mov ecx, msg_chute_y
  mov edx, len_msg_chute_y
  call _stdout

  mov ecx, buffer
  mov edx, 4
  call _stdin
  mov ebx, buffer
  call _stoi
  mov [chute_altura], eax

  ; Tiro do mago
  mov dword [max_num], 100
  call _gerar_aleatorio
  mov eax, 5
  mov ebx, [numero_aleatorio]
  cmp ebx, eax
  jle _mago_acerta_jogador

_gerar_movimento_x:
  mov dword [max_num], 3
  call _gerar_aleatorio
  mov ebx, [numero_aleatorio]
  sub ebx, 1
  cmp ebx, 0
  jl _movimento_negativo_x

  mov dword [max_num], 3
  call _gerar_aleatorio
  mov ebx, [pos_parede + 0 * 4]
  mov ecx, [numero_aleatorio]
  add ebx, ecx
  mov [pos_parede + 0 * 4], ebx

_gerar_movimento_y:
  mov dword [max_num], 3
  call _gerar_aleatorio
  mov ebx, [numero_aleatorio]
  sub ebx, 1
  cmp ebx, 0
  jl _movimento_negativo_y

  mov dword [max_num], 3
  call _gerar_aleatorio
  mov ebx, [pos_parede + 1 * 4]
  mov ecx, [numero_aleatorio]
  add ebx, ecx
  mov [pos_parede + 1 * 4], ebx
  jmp _checagem_de_tiro

_movimento_negativo_x:
  mov dword [max_num], 3
  call _gerar_aleatorio
  mov ebx, [pos_parede + 0 * 4]
  mov ecx, [numero_aleatorio]
  sub ebx, ecx
  mov [pos_parede + 0 * 4], ebx
  jmp _gerar_movimento_y

_movimento_negativo_y:
  mov dword [max_num], 3
  call _gerar_aleatorio
  mov ebx, [pos_parede + 1 * 4]
  mov ecx, [numero_aleatorio]
  sub ebx, ecx
  mov [pos_parede + 1 * 4], ebx
  jmp _checagem_de_tiro

_checagem_de_tiro:
  mov eax, [pos_parede + 0 * 4]
  mov ebx, [chute_largura]
  sub eax, ebx

  mov ecx, [pos_parede + 1 * 4]
  mov edx, [chute_altura]
  sub edx, ecx

  cmp eax, edx
  je _tiro_acertado

  mov ecx, msg_erro
  mov edx, len_msg_erro
  call _stdout

  mov ebx, [pos_parede + 0 * 4]
  call _itos
  mov eax, esi
  mov byte [strint + eax], 0x20
  inc esi
  mov ecx, strint
  mov edx, esi
  call _stdout

  mov ebx, [pos_parede + 1 * 4]
  call _itos
  mov eax, esi
  mov byte [strint + eax], 0xA
  inc esi
  mov ecx, strint
  mov edx, esi
  call _stdout

  mov eax, [jogador_hp]
  dec eax
  mov [jogador_hp], eax

_verificar_fim:
  mov eax, [jogador_hp]
  cmp eax, 0
  je _game_over

  mov eax, [parede_hp]
  cmp eax, 0
  je _win

  jmp _loop_jogo

_tiro_acertado:
  mov ecx, msg_acerto
  mov edx, len_msg_acerto
  call _stdout

  mov ebx, [pos_parede + 0 * 4]
  call _itos
  mov eax, esi
  mov byte [strint + eax], 0x20
  inc esi
  mov ecx, strint
  mov edx, esi
  call _stdout

  mov ebx, [pos_parede + 1 * 4]
  call _itos
  mov eax, esi
  mov byte [strint + eax], 0xA
  inc esi
  mov ecx, strint
  mov edx, esi
  call _stdout

  mov eax, [jogador_hp]
  inc eax
  mov [jogador_hp], eax

  mov ebx, [parede_hp]
  dec ebx
  mov [parede_hp], ebx

  jmp _verificar_fim

_mago_acerta_jogador:
  mov ecx, msg_mago
  mov edx, len_msg_mago
  call _stdout

  xor edx, edx
  mov eax, [jogador_hp]
  mov ebx, 2
  div ebx
  mov [jogador_hp], eax

  jmp _gerar_movimento_x

_stdout:
  mov eax, 4
  mov ebx, 1
  int 0x80
  ret

_stdin:
  mov eax, 3
  xor ebx, ebx
  int 0x80
  ret

_stoi:
  xor esi, esi
  xor eax, eax

_stoi_loop:
  cmp byte [ebx + esi], 0xA
  je _stoi_end
  cmp byte [ebx + esi], 0
  je _stoi_end
  movzx ecx, byte [ebx + esi]
  sub ecx, '0'
  imul eax, eax, 10
  add eax, ecx
  inc esi
  jmp _stoi_loop

_stoi_end:
  ret

_itos:
  mov edi, strint
  mov ecx, 10
  xor esi, esi
  xor edx, edx
  mov eax, ebx

.itos_loop:
  xor edx, edx
  div ecx
  add edx, '0'
  push edx
  inc esi
  cmp eax, 0
  jne .itos_loop

  mov edi, strint

.itos_pop:
  pop eax
  mov [edi], al
  inc edi
  dec esi
  cmp esi, 0
  jne .itos_pop

  mov esi, edi
  sub esi, strint
  ret

_gerar_aleatorio:
  rdtsc                       ; Lê o contador de tempo do processador
  add [numero_aleatorio], eax ; Mistura com a semente atual
  mov eax, [numero_aleatorio]
  mov ecx, [multiplicador]
  mul ecx
  add eax, [incremento]
  mov [numero_aleatorio], eax
  xor edx, edx
  div dword [max_num]
  mov [numero_aleatorio], edx
  ret

_game_over:
  mov ecx, msg_gameover
  mov edx, len_msg_gameover
  call _stdout
  mov eax, 1
  xor ebx, ebx
  int 0x80

_win:
  mov ecx, msg_win
  mov edx, len_msg_win
  call _stdout
  mov eax, 1
  xor ebx, ebx
  int 0x80
