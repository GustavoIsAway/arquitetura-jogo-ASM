#include <math.h>
#include <stdbool.h>
#include <stdlib.h>
#include <stdio.h>
#include <time.h>

int main() {
    int parede[2] = {500, 500};     // Posição inicial
    int jogador_hp = 6;             // Tentativas antes de ser petrificado
    int parede_hp = 3;              // Saúde da parede
    srand(time(NULL));

    printf("⚔️ THE WIZARD'S WALL ⚔️\n");
    printf("Destrua a parede do mago antes de ser petrificado!\n");

    while (jogador_hp > 0 && parede_hp > 0) {
        int chute[2];
        printf("\nSua vida: %d\n", jogador_hp);
        printf("Vida da Parede: %d\n", parede_hp);
        printf("Chute (X Y): ");
        scanf("%d %d", &chute[0], &chute[1]);

        // Feitiço do mago (5% de chance)
        if (rand() % 100 < 5) {
            printf("\n☠️ O mago lhe acertou com um feitiço. Perdeu metade da vida.\n");
            jogador_hp -= (int)(jogador_hp/2);
        }

        // Movimento da parede (0 a 9 unidades em X/Y)
        parede[0] += (rand() % 3 - 1) * (rand() % 11);  // -1, 0, ou +1 * aleatório
        parede[1] += (rand() % 3 - 1) * (rand() % 11);

        // Verifica acerto (raio de 10 unidades)
        double distancia = sqrt(pow(chute[0] - parede[0], 2) + pow(chute[1] - parede[1], 2));
        if (distancia <= 5) {
            printf("\n💥 BOOM! Você acertou a parede! (Posição atual: %d, %d)\n", parede[0], parede[1]);
            jogador_hp++;  // Recompensa por acerto
            parede_hp--;
        } else {
            printf("\n❌ Errou! A parede agora está em (%d, %d)\n", parede[0], parede[1]);
            jogador_hp--;  // Penalidade por erro
        }
    }
    
    if (parede_hp == 0){
        printf("\n🏆Fim de jogo! Você venceu! O mago foi derrotado.🏆\n");
    } else {
        printf("\n💀Fim de jogo! Você perdeu! O mago lhe petrificou.💀\n");
    }
    
    return 0;
}