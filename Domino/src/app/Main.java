package app;

import java.util.InputMismatchException;
import java.util.Scanner;

/**
 * Chama o cliente e servidor e o usuário escolhe.
 * @author samir
 */
public class Main {

    public Main() {
    }

    public static void main(String[] args) {
        try {
            MainInterface.main(args);
        } catch (Exception e) {
            System.out.println("Não foi possível abrir em modo gráfico.");
            System.out.println("\nExecutando modo texto:");
            Scanner ler;
            int resposta;
            do {
                resposta = 0;
                ler = new Scanner(System.in);
                System.out.println(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
                System.out.println("Você deseaja iniciar um jogo ou entrar em um?");
                System.out.println("\n(1) para criar e (2) para entrar | Ctrl + C para sair");
                System.out.print("Opção: ");
                try {
                    resposta = ler.nextInt();
                } catch (InputMismatchException l) {
                    System.out.println("\n>> Digite um número válido!\n");
                }
            } while (resposta != 1 && resposta != 2);

            if (resposta == 2) {
                try {
                    AppCliente.run();
                } catch (Exception h) {
                    System.out.println("Não foi possível entrar em um jogo.");
                    System.out.println(e);
                }
            } else {
                do {
                    resposta = 0;
                    System.out.print("Porta: ");
                    try {
                        resposta = ler.nextInt();
                    } catch (InputMismatchException g) {
                        System.out.println("\n>> Digite um número válido!\n");
                        ler = new Scanner(System.in);
                    }
                } while (resposta <= 0);
                try {
                    AppServidor.run(resposta);
                } catch (Exception f) {
                    System.out.println("Não foi possível abrir um servidor.");
                    System.out.println(f);
                }
            }
        }
    }
}
