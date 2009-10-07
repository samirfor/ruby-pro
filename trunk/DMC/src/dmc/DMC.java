package dmc;

public class DMC {

    private BancoDados treinamento;

    public DMC(BancoDados treinamento) {
        this.treinamento = treinamento;
    }

    /**
     * Calcula o sentróide de setosas.
     * @return
     */
    public double getCentroideSetosa() {
        double soma = 0.00;
        int count = 0;

        for (int i = 0; i < treinamento.size(); i++, count++) {
            Padrao padrao = treinamento.getPadrao(i);
            if (padrao.getClasse() == Classificacao.SETOSA) {
                soma += (padrao.getComprimentoSepala() +
                        padrao.getLarguraSepala() +
                        padrao.getComprimentoPetala() +
                        padrao.getLarguraPetala()) / 4.0;
            }
        }

        // Evita o bug do 0/0
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
        double soma = 0.00;
        int count = 0;

        for (int i = 0; i < treinamento.size(); i++, count++) {
            Padrao padrao = treinamento.getPadrao(i);
            if (padrao.getClasse() == Classificacao.VERSICOLOR) {
                soma += (padrao.getComprimentoSepala() +
                        padrao.getLarguraSepala() +
                        padrao.getComprimentoPetala() +
                        padrao.getLarguraPetala()) / 4.0;
            }
        }

        // Evita o bug do 0/0
        if (count != 0) {
            return soma / count;
        } else {
            return 0;
        }
    }

    /**
     * Caclula o centróide de virgínica.
     * @return
     */
    public double getCentroideVirginica() {
        double soma = 0.00;
        int count = 0;

        for (int i = 0; i < treinamento.size(); i++, count++) {
            Padrao padrao = treinamento.getPadrao(i);
            if (padrao.getClasse() == Classificacao.VIRGINICA) {
                soma += (padrao.getComprimentoSepala() +
                        padrao.getLarguraSepala() +
                        padrao.getComprimentoPetala() +
                        padrao.getLarguraPetala()) / 4.0;
            }
        }

        // Evita o bug do 0/0
        if (count != 0) {
            return soma / count;
        } else {
            return 0;
        }
    }

    /**
     * Faz a classificação de acordo com os atributos sorteados.
     * @param comprimento_sepala
     * @param largura_sepala
     * @param comprimento_petala
     * @param largura_petala
     * @return
     */
    public Classificacao classificar(double comprimento_sepala, double largura_sepala, double comprimento_petala, double largura_petala) {
        double setosa = 0.0, versicolor = 0.0, virginica = 0.0;

        setosa = (Math.pow(comprimento_sepala - getCentroideSetosa(), 2) +
                Math.pow(largura_sepala - getCentroideSetosa(), 2) +
                Math.pow(comprimento_petala - getCentroideSetosa(), 2) +
                Math.pow(largura_petala - getCentroideSetosa(), 2));
        setosa = Math.sqrt(setosa);

        versicolor = (Math.pow(comprimento_sepala - getCentroideVersicolor(), 2) +
                Math.pow(largura_sepala - getCentroideVersicolor(), 2) +
                Math.pow(comprimento_petala - getCentroideVersicolor(), 2) +
                Math.pow(largura_petala - getCentroideVersicolor(), 2));
        versicolor = Math.sqrt(versicolor);

        virginica = (Math.pow(comprimento_sepala - getCentroideVirginica(), 2) +
                Math.pow(largura_sepala - getCentroideVirginica(), 2) +
                Math.pow(comprimento_petala - getCentroideVirginica(), 2) +
                Math.pow(largura_petala - getCentroideVirginica(), 2));
        virginica = Math.sqrt(virginica);

        System.out.println("\nCálculos de classificação:");
        System.out.println("setosa = " + setosa);
        System.out.println("versicolor = " + versicolor);
        System.out.println("virginica = " + virginica);

        if (setosa <= versicolor && setosa <= virginica) {
            return Classificacao.SETOSA;
        } else {
            if (versicolor <= setosa && versicolor <= virginica) {
                return Classificacao.VERSICOLOR;
            } else {
                return Classificacao.VIRGINICA;
            }
        }
    }
}
