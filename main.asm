section .data
  ;-----------------DADOS DO TIMER---------------------;
  multiplicador              dd 1664525
  incremento                 dd 1013904223
  max_num                    dd 100      ; Números de 0 a 99
  
  ;------------INICIALIZAÇÃO DE TEXTOS------------;
  msginp1 db "Introduza uma posiçao válida: ", 0xA, 0x0
  lenmsginp1 equ $ - msginp1

  msg_inicial                db "⚔️ THE WIZARD'S WALL ⚔️", 0, 0xA,
  len_msg_inicial            equ $ - msg_inicial
  msg_instrucoes             db "Destrua a parede do mago antes de ser petrificado!", 0, 0xA,
  len_msg_instucoes          equ $ - msg_instrucoes
  msg_chute_x                db "Chute X: ", 0
  len_msg_chute_x            equ $ - msg_chute_x
  msg_chute_y                db "Chute Y: ", 0
  len_msg_chute_y            equ $ - msg_chute_y
  msg_vida_jogador           db "Vida do Jogador: ", 0
  len_msg_vida_jogador       equ $ - msg_vida_jogador
  msg_vida_parede            db "Vida da Parede: ", 0
  len_msg_vida_parede        equ $ - msg_vida_parede
  msg_acerto                 db "BOOOM! Você acertou! Posicao da parede: ",
  len_msg_acerto             equ $ - msg_acerto
  msg_erro                   db "Errou! A parede agora esta em: ",
  len_msg_erro               equ $ - msg_vida_jogador
  msg_mago                   db "O mago lhe acertou com um feitico. Perdeu metade da vida.", 0, 0xA
  len_msg_mago               equ $ - msg_mago
  msg_gameover               db "💀Fim de jogo! Você perdeu! O mago lhe petrificou.💀", 0, 0xA
  len_msg_gameover           equ $ - msg_gameover
  msg_win                    db "🏆Fim de jogo! Você venceu! O mago foi derrotado.🏆", 0, 0xA
  len_msg_win                equ $ - msg_win

  ;----------------VARIÁVEIS COMUNS----------------;
  pos_parede  dd 500, 500
  jogador_hp  dd 10
  parede_hp   dd 3


section .bss                            ; 
  buffer resb 100                       ; espaço suficiente para 10 dígitos + \n + \0
  strint resb 100                       ; buffer para armazenar o inteiro convertido em string
  numero_aleatorio resd 1               ; variável para receber número aleatório
  
  chute_altura resd 1
  chute_largura resd 1

  parede_mexe_x resd 1
  parede_mexe_y resd 1
  parede_dir_x  resd 1
  parede_dir_y  resd 1

section .text
  global _start


; -------------------------- EXECUÇÃO DO JOGO -------------------------- ;
_start:
  ; INTRODUÇÃO DO JOGO ;
  mov ecx, msg_inicial 
  mov edx, len_msg_inicial
  call _stdout
  
  mov ecx, msg_instrucoes
  mov edx, len_msg_instucoes
  call _stdout
  

_loop_jogo:
  mov eax, 100
  mov [max_num], eax

  ; INFORMAÇÕES DE JOGO ;

  mov ecx, msg_vida_jogador
  mov edx, len_msg_vida_jogador
  call _stdout

  mov ebx, [jogador_hp]
  call _itos                      ;_itos não imprime \n -> esi devolve tamanho da string 

  mov eax, strint
  add esi, eax
  mov byte [esi], 0xA
  
  mov ecx, strint
  mov edx, esi
  call _stdout

  mov ecx, msg_vida_parede
  mov edx, len_msg_vida_parede
  call _stdout
  
  mov ebx, [parede_hp]
  call _itos

  mov eax, strint
  add esi, eax
  mov byte [esi], 0xA

  mov ecx, strint
  mov edx, esi
  call _stdout


  ; INICIANDO INTERAÇÃO DO JOGADOR ;
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

  ; TIRO DO MAGO - CHANCE DE 95% ;
  call _gerar_aleatorio
  mov eax, 5
  mov ebx, [numero_aleatorio]
  cmp ebx, eax   ; compara [numero_aleatorio] - 5
  jle _mago_acerta_jogador       ; se for menor ou igual...

_gerar_movimento_x:
  ; Definindo pra sortear números de 0 a 2
  mov eax, 3
  mov [max_num], eax
  
  call _gerar_aleatorio
  mov ebx, [numero_aleatorio]   ; Ou dá 0, 1 ou 2 -> Verifica se mexe para x
  sub ebx, 1
  cmp ebx, 0
  jl _movimento_negativo_x
  ; Roda isso caso não saltar
  call _gerar_aleatorio
  mov dword ebx, [pos_parede + 0 * 4]
  mov ecx,[numero_aleatorio]
  add ebx, ecx
  mov dword [pos_parede + 0 * 4], ebx
  

