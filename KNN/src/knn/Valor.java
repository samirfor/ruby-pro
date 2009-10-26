package knn;

/**
 *
 * @author Samir Coutinho Costa <samirfor@gmail.com>
 */
public class Valor implements Comparable {

    private Double valor;
    private Classificacao tipo;

    public Valor(double valor, Classificacao tipo) {
        this.valor = valor;
        this.tipo = tipo;
    }

    public Classificacao getTipo() {
        return tipo;
    }

    public void setTipo(Classificacao tipo) {
        this.tipo = tipo;
    }

    public double getValor() {
        return valor;
    }

    public void setValor(double valor) {
        this.valor = valor;
    }

    public int compareTo(Object o) {
        Valor v = (Valor) o;
        return valor.compareTo(v.valor);
    }
}
