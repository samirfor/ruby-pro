package knn;

/**
 * Contém a distância e o tipo de íris para cada padrão do sorteio.
 * @author Samir Coutinho Costa <samirfor@gmail.com>
 */
public class Valor implements Comparable {

    private Double distancia;
    private Classificacao tipo;

    public Valor() {
    }

    public Valor(double distancia, Classificacao tipo) {
        this.distancia = distancia;
        this.tipo = tipo;
    }

    public Classificacao getTipo() {
        return tipo;
    }

    public void setTipo(Classificacao tipo) {
        this.tipo = tipo;
    }

    public double getDistancia() {
        return distancia;
    }

    public void setDistancia(double distancia) {
        this.distancia = distancia;
    }

    public int compareTo(Object o) {
        throw new UnsupportedOperationException("Não implementado ainda.");
    }

    @Override
    public String toString() {
        return distancia.toString();
    }
}
