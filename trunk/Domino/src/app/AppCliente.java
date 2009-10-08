package app;

import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.net.Socket;
import java.net.UnknownHostException;
import java.util.Scanner;
import jogador.Jogador;
import regras.JogoRegras;

// <editor-fold defaultstate="collapsed" desc=" UML Marker "> 
// #[regen=yes,id=DCE.71BE868F-EB2E-8D60-26BE-0F7E1B2C1739]
// </editor-fold> 
public class AppCliente {

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
        String host = null;
        int porta = 0;

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

        System.out.println("Conectado ao servidor " + host + ":" + porta);
        entrada.readUTF(); // resposta da vez

        //Sincronizando jogo
        jogo = (JogoRegras) entrada.readObject();
        jogador = (Jogador) entrada.readObject();

        entrada.close();
        socket.close();
    }
}

