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
    public static void submit(JogoRegras jogo, Jogador j1, Jogador j2, ObjectOutputStream s1, ObjectOutputStream s2) throws IOException, ClassNotFoundException {
        s1.writeObject(jogo);
        s2.writeObject(jogo);
        s1.writeObject(j1);
        s2.writeObject(j2);
    }

    /**
     * Enquanto houver dorme, o jogador que passar vai puxar e o método retorna
     * true. Se não houver dorme, retorna false.
     * @param jogo
     * @param jogador
     * @return
     */
    public static boolean passou_vez(JogoRegras jogo, Jogador jogador) {
        while (jogo.passou(jogador)) { // Enquanto o jogador passar:
            if (jogo.getDorme().size() != 0) { // Se houver dorme
                jogo.puxa_do_dorme(jogador); // O jogador puxa.
            } else { // Se não houver dorme
                return true;
            }
        }
        return false; // Jogador não passou a vez
    }

    // <editor-fold defaultstate="collapsed" desc=" UML Marker ">
    // #[regen=yes,id=DCE.D755BEEC-6994-4C29-12C6-9BCE84173A85]
    // </editor-fold>
    public static void main(String[] args) throws IOException, ClassNotFoundException {
        JogoRegras jogo = new JogoRegras();
        Jogador jogador1 = new Jogador(1);
        Jogador jogador2 = new Jogador(2);
        Jogador jogador_da_vez, jogador_anterior;
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
        saida1.writeUTF(log);

        System.out.println("Abrindo socket servidor 2\n");
        ServerSocket serverSocket2 = new ServerSocket(5002);
        Socket socket2 = serverSocket2.accept();
        System.out.println("Jogador 2 se conectou.");
        ObjectInputStream entrada2 = new ObjectInputStream(socket2.getInputStream());
        ObjectOutputStream saida2 = new ObjectOutputStream(socket2.getOutputStream());
        saida1.writeUTF("Conexão OK.\n");
        saida2.writeUTF("\nVocê é o jogador 2.");
        saida2.writeUTF("Conexão com o servidor OK.");
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
                jogador_da_vez = jogador2;
                System.out.println("Jogador 1 começou.");
                saida1.writeUTF("Você começou o jogo com um carroção.\nAguardando o outro jogador."); // saida1 envia: 1
                saida2.writeUTF("Jogador 1 começou o jogo. Agora é a sua vez.");
            } else if (resposta == 2) {
                jogador_da_vez = jogador1;
                System.out.println("Jogador 2 começou.");
                saida2.writeUTF("Você começou o jogo com um carroção.\nAguardando o outro jogador."); // saida2 envia: 1
                saida1.writeUTF("Jogador 2 começou o jogo. Agora é a sua vez.");
            } else { // jogo.primeiraJogada retorna 0
                jogador_da_vez = null;
                jogo = new JogoRegras();
            }
        } while (jogador_da_vez.equals(null));

        // Controle das jogadas
        do {
            jogador_anterior = jogador_da_vez; // Guarda referência do jogador da vez
            if (jogador_da_vez.getId() == 1) { // Se é a vez do jogador 1
                if (passou_vez(jogo, jogador1)) { // Se jogador 1 passou a vez
                    jogador1.setPassou_vez(true);
                    if (!jogador2.isPassou_vez()) { // Se jogador 2 não passou a vez
                        jogador_da_vez = jogador2;  // Seta vez para jogador 2
                    } else { // Se jogador 2 também passou a vez
                        jogo.setEmpatou(true);
                    }
                } else { // jogador 1 não passou a vez
                    jogador_da_vez = jogador2;  // Seta vez para jogador 2
                }
            } else { // Se é a vez do jogador 2
                if (passou_vez(jogo, jogador2)) { // Se jogador 2 passou a vez
                    jogador2.setPassou_vez(true);
                    if (!jogador1.isPassou_vez()) { // Se jogador 1 não passou a vez
                        jogador_da_vez = jogador1;  // Seta vez para jogador 1
                    } else { // Se jogador 1 também passou a vez
                        jogo.setEmpatou(true);
                    }
                } else { // jogador 2 não passou a vez
                    jogador_da_vez = jogador1;  // Seta vez para jogador 1
                }
            }
            // Envia dados do jogo para os clientes
            submit(jogo, jogador1, jogador2, saida1, saida2);
            // Ler dados do jogo dos clientes dependendo da vez
            if (jogador_da_vez.getId() == 1) { // Jogador 1 jogou?
                jogo = (JogoRegras) entrada1.readObject(); // Sincroniza jogo
                jogador1 = (Jogador) entrada1.readObject(); // Sincroniza jogador1
            } else { // Jogador 2 jogou?
                jogo = (JogoRegras) entrada2.readObject(); // Sincroniza jogo
                jogador2 = (Jogador) entrada2.readObject(); // Sincroniza jogador2
            }
        } while (!jogo.isGanhou() && !jogo.isEmpatou());

        // Ver quem ganhou
        if (jogador1.isGanhou()) {
            saida1.writeUTF("Você venceu!");
            saida2.writeUTF("Você perdeu, que pena.");
        } else if (jogador2.isGanhou()){
            saida1.writeUTF("Você perdeu, que pena.");
            saida2.writeUTF("Você venceu!");
        } else {
            log = "O jogo se trancou. Empate!";
            saida1.writeUTF(log);
            saida2.writeUTF(log);
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
