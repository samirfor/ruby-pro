package app;

import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.Serializable;
import java.net.Socket;
import java.net.UnknownHostException;
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
    public static void main(String[] args) throws UnknownHostException, IOException, ClassNotFoundException {
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
            System.out.print("Informe o IP do servidor: ");
            host = ler.next();
            System.out.print("Porta: ");
            porta = ler.nextInt();
        } while (host.equals(null) || porta == 0);

        socket = new Socket(host, porta);
        saida = new ObjectOutputStream(socket.getOutputStream());
        entrada = new ObjectInputStream(socket.getInputStream());

        System.out.println("Conectado a " + host + ":" + porta);

        System.out.println(entrada.readUTF());
        System.out.println(entrada.readUTF());
        System.out.println(entrada.readUTF());

        System.out.println("\n>>>>>>>>>>>>>>>>>>>>");
        System.out.println("Iniciando jogo.");
        do {
            // Recebe os dados do jogo
            System.out.println("Lendo objeto jogo");
            jogo = (JogoRegras) entrada.readObject();
            System.out.println("Lendo objeto jogador");
            jogador = (Jogador) entrada.readObject();

            if (!jogador.isVez()) {
                System.out.println("Esperando o outro jogador...");
                System.out.println(entrada.readUTF());
            }

            i++;
            System.out.println("\n\n>>>>>>>>>>>>\nTabuleiro:");
            System.out.println(jogo.mostrarTabuleiro());
            System.out.println("\nJogada " + i + ":");
            System.out.println("Suas peças:");
            System.out.println(jogador.mostrarMao());

            do {
                System.out.print("Escolher peça número: ");
                posicao = ler.nextInt();
                System.out.print("\n(-1) para cima e (1) para baixo\n");
                ponta = ler.nextInt();
            } while (!jogo.jogada(jogador, posicao, ponta));
            if (jogador.getMao().size() == 0) {
                jogo.setGanhou(true);
            }

            jogador.setVez(false);
            System.out.println("Enviando objeto jogo");
            saida.writeObject(jogo);
            System.out.println("Enviando objeto jogador");
            saida.writeObject(jogador);
        } while (!jogo.isEmpatou() && !jogo.isGanhou());

        System.out.println(entrada.readUTF()); // Fala quem venceu ou empate.

        // Fecha conexões
        entrada.close();
        saida.close();
        socket.close();
    }
}

