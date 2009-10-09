package app;

import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.Scanner;
import jogador.Jogador;
import regras.JogoRegras;

// <editor-fold defaultstate="collapsed" desc=" UML Marker "> 
// #[regen=yes,id=DCE.4AD67B8B-C1D8-A539-4C74-E700A6C62C86]
// </editor-fold> 
public class AppServidor {

    /**
     * Envia os dados para os clientes, sincronizando com os dados do servidor.
     * @param jogo
     * @param j1
     * @param j2
     * @param s1
     * @param s2
     * @throws IOException
     * @throws ClassNotFoundException
     */
    public static void submit(JogoRegras jogo, Jogador j1, Jogador j2, ObjectOutputStream s1, ObjectOutputStream s2) throws IOException, ClassNotFoundException {
        s1.writeObject(jogo);
        s2.writeObject(jogo);
        s1.writeObject(j1);
        s2.writeObject(j2);
    }


    /**
     * Ainda em construção... Aqui q tem q bulir e adequar.
     * @param jogo
     * @param jogador
     * @return
     */
    public static Jogador le_jogada(JogoRegras jogo, Jogador jogador) {
        Scanner ler = new Scanner(System.in);
        int ponta, posicao;

        // Trata o "passa"
        while (jogo.passou(jogador)) {
            if (jogo.getDorme().size() != 0) {
                jogo.puxa_do_dorme(jogador);
            } else { // Caso o dorme acabe
                // Seta jogador da vez

                // Se for o jogador 1 e o jogador 2 passou a vez
                if (jogador.getId() == 1 && !jogador2.isPassou_vez()) {
                    jogador.setPassou_vez(true);
                    jogador = jogador2;
                } else {
                    if (!jogador1.isPassou_vez()) {
                        jogador.setPassou_vez(true);
                        jogador = jogador1;
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
        return jogador;
    }
    // <editor-fold defaultstate="collapsed" desc=" UML Marker "> 
    // #[regen=yes,id=DCE.D755BEEC-6994-4C29-12C6-9BCE84173A85]
    // </editor-fold> 

    public static void main(String[] args) throws IOException, ClassNotFoundException {
        JogoRegras jogo = new JogoRegras();
        Jogador jogador1 = new Jogador(1);
        Jogador jogador2 = new Jogador(2);
        Jogador primeiro_jogador, jogador_da_vez;
        String log;
        int resposta, ponta, indice;

        System.out.println("Abrindo socket servidor 1\n");
        ServerSocket serverSocket1 = new ServerSocket(5001);

        System.out.println("Esperando jogador 1 se conectar");
        Socket socket1 = serverSocket1.accept();
        System.out.println("Jogador 1 se conectou.");
        ObjectInputStream entrada1 = new ObjectInputStream(socket1.getInputStream());
        ObjectOutputStream saida1 = new ObjectOutputStream(socket1.getOutputStream());

        log = "Esperando jogador 2...";
        System.out.println(log);
        saida1.writeUTF(log); // saida1 envia: 0

        System.out.println("Abrindo socket servidor 2\n");
        ServerSocket serverSocket2 = new ServerSocket(5002);
        Socket socket2 = serverSocket2.accept();
        System.out.println("Jogador 2 se conectou.");
        ObjectInputStream entrada2 = new ObjectInputStream(socket2.getInputStream());
        ObjectOutputStream saida2 = new ObjectOutputStream(socket2.getOutputStream());
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
            if (resposta == 1) {
                primeiro_jogador = jogador1;
                System.out.println("Jogador 1 começa.");
                saida1.writeUTF("Você começou o jogo com um carroção.\nAguardando o outro jogador."); // saida1 envia: 1
                saida2.writeUTF("Jogador 1 começou o jogo. Agora é a sua vez.");
            } else if (resposta == 2) {
                primeiro_jogador = jogador2;
                System.out.println("Jogador 2 começa.");
                saida2.writeUTF("Você começou o jogo com um carroção.\nAguardando o outro jogador."); // saida2 envia: 1
                saida1.writeUTF("Jogador 2 começou o jogo. Agora é a sua vez."); 
            } else {
                primeiro_jogador = null;
                jogo = new JogoRegras();
            }
        } while (primeiro_jogador.equals(null));

        // Seta jogador da vez para a 1a jogada
        if (primeiro_jogador.getId() == 1) {
            jogador_da_vez = jogador2;
        } else {
            jogador_da_vez = jogador1;
        }

        /**
         * Até aki é pra tá certo.
         * Falta implementar direitim o le_jogada()
         * A lógica é mais ou menos essa abaixo:
         */


        //Lê jogadas
        do {
            if (jogador_da_vez.getId() == 1) {
                jogador_da_vez = le_jogada(jogador1);
            } else {
                jogador_da_vez = le_jogada(jogador2);
            }
        } while (!jogador_da_vez.isGanhou() && !jogo.empatou(jogador1, jogador2));

        /**
         * Esse empate ainda vai sair daqui...
         */
        // Empatou
        log = "O jogo empatou.";
        saida1.writeUTF(log);
        saida2.writeUTF(log);

        // Envia dados do jogo para os clientes
        submit(jogo, jogador1, jogador2, saida1, saida2);

        // Ver quem ganhou
        if (jogador1.isGanhou()) {
            saida1.writeUTF("Você venceu!");
            saida2.writeUTF("Você perdeu, que pena.");
        } else {
            saida1.writeUTF("Você perdeu, que pena.");
            saida2.writeUTF("Você venceu!");
        }

        // Fechando as conexões
        saida1.close();
        saida2.close();
        entrada1.close();
        entrada2.close();
        socket1.close();
        socket2.close();
        serverSocket1.close();
        serverSocket2.close();
    }
}

