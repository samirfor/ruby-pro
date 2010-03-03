package perceptron;

public class Perceptron {

    private BancoDados treinamento;//guarda os dados das iris para treinamento
    private double[] pesosSetosa;
    private double[] pesosVersicolor;
    private double[] pesosVirginica;
    private double taxaDeAprendizagem;

    public Perceptron() {
        this.treinamento = null;
        this.pesosSetosa = new double[5];
        this.pesosVersicolor = new double[5];
        this.pesosVirginica = new double[5];
        this.taxaDeAprendizagem = 0.3;
    }

    public void inicializaPesos() {
        for (int indice = 0; indice < 5; indice++) {
            pesosSetosa[indice] = (Math.random() * 4) / 10 - 0.2;
            pesosVersicolor[indice] = (Math.random() * 4) / 10 - 0.2;
            pesosVirginica[indice] = (Math.random() * 4) / 10 - 0.2;
        }
    }

    public void setTreinamento(BancoDados treinamento) {
        this.treinamento = treinamento;
    }

    public void treinar() {
        double[] erro = new double[3];
        int[] saidaDesejada = new int[3];
        int[] saida = new int[3];
        double ativacao;
        int Epoca = 500;
        double constante = (taxaDeAprendizagem - 0.1) / Epoca;
        int indice, epoca = 1;
        System.out.println("Treinando neuronios Perceptron");


        while (epoca <= Epoca) {
            indice = 0;
            while (indice < treinamento.tamanho()) {

                ativacao = 0;
                erro[0] = 0;
                erro[1] = 0;
                erro[2] = 0;

                System.out.println("Normalizando Treinamento");

                Padrao p = normalizaDados(treinamento, indice);

                if (p.getClassificacao() == Classificacao.SETOSA) {
                    saidaDesejada[0] = 1;
                    saidaDesejada[1] = 0;
                    saidaDesejada[2] = 0;
                } else if (p.getClassificacao() == Classificacao.VERSICOLOR) {
                    saidaDesejada[0] = 0;
                    saidaDesejada[1] = 1;
                    saidaDesejada[2] = 0;
                } else if (p.getClassificacao() == Classificacao.VIRGINICA) {
                    saidaDesejada[0] = 0;
                    saidaDesejada[1] = 0;
                    saidaDesejada[2] = 1;
                }



                System.out.println("Calculando Saidas e comparando com saidas desejadas");

                saida[0] = neuronioSetosa(p);
                saida[1] = neuronioVersicolor(p);
                saida[2] = neuronioVirginica(p);

                if (saida[0] != saidaDesejada[0]) {

                    System.out.println("Ajustando os Pesos Setosa");

                    erro[0] = saidaDesejada[0] - saida[0];
                    pesosSetosa[0] += 1 * taxaDeAprendizagem * erro[0];
                    pesosSetosa[1] += p.getComprimentoSepala()
                            * taxaDeAprendizagem * erro[0];
                    pesosSetosa[2] += p.getLarguraSepala()
                            * taxaDeAprendizagem * erro[0];
                    pesosSetosa[3] += p.getComprimentoPetala()
                            * taxaDeAprendizagem * erro[0];
                    pesosSetosa[4] += p.getLarguraPetala()
                            * taxaDeAprendizagem * erro[0];
                }

                if (saida[1] != saidaDesejada[1]) {

                    System.out.println("Ajustando  os Pesos Versicolor");

                    erro[1] = saidaDesejada[1] - saida[1];
                    pesosVersicolor[0] += 1 * taxaDeAprendizagem * erro[1];
                    pesosVersicolor[1] += p.getComprimentoSepala()
                            * taxaDeAprendizagem * erro[1];
                    pesosVersicolor[2] += p.getLarguraSepala()
                            * taxaDeAprendizagem * erro[1];
                    pesosVersicolor[3] += p.getComprimentoPetala()
                            * taxaDeAprendizagem * erro[1];
                    pesosVersicolor[4] += p.getLarguraPetala()
                            * taxaDeAprendizagem * erro[1];
                }

                if (saida[2] != saidaDesejada[2]) {

                    System.out.println("Ajustando  os Pesos Virginica");

                    erro[2] = saidaDesejada[2] - saida[2];
                    pesosVirginica[0] += 1 * taxaDeAprendizagem * erro[2];
                    pesosVirginica[1] += p.getComprimentoSepala()
                            * taxaDeAprendizagem * erro[2];
                    pesosVirginica[2] += p.getLarguraSepala()
                            * taxaDeAprendizagem * erro[2];
                    pesosVirginica[3] += p.getComprimentoPetala()
                            * taxaDeAprendizagem * erro[2];
                    pesosVirginica[4] += p.getLarguraPetala()
                            * taxaDeAprendizagem * erro[2];
                }

                if (erro[0] == 0 && erro[1] == 0 && erro[2] == 0) {
                    System.out.println("Classificou corretamente");
                    indice++;
                }

            }
            taxaDeAprendizagem -= constante;
            treinamento.shuffle();
            epoca++;
        }

    }

