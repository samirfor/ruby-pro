package app;

import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.Serializable;
import java.net.ServerSocket;
import java.net.Socket;
import jogador.Jogador;
import regras.JogoRegras;

// <editor-fold defaultstate="collapsed" desc=" UML Marker "> 
// #[regen=yes,id=DCE.4AD67B8B-C1D8-A539-4C74-E700A6C62C86]
// </editor-fold> 
public class AppServidor implements Serializable {

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
    public static void submit(JogoRegras jogo, Jogador jogador, ObjectOutputStream saida) throws IOException, ClassNotFoundException {
        saida.writeUTF("Libera jogada do submit...");
        saida.writeObject(jogo);
        saida.writeObject(jogador);
    }

    // <editor-fold defaultstate="collapsed" desc=" UML Marker ">
    // #[regen=yes,id=DCE.D755BEEC-6994-4C29-12C6-9BCE84173A85]
    // </editor-fold>
    public static void main(String[] args) throws IOException, ClassNotFoundException {
        JogoRegras jogo = new JogoRegras();
        Jogador jogador1 = new Jogador(1);
        Jogador jogador2 = new Jogador(2);
        String log;
        int resposta, ponta, indice;

        System.out.println("Abrindo socket servidor 1\n");
        ServerSocket serverSocket1 = new ServerSocket(6001);
        System.out.println("Esperando jogador 1 se conectar");
        Socket socket1 = serverSocket1.accept();
        System.out.println("Jogador 1 se conectou.");
        ObjectInputStream entrada1 = new ObjectInputStream(socket1.getInputStream());
        ObjectOutputStream saida1 = new ObjectOutputStream(socket1.getOutputStream());
        System.out.println("Esperando jogador 2...");
        saida1.writeUTF("01: Esperando jogador 2..."); // 1.1
        saida1.flush();

        System.out.println("Abrindo socket servidor 2\n");
        ServerSocket serverSocket2 = new ServerSocket(6002);
        Socket socket2 = serverSocket2.accept();
        System.out.println("Jogador 2 se conectou.");
        ObjectInputStream entrada2 = new ObjectInputStream(socket2.getInputStream());
        ObjectOutputStream saida2 = new ObjectOutputStream(socket2.getOutputStream());
        saida1.writeUTF("02: Conexão OK.\n"); // 1.2
        saida1.flush();
        saida2.writeUTF("01: Você é o jogador 2."); // 2.1
        saida2.flush();
        saida2.writeUTF("02: Conexão com o servidor OK.");// 2.2
        saida2.flush();
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
                jogador2.setVez(true);
                jogador1.setVez(false);
                System.out.println("Jogador 1 começou.");
                saida1.writeUTF("03: Você começou o jogo com um carroção.\nAguardando o outro jogador.");
                saida1.flush(); // 1.3
                saida2.writeUTF("03: Jogador 1 começou o jogo. Agora é a sua vez."); // 2.3
                saida2.flush();
                saida1.writeObject(jogo);
                saida1.writeObject(jogador1);
                saida2.writeObject(jogo);
                saida2.writeObject(jogador2);
                saida2.writeUTF("04: Libera jogada..."); // 2.4
            } else if (resposta == 2) {  // Jogador 2 jogou um carroção
                jogador1.setVez(true);
                jogador2.setVez(false);
                System.out.println("Jogador 2 começou.");
                saida2.writeUTF("03: Você começou o jogo com um carroção.\nAguardando o outro jogador.");
                saida2.flush(); // 2.3
                saida1.writeUTF("03: Jogador 2 começou o jogo. Agora é a sua vez."); // 1.3
                saida1.flush();
                saida1.writeObject(jogo);
                saida1.writeObject(jogador1);
                saida2.writeObject(jogo);
                saida2.writeObject(jogador2);
                saida1.writeUTF("04: Libera jogada..."); // 1.4
            } else { // jogo.primeiraJogada retorna 0
                jogo = new JogoRegras();
            }
        } while (!jogador1.isVez() && !jogador2.isVez());



        // Controle das jogadas
        if (jogador1.isVez()) {
        saida1.writeObject(jogo);
        saida1.writeObject(jogador1);
        } else {
        saida2.writeObject(jogo);
        saida2.writeObject(jogador2);
        }

        do {
            if (jogador1.isVez()) { // Vez do 1
                if (!jogo.passou_vez(jogador1)) { // Se 1 não passou a vez
                    jogador2.setVez(false);
                    jogador1.setVez(true);
                    System.out.println("Agora é a vez do jogador 1");
                    saida1.writeUTF("Liberando jogada.");
                    saida1.flush();
                    jogo = (JogoRegras) entrada1.readObject(); // Sincroniza jogo
                    jogador1 = (Jogador) entrada1.readObject(); // Sincroniza jogador
                    jogador2.setVez(true);
                    jogador1.setVez(false);
                    saida2.writeObject(jogo);
                    saida2.writeObject(jogador2);
                } else {
                    jogador1.setPassou_vez(true);
                }
            } else if (jogador2.isVez()) { // Vez do 2
                if (!jogo.passou_vez(jogador2)) {
                    jogador2.setVez(true);
                    jogador1.setVez(false);
                    System.out.println("Agora é a vez do jogador 2");
                    saida2.writeUTF("Liberando jogada.");
                    saida2.flush();
                    jogo = (JogoRegras) entrada2.readObject(); // Sincroniza jogo
                    jogador2 = (Jogador) entrada2.readObject(); // Sincroniza jogador
                    jogador2.setVez(false);
                    jogador1.setVez(true);
                    saida1.writeObject(jogo);
                    saida1.writeObject(jogador1);
                } else {
                    jogador2.setPassou_vez(true);
                }
            }


            if (jogador1.isPassou_vez() && jogador2.isPassou_vez()) {
                jogo.setEmpatou(true);
            }
            if (jogador1.isGanhou() || jogador2.isGanhou()) {
                jogo.setGanhou(true);
            }
        } while (!jogo.isGanhou() && !jogo.isEmpatou());

        // Ver quem ganhou
        if (jogador1.isGanhou()) {
            saida1.writeUTF("Você venceu!");
            saida1.flush();
            saida2.writeUTF("Você perdeu, que pena.");
            saida2.flush();
        } else if (jogador2.isGanhou()) {
            saida1.writeUTF("Você perdeu, que pena.");
            saida1.flush();
            saida2.writeUTF("Você venceu!");
            saida2.flush();
        } else {
            log = "O jogo se trancou. Empate!";
            saida1.writeUTF(log);
            saida1.flush();
            saida2.writeUTF(log);
            saida2.flush();
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
