package knn;

/**
 * Implementação do algoritmo KNN (K-nearest Neighbors Algorithm).
 * @author Samir Coutinho Costa <samirfor@gmail.com>
 */
public class KNN {

    private BancoDados treinamento;

    /**
     * @param treinamento
     */
    public KNN(BancoDados treinamento) {
        this.treinamento = treinamento;
    }

    /**
     * Calcula a distância para setosa.
     * @return
     */
    public double getDistanciaSetosa() {
        double soma = 0;
        int count = 0;

        for (int i = 0; i < treinamento.size(); i++) {
            Padrao padrao = treinamento.getPadrao(i);
            if (padrao.getTipo() == Classificacao.SETOSA) {
                soma += (padrao.getComprimentoSepala() +
                        padrao.getLarguraSepala() +
                        padrao.getComprimentoPetala() +
                        padrao.getLarguraPetala()) / 4.0;
                count++;
            }
        }

        // Manipula o 0/0
        if (count != 0) {
            return soma / count;
        } else {
            return 0;
        }
    }

    /**
     * Calcula a distância para versicolor.
     * @return
     */
    public double getDistanciaVersicolor() {
        double soma = 0;
        int count = 0;

        for (int i = 0; i < treinamento.size(); i++) {
            Padrao padrao = treinamento.getPadrao(i);
            if (padrao.getTipo() == Classificacao.VERSICOLOR) {
                soma += (padrao.getComprimentoSepala() +
                        padrao.getLarguraSepala() +
                        padrao.getComprimentoPetala() +
                        padrao.getLarguraPetala()) / 4.0;
                count++;
            }
        }

        // Manipula o 0/0
        if (count != 0) {
            return soma / count;
        } else {
            return 0;
        }
    }

    /**
     * Calcula a distância para virgínica.
     * @return
     */
    public double getDistanciaVirginica() {
        double soma = 0;
        int count = 0;

        for (int i = 0; i < treinamento.size(); i++) {
            Padrao padrao = treinamento.getPadrao(i);
            if (padrao.getTipo() == Classificacao.VIRGINICA) {
                soma += (padrao.getComprimentoSepala() +
                        padrao.getLarguraSepala() +
                        padrao.getComprimentoPetala() +
                        padrao.getLarguraPetala()) / 4.0;
                count++;
            }
        }

        // Manipula o 0/0
        if (count != 0) {
            return soma / count;
        } else {
            return 0;
        }
    }

    /**
     * Faz a classificação de acordo com os atributos sorteados.
     * @param comprimentoSepala
     * @param larguraSepala
     * @param comprimentoPetala
     * @param larguraPetala
     * @return
     */
    public Classificacao classificar(double comprimentoSepala, double larguraSepala, double comprimentoPetala, double larguraPetala) {
        double setosa = 0.0, versicolor = 0.0, virginica = 0.0;

        setosa = (Math.pow(comprimentoSepala - getDistanciaSetosa(), 2) +
                Math.pow(larguraSepala - getDistanciaSetosa(), 2) +
                Math.pow(comprimentoPetala - getDistanciaSetosa(), 2) +
                Math.pow(larguraPetala - getDistanciaSetosa(), 2));
        setosa = Math.sqrt(setosa);

        versicolor = (Math.pow(comprimentoSepala - getDistanciaVersicolor(), 2) +
                Math.pow(larguraSepala - getDistanciaVersicolor(), 2) +
                Math.pow(comprimentoPetala - getDistanciaVersicolor(), 2) +
                Math.pow(larguraPetala - getDistanciaVersicolor(), 2));
        versicolor = Math.sqrt(versicolor);

        virginica = (Math.pow(comprimentoSepala - getDistanciaVirginica(), 2) +
                Math.pow(larguraSepala - getDistanciaVirginica(), 2) +
                Math.pow(comprimentoPetala - getDistanciaVirginica(), 2) +
                Math.pow(larguraPetala - getDistanciaVirginica(), 2));
        virginica = Math.sqrt(virginica);

        System.out.println("\tDistância:");
        System.out.println("\t\tSetosa = " + setosa);
        System.out.println("\t\tVersicolor = " + versicolor);
        System.out.println("\t\tVirginica = " + virginica);

        if (setosa <= versicolor && setosa <= virginica) {
            return Classificacao.SETOSA;
        } else if (versicolor <= setosa && versicolor <= virginica) {
            return Classificacao.VERSICOLOR;
        } else { // if (virginica <= setosa && virginica <= versicolor) {
            return Classificacao.VIRGINICA;
        }
    }
}