    private int neuronioSetosa(Padrao padrao) {
        double ativacao = 1 * pesosSetosa[0]
                + padrao.getComprimentoSepala() * pesosSetosa[1]
                + padrao.getLarguraSepala() * pesosSetosa[2]
                + padrao.getComprimentoPetala() * pesosSetosa[3]
                + padrao.getLarguraSepala() * pesosSetosa[4];
        int saida = funcaoAtivacao(ativacao);

        return saida;
    }

    private int neuronioVersicolor(Padrao padrao) {
        double ativacao = 1 * pesosVersicolor[0]
                + padrao.getComprimentoSepala() * pesosVersicolor[1]
                + padrao.getLarguraSepala() * pesosVersicolor[2]
                + padrao.getComprimentoPetala() * pesosVersicolor[3]
                + padrao.getLarguraSepala() * pesosVersicolor[4];
        int saida = funcaoAtivacao(ativacao);

        return saida;
    }

    private int neuronioVirginica(Padrao padrao) {
        double ativacao = 1 * pesosVirginica[0]
                + padrao.getComprimentoSepala() * pesosVirginica[1]
                + padrao.getLarguraSepala() * pesosVirginica[2]
                + padrao.getComprimentoPetala() * pesosVirginica[3]
                + padrao.getLarguraSepala() * pesosVirginica[4];
        int saida = funcaoAtivacao(ativacao);

        return saida;
    }

    private int funcaoAtivacao(double ativacao) {
        if (ativacao >= 0) {
            return 1;
        }

        //se ativacao < 0 retorna -1
        return 0;
    }

    private Padrao normalizaDados(BancoDados banco, int indice) {
        double MaiorComprimentoSepala = banco.getMaiorComprimentoSepala();
        double MaiorLarguraSepala = banco.getMaiorLarguraSepala();
        double MaiorComprimentoPetala = banco.getMaiorComprimentoPetala();
        double MaiorLarguraPetala = banco.getMaiorLarguraPetala();
        double MenorComprimentoSepala = banco.getMenorComprimentoSepala();
        double MenorLarguraSepala = banco.getMenorLarguraSepala();
        double MenorComprimentoPetala = banco.getMenorComprimentoPetala();
        double MenorLarguraPetala = banco.getMenorLarguraPetala();
        double comprimentoSepalaN;
        double larguraSepalaN;
        double comprimentoPetalaN;
        double larguraPetalaN;

        Padrao padraoN = new Padrao(1.0, 1.0, 1.0, 1.0, Classificacao.SETOSA);

        Padrao p = banco.getPadrao(indice);

        comprimentoPetalaN = (p.getComprimentoPetala() - MenorComprimentoPetala)
                / (MaiorComprimentoPetala - MenorComprimentoPetala);
        comprimentoSepalaN = (p.getComprimentoSepala() - MenorComprimentoSepala)
                / (MaiorComprimentoSepala - MenorComprimentoSepala);
        larguraPetalaN = (p.getLarguraPetala() - MenorLarguraPetala)
                / (MaiorLarguraPetala - MenorLarguraPetala);
        larguraSepalaN = (p.getLarguraSepala() - MenorLarguraSepala)
                / (MaiorLarguraSepala - MenorLarguraSepala);

        padraoN.setClassificacao(p.getClassificacao());
        padraoN.setComprimentoPetala(comprimentoPetalaN);
        padraoN.setComprimentoSepala(comprimentoSepalaN);
        padraoN.setLarguraPetala(larguraPetalaN);
        padraoN.setLarguraSepala(larguraSepalaN);

        return padraoN;
    }

    public Classificacao classifica(BancoDados banco, int indice) {

        Classificacao classificacao = null;
        int[] saida = new int[3];

        Padrao teste = normalizaDados(banco, indice);

        saida[0] = neuronioSetosa(teste);
        saida[1] = neuronioVersicolor(teste);
        saida[2] = neuronioVirginica(teste);

        if (saida[0] == 1) {
            classificacao = Classificacao.SETOSA;
        } else if (saida[1] == 1) {
            classificacao = Classificacao.VERSICOLOR;
        } else if (saida[2] == 1) {
            classificacao = Classificacao.VIRGINICA;
        }

        return classificacao;

    }
}
