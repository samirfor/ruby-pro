package perceptron;

import java.util.ArrayList;

/**
 * Faz cálculos da média e desvio padrão dos resultados obtidos.
 * @author Samir Coutinho Costa <samirfor@gmail.com>
 */
public class Estatistica {

    public static void main(String[] args) {
        final int LOOP = 2;
        double somax = 0, calculo = 0, media = 0, desvio = 0, porcentagem;
        ArrayList<Double> porcentagens = new ArrayList<Double>();

        for (int i = 0; i < LOOP; i++) {
            porcentagem = Main.run();
            somax += porcentagem;
            porcentagens.add(porcentagem);
        }
        media = somax / LOOP;
        System.out.println("\n\n>>>>>>>>>>>>>>>>>>>>>>>>>>>");
//        System.out.println("Porcentagens:");
        for (int i = 0; i < porcentagens.size(); i++) {
//            System.out.println(porcentagens.get(i));
            calculo += Math.pow((porcentagens.get(i) - media), 2);
        }
        System.out.println("Média aritmética: " + media);
        desvio = Math.sqrt(calculo / LOOP);
        System.out.println("Desvio padrão: " + desvio);
    }
}
