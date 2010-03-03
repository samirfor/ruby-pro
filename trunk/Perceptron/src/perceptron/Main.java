package perceptron;

import static org.math.io.files.ASCIIFile.readDoubleArray;
import java.io.File;

/**
 * Classificação de padrões através de a implementação do algoritmo
 * Perceptron Simples.
 * @author Samir Coutinho Costa <samirfor@gmail.com>
 */
public class Main {

    private static boolean isAdicionarPadrao(BancoDados banco, double[][] atributos, int indice) {

        for (int j = 0; j < banco.tamanho(); j++) {
            Padrao p = banco.getPadrao(j);
            if (p.getComprimentoSepala() == atributos[indice][0]
                    && p.getLarguraSepala() == atributos[indice][1]
                    && p.getComprimentoPetala() == atributos[indice][2]
                    && p.getLarguraPetala() == atributos[indice][3]) {
                return false;
            }
        }

        return true;

    }

    /**
     * Executa o programa.
     * @return percentual - retorna a precisão do algoritmo em porcentagem.
     */
    public static void main(String[] args) {

        BancoDados treinamento = new BancoDados();
        BancoDados teste = new BancoDados();
        Perceptron perceptron = new Perceptron();
        double[][] atributos = readDoubleArray(new File("iris.data"));
        int[] irisEscolhidas = new int[120];
        int[] testesEscolhidos = new int[30];
        int indice, i, linha, cont, quantidade = 10;
        boolean adicionar = true;
        double desvioPadrao, acertos, media = 0;
        double[] percentual = new double[10];

        System.out.println("\n________________________________________________\n");

        cont = 0;
        while (cont < 10) {
            System.out.println("Treinando Perceptron com iris de: "
                    + (cont + 1) + "º iteracao");
            treinamento.clear();
            teste.clear();
            System.out.println("Escolhendo Aleatoriamente as iris de Treinamento");

            i = 0;
            while (i < 120) {

                indice = (int) (Math.random() * 149);

                if (isAdicionarPadrao(treinamento, atributos, indice) || i == 0) {

                    Padrao p = new Padrao(
                            atributos[indice][0],
                            atributos[indice][1],
                            atributos[indice][2],
                            atributos[indice][3],
                            Classificacao.SETOSA);
                    irisEscolhidas[i] = indice;

                    if (atributos[indice][4] == 1.0) {
                        p.setClassificacao(Classificacao.SETOSA);
                    } else if (atributos[indice][4] == 2.0) {
                        p.setClassificacao(Classificacao.VERSICOLOR);
                    } else if (atributos[indice][4] == 3.0) {
                        p.setClassificacao(Classificacao.VIRGINICA);
                    }

                    treinamento.add(p);
                    i++;
                }
            }

            System.out.println("Treinamento sendo classificado pelo Perceptron");

            perceptron.setTreinamento(treinamento);
            perceptron.inicializaPesos();
            perceptron.treinar();

            System.out.println("Escolhendo Aleatoriamente as iris para Teste");

            linha = 0;
            for (indice = 0; indice < 150; indice++) {
                adicionar = true;
                for (i = 0; i < 120; i++) {
                    if (irisEscolhidas[i] == indice) {
                        adicionar = false;
                        break;
                    }
                }
                if (adicionar) {
                    testesEscolhidos[linha] = indice;
                    Padrao p = new Padrao(
                            atributos[indice][0],
                            atributos[indice][1],
                            atributos[indice][2],
                            atributos[indice][3],
                            Classificacao.SETOSA);
                    teste.add(p);
                    linha++;
                }
            }

            System.out.println("Classificando as iris de Testes");

            for (indice = 0; indice < teste.tamanho(); indice++) {
                Padrao p = teste.getPadrao(indice);
                p.setClassificacao(perceptron.classifica(teste, indice));

            }

            System.out.println("Calculando Percentual de acertos");

            acertos = 0.0;
            for (int j = 0; j < teste.tamanho(); j++) {
                Padrao p = teste.getPadrao(j);
                double classe = 0.0;
                indice = testesEscolhidos[j];

                if (p.getClassificacao() == Classificacao.SETOSA) {
                    classe = 1.0;
                } else if (p.getClassificacao() == Classificacao.VERSICOLOR) {
                    classe = 2.0;
                } else if (p.getClassificacao() == Classificacao.VIRGINICA) {
                    classe = 3.0;
                }

                if (classe == atributos[indice][4]) {
                    acertos += 1.0;
                }
            }

            percentual[cont] = (double) (acertos / teste.tamanho()) * 100.00;
            media += percentual[cont];
            cont++;
        }

        System.out.println("\n___________________________________________________\n");
        System.out.println("Resultado da Estatistica: \n");

        for (indice = 0; indice < quantidade; indice++) {
            System.out.println("Percentual " + (indice + 1)
                    + " = " + percentual[indice] + "%");
        }

        media = media / quantidade;

        System.out.println("Media = " + media + "%");

        desvioPadrao = 0.0;
        for (indice = 0; indice < quantidade; indice++) {
            desvioPadrao += Math.pow((percentual[indice] - media), 2);
        }
        desvioPadrao = desvioPadrao / (quantidade - 1.0);
        desvioPadrao = Math.sqrt(desvioPadrao);
        System.out.println("Desvio Padrao = " + desvioPadrao);
        System.out.println("\n________________________________________________\n");
    }
}
