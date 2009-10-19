

import java.util.Scanner;
import jogador.Jogador;
import regras.JogoRegras;

public class Teste {

    public static void main(String[] args) {

        JogoRegras jogo = new JogoRegras();
        Jogador jogador1 = new Jogador(1);
        Jogador jogador2 = new Jogador(2);
        Jogador primeiro_jogador, jogador_da_vez;
        Scanner ler = new Scanner(System.in);
        int posicao, ponta;

        // Inicia o tabuleiro
        do {
            jogo.criarTabuleiro();
            jogo.darMao(jogador1);
            jogo.darMao(jogador2);
            jogo.definirDorme();
            int resposta = jogo.primeiraJogada(jogador1, jogador2);
            if (resposta == 1) {
                primeiro_jogador = jogador1;
            } else if (resposta == 2) {
                primeiro_jogador = jogador2;
            } else {
                primeiro_jogador = null;
            }
        } while (primeiro_jogador.equals(null));

        System.out.println("Jogador " + primeiro_jogador.getId() + " jogou a primeira peça.\n");
        System.out.println("Mostrando tabuleiro (1a jogada):");
        System.out.println(jogo.mostrarTabuleiro());

        // Seta jogador da vez
        if (primeiro_jogador.getId() == 1) {
            jogador_da_vez = jogador2;
        } else {
            jogador_da_vez = jogador1;
        }
        System.out.println("Agora é a vez do jogador " + jogador_da_vez.getId());

        // Ler jogadas
        do {
            // Trata o "passa"
            while (jogo.passou(jogador_da_vez)) {
                if (jogo.getDorme().size() != 0) {
                    jogo.puxaDorme(jogador_da_vez);
                } else { // Caso o dorme acabe
                    // Seta jogador da vez

                    // Se for o jogador 1 e o jogador 2 passou a vez
                    if (jogador_da_vez.getId() == 1 && !jogador2.isPassou_vez()) {
                        jogador_da_vez.setPassouVez(true);
                        jogador_da_vez = jogador2;
                    } else {
                        if (!jogador1.isPassou_vez()) {
                            jogador_da_vez.setPassouVez(true);
                            jogador_da_vez = jogador1;
                        } else {
                            System.out.println("Empatou!");
                            System.exit(0); //Encerra o programa.
                        }
                    }
                }
            }

            System.out.println("\n\n>>>>>>>>>>>>\n\nLendo jogada:");
            System.out.println("Mostrando mão do jogador1:");
            System.out.println(jogador1.mostrarMao());
            System.out.println("Mostrando mão do jogador2:");
            System.out.println(jogador2.mostrarMao());

            System.out.println("Tamanho do dorme: " + jogo.getDorme().size());
            System.out.println("Pontas: " + jogo.mostraPontas());
            System.out.print("Posição da peça: ");
            posicao = ler.nextInt();
            System.out.print("\nPonta: (-1) para cima e (1) para baixo\n");
            ponta = ler.nextInt();

            // Define de quem é a vez e faz a jogada.
            if (jogador_da_vez.getId() == 1 && jogo.jogada(jogador1, posicao, ponta)) {
                if (jogador_da_vez.isGanhou()) { // Jogador ganhou?
                    break;
                } else {
                    jogador_da_vez = jogador2;
                }
            } else {
                if (jogo.jogada(jogador2, posicao, ponta)) {
                    if (jogador_da_vez.isGanhou()) { // Jogador ganhou?
                        break;
                    } else {
                        jogador_da_vez = jogador1;
                    }
                }
            }

            System.out.println("\n---------------------\nTabuleiro resultante:");
            System.out.println(jogo.mostrarTabuleiro());
            System.out.println("\nAgora é a vez do jogador " + jogador_da_vez.getId());
        } while (!jogador_da_vez.isGanhou());

        System.out.println("Jogador " + jogador_da_vez.getId() + " ganhou!");
    }
}
