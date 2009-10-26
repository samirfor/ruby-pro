package knn;

import java.util.Collections;
import java.util.List;

/**
 *
 * @author Samir Coutinho Costa <samirfor@gmail.com>
 */
public class Lista {

    private List<Valor> valor;

    public Lista() {
    }

    public Lista(List<Valor> valor) {
        this.valor = valor;
    }

    public List<Valor> getValor() {
        return valor;
    }

    public void setValor(List<Valor> valor) {
        this.valor = valor;
    }

    public int size() {
        return valor.size();
    }

    public void add(Valor v) {
        valor.add(v);
    }

    public void ordenar() {
        Collections.sort(valor);
    }
}
