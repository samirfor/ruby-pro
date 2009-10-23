
/**
 *
 * @author Samir Coutinho Costa <samirfor@gmail.com>
 */
public class KnnValor {

    private double valor, valorEscalar;
    private String id;

    /**
     * Cria uma instância de um valor sem string de identificação.
     * @param valor
     */
    public KnnValor(double valor) {
        this.valor = valor;
        this.id = null;
    }

    /**
     * Cria uma instância de um valor com string de identificação.
     * @param valor
     * @param id
     */
    public KnnValor(double valor, String id) {
        this.valor = valor;
        this.id = id;
    }

    /**
     * Retorna um valor numérico de {@link KnnValor}.
     * @return valor
     */
    public double getIndex() {
        return getIndex(false);
    }

    /**
     * Retorna o valor escalar de {@link KnnValor}.
     * @param se valor escalar ou não
     * @return valor
     */
    public double getIndex(boolean scaled) {
        if (scaled) {
            return valorEscalar;
        }
        return valor;
    }

    /**
     * Retorna a string de identificação de {@link KnnValor}.
     * @return String de identificação
     */
    public String getID() {
        return id;
    }

    /**
     * Calcula o valor escalar do valor original usando significado
     * e sigma do data set.
     * @param mean Mean valor of the data set.
     * @param sigma Sigma valor of the data set (from the standard deviation).
     */
    public void calcularEscalar(double media, double classe) {
        valorEscalar = (valor - media) / classe;
    }

    /**
     * Retorna se o valor está reservado ou não.
     * Identificador <em>DESCONHECIDO</em> (-1).
     * @return Se este valor é desconhecido ou não.
     */
    public boolean isDesconhecido() {
        return valor < 0;
    }

    /**
     * Retorna uma string representando {@link KnnValor}.
     */
    @Override
    public String toString() {
        return id;
    }
}
