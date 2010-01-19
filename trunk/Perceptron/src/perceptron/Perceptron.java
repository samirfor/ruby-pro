package perceptron;

import java.text.DecimalFormat;
import java.text.NumberFormat;

public class Perceptron {

//    private BancoDados treinamento;
//
//    public Perceptron(BancoDados treinamento) {
//        this.treinamento = treinamento;
//    }
//    /**
//     * Faz a classificação de acordo com os atributos sorteados.
//     * @param comprimentoSepala
//     * @param larguraSepala
//     * @param comprimentoPetala
//     * @param larguraPetala
//     * @return
//     */
//    public Classificacao classificar(
//            double comprimentoSepala,
//            double larguraSepala,
//            double comprimentoPetala,
//            double larguraPetala) {
    int[][] padroes = {
        {0, 0, 0, 0},
        {0, 0, 0, 1},
        {0, 0, 1, 0},
        {0, 0, 1, 1},
        {0, 1, 0, 0},
        {0, 1, 0, 1},
        {0, 1, 1, 0},
        {0, 1, 1, 1},
        {1, 0, 0, 0},
        {1, 0, 0, 1}};
    int[][] saidasEnsinadas = {
        {0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
        {1, 0, 0, 0, 0, 0, 0, 0, 0, 0},
        {1, 1, 0, 0, 0, 0, 0, 0, 0, 0},
        {1, 1, 1, 0, 0, 0, 0, 0, 0, 0},
        {1, 1, 1, 1, 0, 0, 0, 0, 0, 0},
        {1, 1, 1, 1, 1, 0, 0, 0, 0, 0},
        {1, 1, 1, 1, 1, 1, 0, 0, 0, 0},
        {1, 1, 1, 1, 1, 1, 1, 0, 0, 0},
        {1, 1, 1, 1, 1, 1, 1, 1, 0, 0},
        {1, 1, 1, 1, 1, 1, 1, 1, 1, 0}};
    int numNeuroniosEntrada = padroes[0].length;
    int numNeuroniosSaida = saidasEnsinadas[0].length;
    int numPadroes = padroes.length;
    double[][] pesos;

    public Perceptron() {
        pesos = new double[numNeuroniosEntrada][numNeuroniosSaida];
    }

    public void calculoDelta() {
        boolean tudoCerto = false;
        boolean erro = false;
        double fatorDeAprendizagem = 0.2;
        while (!tudoCerto) {
            erro = false;
            for (int i = 0; i < numPadroes; i++) {

                int[] saida = setValoresSaida(i);
                for (int j = 0; j < numNeuroniosSaida; j++) {
                    if (saidasEnsinadas[i][j] != saida[j]) {
                        for (int k = 0; k < numNeuroniosEntrada; k++) {
                            pesos[k][j] = pesos[k][j] + fatorDeAprendizagem
                                    * padroes[i][k]
                                    * (saidasEnsinadas[i][j] - saida[j]);
                        }
                    }
                }
                for (int z = 0; z < saida.length; z++) {
                    if (saida[z] != saidasEnsinadas[i][z]) {
                        erro = true;
                    }
                }

            }
            if (!erro) {
                tudoCerto = true;
            }
        }
    }

    int[] setValoresSaida(int nPadrao) {
        double bias = 0.7;
        int[] resultado = new int[numNeuroniosSaida];
        int[] paraImprimir = padroes[nPadrao];
        for (int i = 0; i < paraImprimir.length; i++) {

            for (int j = 0; j < resultado.length; j++) {
                double rede = pesos[0][j] * paraImprimir[0] + pesos[1][j]
                        * paraImprimir[1] + pesos[2][j] * paraImprimir[2]
                        + pesos[3][j] * paraImprimir[3];
                if (rede > bias) {
                    resultado[j] = 1;
                } else {
                    resultado[j] = 0;
                }
            }

        }
        return resultado;
    }

    public void imprimeMatriz(double[][] matriz) {

        for (int i = 0; i < matriz.length; i++) {
            for (int j = 0; j < matriz[i].length; j++) {
                NumberFormat f = NumberFormat.getInstance();
                if (f instanceof DecimalFormat) {
                    DecimalFormat decimalFormat = ((DecimalFormat) f);
                    decimalFormat.setMaximumFractionDigits(1);
                    decimalFormat.setMinimumFractionDigits(1);
                    System.out.print("(" + f.format(matriz[i][j]) + ")");
                }
            }
            System.out.println();
        }

    }
}
