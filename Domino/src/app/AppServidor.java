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

    public static void sincronizar(JogoRegras jogo, Jogador j1, Jogador j2, ObjectOutputStream s1, ObjectOutputStream s2) throws IOException, ClassNotFoundException {
        s1.writeObject(jogo);
        s2.writeObject(jogo);
        s1.writeObject(j1);
        s2.writeObject(j2);
    }
    // <editor-fold defaultstate="collapsed" desc=" UML Marker "> 
    // #[regen=yes,id=DCE.D755BEEC-6994-4C29-12C6-9BCE84173A85]
    // </editor-fold> 

    public static void main(String[] args) throws IOException, ClassNotFoundException {
        JogoRegras jogo = new JogoRegras();
        Jogador jogador1 = new Jogador(1);
        Jogador jogador2 = new Jogador(2);
        Jogador primeiro_jogador, jogador_da_vez;
        Scanner ler = new Scanner(System.in);
        int posicao, ponta;
        String log;
//        boolean sinal_verde = false;

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
        log = "Iniciando jogo.";
        System.out.println(log);
        saida2.writeUTF(log); // saida2 envia: 1

        // Inicia o tabuleiro
        do {
            jogo.criarTabuleiro();
            jogo.darMao(jogador1);
            jogo.darMao(jogador2);
            jogo.definirDorme();
            // Guarda quem foi o primeiro jogador
            int resposta = jogo.primeiraJogada(jogador1, jogador2);
            if (resposta == 1) {
                primeiro_jogador = jogador1;
                saida1.writeUTF("Você começou o jogo com um carroção.\nAguardando o outro jogador."); // saida1 envia: 1
            } else if (resposta == 2) {
                primeiro_jogador = jogador2;
                saida2.writeUTF("Você começou o jogo com um carroção.\nAguardando o outro jogador."); // saida2 envia: 1
            } else {
                primeiro_jogador = null;
                jogo = new JogoRegras();
            }
        } while (primeiro_jogador.equals(null));

        //Sincronizando jogo
        sincronizar(jogo, jogador1, jogador2, saida1, saida2);


        // Fechando as conexões
        saida1.close();
        saida2.close();
        entrada1.close();
        entrada2.close();
        serverSocket1.close();
        serverSocket2.close();
    }
}

