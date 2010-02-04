/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package naivebayes;

import java.util.ArrayList;
import java.util.Random;
import static org.math.io.files.ASCIIFile.readDoubleArray;
import java.io.File;

/**
 *
 * @author JonasRodrigues
 */
public class Estatistica {

    public static void main(String[] args) {
        ArrayList<PadraoIris> treinamento = new ArrayList<PadraoIris>();
        ArrayList<PadraoIris> teste = new ArrayList<PadraoIris>();
        ArrayList<Integer> indexRepetidos = new ArrayList<Integer>();
        Random num = new Random();
        boolean repeticao = false;
        double tipo, acertos = 0.0;
        double[][] atributos = readDoubleArray(new File("iris_1.data"));
        int index = 0, count = 0;
        PadraoIris p;

        while (count < 120) {
            repeticao = false;
           index = num.nextInt(150);
          

            for (int i = 0; i < indexRepetidos.size(); i++) {
                if (index == indexRepetidos.get(i)) {
                    repeticao = true;
                    break;
                }
            }
           if (!repeticao) {
                p = new PadraoIris(atributos[index][0], atributos[index][1], atributos[index][2],
                        atributos[index][3], Classificacao.SETOSA);
                if (atributos[index][4] == 1.0) {
                    p.setClasse(Classificacao.SETOSA);
                } else if (atributos[index][4] == 2.0) {
                    p.setClasse(Classificacao.VERSICOLOR);
                } else {
                    p.setClasse(Classificacao.VIRGINICA);
                }
                //System.out.println(atributos[index][0]+""+ atributos[index][1]+ atributos[index][2]+atributos[index][3] + p.getClasse());
                indexRepetidos.add(index);
                treinamento.add(p);
                count++;
                //index+=26;
            }
        }
        count = 0;
        NaiveBayes naive = new NaiveBayes(treinamento);
        //teste
        index=10;
        while (count < 30) {
            index = num.nextInt(150);
            repeticao = false;

            for (int i = 0; i < indexRepetidos.size(); i++) {
                if (indexRepetidos.get(i) == index) {
                    repeticao = true;
                    break;
                }
            }
            if (!repeticao) {
                Classificacao classe = naive.classificar(atributos[index][0], atributos[index][1], atributos[index][2], atributos[index][3]);
                p = new PadraoIris(atributos[index][0], atributos[index][1], atributos[index][2], atributos[index][3], classe);
                indexRepetidos.add(index);
                teste.add(p);
                count++;
                //index+=50;
            }
        }

        for (int i = 0; i < teste.size(); i++) {
            p = teste.get(i);
            if (p.getClasse() == Classificacao.SETOSA) {
                tipo = 1.0;
            } else if (p.getClasse() == Classificacao.VERSICOLOR) {
                tipo = 2.0;
            } else {
                tipo = 3.0;
            }
            for (int j = 0; j < 150; j++) {
                if ((p.getTamanho_sepala() == atributos[j][0]) && (p.getLargura_sepala() == atributos[j][1]) && (p.getTamanho_petala() == atributos[j][2]) && (p.getLargura_petala() == atributos[j][3]) && tipo == atributos[j][4]) {
                    acertos++;
                   // System.out.println(" classe " + tipo);
                    break;
                }
            }

        }
        double percentual = ((acertos / teste.size()) * 100);
        System.out.println("acertos = " + percentual);
    }
}
