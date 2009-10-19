package dmc;

/**
 * Implementação do algoritmo DMC (Dynamic Matrix Control).
 * @author samir
 */
public class DMC {

    private BancoDados treinamento;

    /**
     * @param treinamento
     */
    public DMC(BancoDados treinamento) {
        this.treinamento = treinamento;
    }

    /**
     * Calcula o sentróide de setosas.
     * @return
     */
    public double getCentroideSetosa() {
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
     * Calcula o centróide de versicolor.
     * @return
     */
    public double getCentroideVersicolor() {
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
     * Calcula o centróide de virgínica.
     * @return
     */
    public double getCentroideVirginica() {
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

        setosa = (Math.pow(comprimentoSepala - getCentroideSetosa(), 2) +
                Math.pow(larguraSepala - getCentroideSetosa(), 2) +
                Math.pow(comprimentoPetala - getCentroideSetosa(), 2) +
                Math.pow(larguraPetala - getCentroideSetosa(), 2));
        setosa = Math.sqrt(setosa);

        versicolor = (Math.pow(comprimentoSepala - getCentroideVersicolor(), 2) +
                Math.pow(larguraSepala - getCentroideVersicolor(), 2) +
                Math.pow(comprimentoPetala - getCentroideVersicolor(), 2) +
                Math.pow(larguraPetala - getCentroideVersicolor(), 2));
        versicolor = Math.sqrt(versicolor);

        virginica = (Math.pow(comprimentoSepala - getCentroideVirginica(), 2) +
                Math.pow(larguraSepala - getCentroideVirginica(), 2) +
                Math.pow(comprimentoPetala - getCentroideVirginica(), 2) +
                Math.pow(larguraPetala - getCentroideVirginica(), 2));
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
