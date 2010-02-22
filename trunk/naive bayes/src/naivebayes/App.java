/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package naivebayes;

import java.util.ArrayList;

/**
 *
 * @author jonas
 */
public class App {
    public static void main(String[] args) {
        ArrayList<Double> porcentagens = new ArrayList<Double>();
        int tamanho=10;
        double desvio;

        for (int i = 0; i <tamanho; i++) {
            porcentagens.add(Estatistica.estatistica());

        }
        desvio = DesvioPadrao.getDesvioPadrao(porcentagens);
        System.out.println("desvio padrao "+ desvio);

    }

}
