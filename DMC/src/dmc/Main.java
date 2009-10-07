/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package dmc;

import static org.math.io.files.ASCIIFile.readDoubleArray;
import java.io.File;

/**
 *
 * @author alunos
 */
public class Main {

    public static void main(String[] args) {

        BancoDados treinamento = new BancoDados();
        BancoDados teste = new BancoDados();
        double[][] atributos = readDoubleArray(new File("iris.data"));
        boolean flag = true; // flag para adição de iris
        int indice = 0, i = 0;

        while (i < 120) { // armazena 120 casos aleatórios de iris
            flag = true;
            indice = (int) (Math.random() * 149); // indice aleatório para calcular o dmc
            if (i != 0) {
                // Evita que uma mesma iris seja armazenada mais de uma vez no BancoDados treinamento
                for (int j = 0; j < treinamento.size(); j++) {
                    Padrao padrao = treinamento.getPadrao(j);
                    if (padrao.getComprimentoSepala() == atributos[indice][0] &&
                            padrao.getLarguraSepala() == atributos[indice][1] &&
                            padrao.getComprimentoPetala() == atributos[indice][2] &&
                            padrao.getLarguraPetala() == atributos[indice][3]) {
                        flag = false;
                        break;
                    }
                }
            }

            if (flag) { // adiciona a iris no BancoDados treinamento
                Padrao padrao = new Padrao(atributos[indice][0], atributos[indice][1],
                        atributos[indice][2], atributos[indice][3], Classificacao.SETOSA);
                if (atributos[indice][4] == 1.0) {
                    padrao.setClasse(Classificacao.SETOSA);
                } else if (atributos[indice][4] == 2.0) {
                    padrao.setClasse(Classificacao.VERSICOLOR);
                } else { //if (atributos[indice][4] == 3.0) {
                    padrao.setClasse(Classificacao.VIRGINICA);
                }
                treinamento.add(padrao);
                i++;
            }
        }

        // cria um objeto dmc com o BancoDados treinamento pronto
        DMC dmc = new DMC(treinamento);
        i = 0;
        System.out.println("\n-------------\n");
        System.out.println("Teste:");
        while (i < 50) { // Procura os casos restantes de iris
            flag = true;
            indice = (int) (Math.random() * 149);

            // Evita que uma iris do treinamento seja utilizado no teste
            for (int j = 0; j < treinamento.size(); j++) {
                Padrao padrao = treinamento.getPadrao(j);
                if (padrao.getComprimentoSepala() == atributos[indice][0] &&
                        padrao.getLarguraSepala() == atributos[indice][1] &&
                        padrao.getComprimentoPetala() == atributos[indice][2] &&
                        padrao.getLarguraPetala() == atributos[indice][3]) {
                    flag = false;
                    break;
                }
            }

            if (flag) {
                // Classifica a iris atraves do dmc
                Classificacao classe = dmc.classificar(atributos[indice][0],
                        atributos[indice][1], atributos[indice][2],
                        atributos[indice][3]);
                Padrao padrao = new Padrao(atributos[indice][0],
                        atributos[indice][1], atributos[indice][2],
                        atributos[indice][3], classe);

                System.out.println("\nPlanta " + (i + 1) + ":   ");
                System.out.println(padrao.getComprimentoSepala() + " " +
                        padrao.getLarguraSepala() + " " +
                        padrao.getComprimentoPetala() + " " +
                        padrao.getLarguraPetala() + "\n" + padrao.getClasse());
                teste.add(padrao);
                i++;
            }
        }

        System.out.println("\n-------------\n");
        // Calcula o percentual de acertos
        double acertos = 0;

        for (i = 0; i < teste.size(); i++) {
            Padrao padrao = teste.getPadrao(i);
            double classe = 0.0;

            for (int j = 0; j < 150; j++) {

                if (padrao.getClasse() == Classificacao.SETOSA) {
                    classe = 1.0;
                } else if (padrao.getClasse() == Classificacao.VERSICOLOR) {
                    classe = 2.0;
                } else if (padrao.getClasse() == Classificacao.VIRGINICA) {
                    classe = 3.0;
                }

                if (padrao.getComprimentoSepala() == atributos[j][0] &&
                        padrao.getLarguraSepala() == atributos[j][1] &&
                        padrao.getComprimentoPetala() == atributos[j][2] &&
                        padrao.getLarguraPetala() == atributos[j][3] &&
                        classe == atributos[j][4]) {
                    acertos += 1;
                }
            }
        }
        double percentual = (acertos / teste.size()) * 100;

        System.out.println("acertos: " + acertos);
        System.out.println("teste.size(): " + teste.size());
        System.out.println("\nPercentual de Acertos: " + percentual + "%");
    }
}
