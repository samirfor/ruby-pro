package app;

import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.Serializable;
import java.net.Socket;
import java.net.UnknownHostException;
import java.util.InputMismatchException;
import java.util.Scanner;
import jogador.Jogador;
import regras.JogoRegras;

// <editor-fold defaultstate="collapsed" desc=" UML Marker "> 
// #[regen=yes,id=DCE.71BE868F-EB2E-8D60-26BE-0F7E1B2C1739]
// </editor-fold> 
public class AppCliente implements Serializable {

    // <editor-fold defaultstate="collapsed" desc=" UML Marker "> 
    // #[regen=yes,id=DCE.A8804613-376E-3AB2-7CAC-94EB899A5C8E]
    // </editor-fold> 
    public static void run() throws UnknownHostException, IOException, ClassNotFoundException {
        Jogador jogador = null;
        JogoRegras jogo = null;
        Socket socket = null;
        ObjectInputStream entrada = null;
        ObjectOutputStream saida = null;
        Scanner ler = new Scanner(System.in);
        String host = null, log;
        int porta = 0, i = 0, posicao, ponta;

        // Captura endereço do servidor
        do {
            try {
                System.out.print("Informe o IP do servidor: ");
                host = ler.next();
                System.out.print("Porta: ");
                porta = ler.nextInt();
            } catch (InputMismatchException e) {
                ler = new Scanner(System.in);
            }
        } while (host.equals(null) || porta == 0);

        socket = new Socket(host, porta);
        saida = new ObjectOutputStream(socket.getOutputStream());
        entrada = new ObjectInputStream(socket.getInputStream());

        System.out.println("Conectado a " + host + ":" + porta);

        System.out.println("\n>>>>>>>>>>>>>>>>>>>>");
        System.out.println("Iniciando jogo.");
        System.out.println("Você é o jogador 2.");
        do {
            System.out.println("Aguardando o jogador 1...");
            // Recebe os dados do jogo;
            jogo = (JogoRegras) entrada.readObject();
            jogador = (Jogador) entrada.readObject();
            System.out.print("\033[H\033[2J");
            if (jogo.passouVez(jogador)) {
                jogador.setPassouVez(true);
                jogador.setVez(false);
            } else { // joga
                jogo.soutJogada(jogador);
            }
            if (jogador.getMao().size() == 0) {
                jogo.setGanhou(true);
            }
            jogador.setVez(false);
            saida.writeObject(jogo);
            saida.writeObject(jogador);
        } while (!jogo.isEmpatou() && !jogo.isGanhou());

        jogador = (Jogador) entrada.readObject();
        System.out.println(jogador.getStatus()); // Informa quem venceu ou empate.

        // Fecha conexões
        entrada.close();
        saida.close();
        socket.close();
    }
}