_gerar_movimento_y:
  call _gerar_aleatorio
  mov ebx, [numero_aleatorio]   ; Ou dá 0, 1 ou 2 -> Verifica se mexe para y
  sub ebx, 1
  mov [parede_mexe_y], ebx
  jl _movimento_negativo_y

  ; Definindo para sortear números de 0 a 9 -> 1 a 10
  mov eax, 10
  mov dword[max_num], 10
  

_checagem_de_tiro:
  mov dword eax, [pos_parede + 0 * 4]
  mov ebx, [chute_largura]
  sub eax, ebx

  mov dword ecx, [pos_parede + 1 * 4]
  mov edx, [chute_altura]
  sub edx, ecx

  cmp eax, edx
  je _tiro_acertado

  mov ecx, msg_erro
  mov edx, len_msg_erro
  call _stdout

  mov dword ebx, [pos_parede + 0 * 4] 
  call _itos

  mov eax, strint
  add esi, eax
  mov byte [esi], 0x20

  mov ecx, strint
  mov edx, esi
  call _stdout
  
  mov dword ebx, [pos_parede + 1 * 4] 
  call _itos

  mov eax, strint
  add esi, eax
  mov byte [esi], 0xA

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

  mov dword ebx, [pos_parede + 0 * 4] 
  call _itos

  mov eax, strint
  add esi, eax
  mov byte [esi], 0x20

  mov ecx, strint
  mov edx, esi
  call _stdout
  
  mov dword ebx, [pos_parede + 1 * 4] 
  call _itos

  mov eax, strint
  add esi, eax
  mov byte [esi], 0xA

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

; --------------------- FUNÇÕES -------------------------- ;
_stdout:        
  mov eax, 4   ; operação write
  mov ebx, 1   ; stdout
  int 0x80
  ret


_stdin:
  mov eax, 3   ;operação read
  xor ebx, ebx ;stdin
  ; ecx contém uma variável de buffer
  ; edx constém o tamanho do texto a ser armazenado
  int 0x80
  ret


_movimento_negativo_x: 
  call _gerar_aleatorio
  mov ebx, [pos_parede + 0 * 4]
  mov ecx, [numero_aleatorio]
  sub ebx, ecx
  mov dword [pos_parede + 0 * 4], ebx
  
  jmp _gerar_movimento_y


_movimento_negativo_y:
  call _gerar_aleatorio
  mov ebx, [pos_parede + 1 * 4]
  mov ecx, [numero_aleatorio]
  sub ebx, ecx
  mov [pos_parede + 1 * 4], ebx
  
  jmp _checagem_de_tiro


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


_stoi:                                      ; entrada = EBX -> saída = EAX
  xor esi, esi
  xor eax, eax

_stoi_loop:
  cmp byte [ebx + esi], 0xA     ; '\n'
  je _stoi_end
  cmp byte [ebx + esi], 0       ; '\0'
  je _stoi_end

  movzx ecx, byte [ebx + esi]
  sub ecx, '0'
  imul eax, eax, 10
  add eax, ecx
  inc esi
  jmp _stoi_loop

_stoi_end:
  ret


_itos:                                      ; entrada = EBX -> saída = strint -> tamanho da string = ESI
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

  ; desempilhando caracteres para strint
  mov edi, strint


.itos_pop:
  pop eax             ; saca último dígito da pilha
  mov [edi], al       ; acrescenta o número sacado para o índice EDI da string
  inc edi             ; incrementa o índice
  dec esi             ; decrementa o iterador - ele é o responsável por saber quantos dígitos temos que passar
  cmp esi, 0          ; subtrai o iterador de 0. Se der 0, não há mais dígitos para acrescentar
  jne .itos_pop       ; se não zerou, faz tudo de novo

  mov esi, edi        ; coloca o endereço do final da string no ESI
  sub esi, strint     ; obtém o tamanho da string subtraindo o primeiro endereço menos o último
                      ; agora ESI = tamanho da string
  ret


_gerar_aleatorio:
  mov eax, [numero_aleatorio]
  mov ecx, [multiplicador]
  mul ecx                   ; multiplica EAX com ECX -> resultado em EAX
  add eax, [incremento]     ; soma com a constante
  mov [numero_aleatorio], eax
  xor edx, edx
  div dword [max_num]       ; divide EAXX com o operando -> resultado em EAX -> resto em EDX 
  mov [numero_aleatorio], edx
  ret


_mago_acerta_jogador:
  mov ecx, msg_mago
  mov edx, len_msg_mago
  call _stdout

  xor edx, edx              ; zera EDX pra receber o resto
  mov eax, [jogador_hp]
  mov ebx, 2
  div ebx
  mov [jogador_hp], eax

  jmp _gerar_movimento_x

