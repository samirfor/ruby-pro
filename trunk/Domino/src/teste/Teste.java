package teste;

import java.util.Scanner;
import jogador.Jogador;
import regras.JogoRegras;

public class Teste {

    public static void main(String[] args) {

        JogoRegras jogo = new JogoRegras();
        Jogador jogador1 = new Jogador();
        Jogador jogador2 = new Jogador();
        Scanner ler = new Scanner(System.in);
        int jogador_primeira, jogador_vez, posicao, ponta;

        do {
            jogo.criarTabuleiro();
            jogo.darMao(jogador1);
            jogo.darMao(jogador2);
//            System.out.println("Mostrando mão do jogador1:");
//            System.out.println(jogador1.mostrarMao());
//            System.out.println("Mostrando mão do jogador2:");
//            System.out.println(jogador2.mostrarMao());
            jogo.definirDorme();
//            System.out.println("Mostrando dorme:");
//            System.out.println(jogo.mostrarDorme());
            jogador_primeira = jogo.primeiraJogada(jogador1, jogador2);
        } while (jogador_primeira == 0);

        System.out.println("Jogador " + jogador_primeira + " jogou a primeira peça.\n");
        System.out.println("Mostrando tabuleiro (1a jogada):");
        System.out.println(jogo.mostrarTabuleiro());
        if (jogador_primeira == 1) {
            jogador_vez = 2;
        } else {
            jogador_vez = 1;
        }
        System.out.println("Agora é a vez do jogador " + jogador_vez);

        do {
            // Ler jogada
            System.out.println("\n\n>>>>>>>>>>>>\n\nLendo jogada:");
            System.out.println("Mostrando mão do jogador1:");
            System.out.println(jogador1.mostrarMao());
            System.out.println("Mostrando mão do jogador2:");
            System.out.println(jogador2.mostrarMao());

            System.out.print("Posição: ");
            posicao = ler.nextInt();
            System.out.print("Ponta: (-1) para esquerda e (1) para direita");
            ponta = ler.nextInt();
            if (jogador_vez == 1) {
                jogo.jogada(jogador1, posicao, ponta);
                jogador_vez = 2;
            } else {
                jogo.jogada(jogador2, posicao, ponta);
                jogador_vez = 1;
            }

            System.out.println("\n\n---------------------\n\nResultado Ler jogada:");
            System.out.println(jogo.mostrarTabuleiro());
            System.out.println("Mostrando mão do jogador1:");
            System.out.println(jogador1.mostrarMao());
            System.out.println("Mostrando mão do jogador2:");
            System.out.println(jogador2.mostrarMao());
            System.out.println("\n\nAgora é a vez do jogador " + jogador_vez);
        } while (true);
    }
}
