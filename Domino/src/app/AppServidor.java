package app;

import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.Serializable;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.Scanner;
import jogador.Jogador;
import regras.JogoRegras;

// <editor-fold defaultstate="collapsed" desc=" UML Marker "> 
// #[regen=yes,id=DCE.4AD67B8B-C1D8-A539-4C74-E700A6C62C86]
// </editor-fold> 
public class AppServidor implements Serializable {

    // <editor-fold defaultstate="collapsed" desc=" UML Marker ">
    // #[regen=yes,id=DCE.D755BEEC-6994-4C29-12C6-9BCE84173A85]
    // </editor-fold>
    public static void main(String[] args) throws IOException, ClassNotFoundException {
        JogoRegras jogo = new JogoRegras();
        Jogador jogador1 = new Jogador(1);
        Jogador jogador2 = new Jogador(2);
        Scanner ler = new Scanner(System.in);
        int resposta, posicao = -2, ponta = -2, i = 0;

        System.out.println("Abrindo socket servidor\n");
        ServerSocket serverSocket = new ServerSocket(6000);
        System.out.println("Esperando jogador se conectar");
        Socket socket = serverSocket.accept();
        ObjectInputStream entrada = new ObjectInputStream(socket.getInputStream());
        ObjectOutputStream saida = new ObjectOutputStream(socket.getOutputStream());

        System.out.println("Iniciando jogo.");
        // Inicia o tabuleiro
        System.out.println("Sorteando e renderizando tabuleiro.");
        do {
            jogo.criarTabuleiro();
            jogo.darMao(jogador1);
            jogo.darMao(jogador2);
            jogo.definirDorme();
            // Guarda quem foi o primeiro jogador
            resposta = jogo.primeiraJogada(jogador1, jogador2);
            if (resposta == 1) { // Jogador 1 jogou um carroção
                jogador1.setVez(false);
                jogador2.setVez(true);
                System.out.println("Você começou o jogo.");
                saida.writeObject(jogo);
                saida.writeObject(jogador2);
                System.out.println("Aguardando a jogada do seu oponente");
                System.out.println("\n\n>>>>>>>>>>>>\nTabuleiro:");
                System.out.println(jogo.mostrarTabuleiro());
                jogo = (JogoRegras) entrada.readObject();
                jogador2 = (Jogador) entrada.readObject();
                jogador1.setVez(true);
                jogador2.setVez(false);
            } else if (resposta == 2) {  // Jogador 2 jogou um carroção
                System.out.println("O outro jogador jogou primeiro. Agora é sua vez.");
                if (jogo.passou_vez(jogador1)) {
                    jogador2.setPassou_vez(true);
                    jogador2.setVez(false);
                } else {
                    i++;
                    System.out.println("\n\n>>>>>>>>>>>>\nTabuleiro:");
                    System.out.println(jogo.mostrarTabuleiro());
                    System.out.println("\nJogada " + i + ":");
                    System.out.println("Suas peças:");
                    System.out.println(jogador1.mostrarMao());

                    do {
                        System.out.print("Escolher peça número: ");
                        posicao = ler.nextInt();
                        System.out.print("\n(-1) para cima e (1) para baixo\n");
                        ponta = ler.nextInt();
                    } while (!jogo.jogada(jogador1, posicao, ponta));
                    jogador2.setVez(true);
                    jogador1.setVez(false);
                }
            } else { // jogo.primeiraJogada retorna 0
                jogo = new JogoRegras();
            }
        } while (!jogador1.isVez() && !jogador2.isVez());


        // Controle das jogadas
        do {
            if (jogador1.isVez()) { // Vez do 1
                if (!jogo.passou_vez(jogador1)) { // Se 1 não passou a vez
                    System.out.print("\033[H\033[2J");
                    System.out.println("É sua vez.");
                    do {
                        i++;
                        System.out.println("\n\n>>>>>>>>>>>>\nTabuleiro:");
                        System.out.println(jogo.mostrarTabuleiro());
                        System.out.println("\nJogada " + i + ":");
                        System.out.println("Suas peças:");
                        System.out.println(jogador1.mostrarMao());
                        System.out.print("Escolher peça número: ");
                        posicao = ler.nextInt();
                        System.out.print("\nPonta: (-1) para cima e (1) para baixo\n");
                        ponta = ler.nextInt();
                    } while (!jogo.jogada(jogador1, posicao, ponta));

                    jogador2.setVez(true);
                    jogador1.setVez(false);
                } else {
                    jogador1.setPassou_vez(true);
                    jogador1.setVez(true);
                    jogador2.setVez(false);
                }
            } else if (jogador2.isVez()) { // Vez do 2
                if (!jogo.passou_vez(jogador2)) { // Se 2 não passou a vez
                    System.out.println("Agora é a vez do jogador 2, aguardando...");
                    System.out.print("\033[H\033[2J");
                    saida.writeObject(jogo);
                    saida.writeObject(jogador2);
                    jogo = (JogoRegras) entrada.readObject();
                    jogador2 = (Jogador) entrada.readObject();
                    jogador2.setVez(false);
                    jogador1.setVez(true);
                } else {
                    jogador2.setPassou_vez(true);
                    jogador2.setVez(false);
                    jogador1.setVez(true);
                }
            }

            if (jogador1.isPassou_vez() && jogador2.isPassou_vez()) {
                jogo.setEmpatou(true);
            }
            if (jogador1.isGanhou() || jogador2.isGanhou()) {
                jogo.setGanhou(true);
            }
        } while (!jogo.isGanhou() && !jogo.isEmpatou());

        // Ver quem ganhou ou empate
        if (jogador1.isGanhou()) {
            System.out.println("Você ganhou!");
            saida.writeUTF("Você perdeu, que pena.");
            saida.flush();
        } else if (jogador2.isGanhou()) {
            System.out.println("Você perdeu, que pena.");
            saida.writeUTF("Você ganhou!");
            saida.flush();
        } else {
            int soma1 = jogador1.somaMao();
            int soma2 = jogador2.somaMao();

            if (soma1 > soma2) {
                jogador1.setGanhou(true);
                System.out.println("Você ganhou por soma das peças.\nVocê: " + soma1 + "\nSeu oponente: " + soma2);
                saida.writeUTF("Você perdeu por soma das peças.\nVocê: " + soma2 + "\nSeu oponente: " + soma1);
            } else if (soma1 < soma2) {
                jogador2.setGanhou(true);
                System.out.println("Você perdeu por soma das peças.\nVocê: " + soma2 + "\nSeu oponente: " + soma1);
                saida.writeUTF("Você ganhou por soma das peças.\nVocê: " + soma1 + "\nSeu oponente: " + soma2);
            } else {
                String log = "O jogo se trancou. A soma das peças deu empate. Então: empate!";
                System.out.println(log);
                saida.writeUTF(log);
                saida.flush();
            }
        }

        // Fechando as conexões
        saida.close();
        entrada.close();
        serverSocket.close();
    }
}
