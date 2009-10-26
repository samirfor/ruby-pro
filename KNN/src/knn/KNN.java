package knn;

/**
 * Implementação do algoritmo KNN (K-Nearest Neighbors Algorithm).
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
     * Faz a classificação de acordo com os atributos sorteados.
     * @param comprimentoSepala
     * @param larguraSepala
     * @param comprimentoPetala
     * @param larguraPetala
     * @return
     */
    public Classificacao classificar(double comprimentoSepala, double larguraSepala, double comprimentoPetala, double larguraPetala) {
        double distancia = 0;
        int setosa = 0, versicolor = 0, virginica = 0;
        Lista lista = new Lista();

        for (int i = 0; i < treinamento.size(); i++) {
            Padrao padrao = treinamento.getPadrao(i);
            distancia = Math.pow(comprimentoSepala - padrao.getComprimentoPetala(), 2) +
                    Math.pow(larguraSepala - padrao.getLarguraSepala(), 2) +
                    Math.pow(comprimentoPetala - padrao.getComprimentoPetala(), 2) +
                    Math.pow(larguraPetala - padrao.getLarguraPetala(), 2);
            distancia = Math.sqrt(distancia);
            Valor valor = new Valor(distancia, padrao.getTipo());
            lista.add(valor);
        }

        System.out.println("\tDistância: " + distancia);

        return
    }
}
