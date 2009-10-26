
import knn.Classificacao;
import knn.Lista;
import knn.Valor;

/**
 *
 * @author multi
 */
public class Sort {

    public static void main(String[] args) {
        Lista l = new Lista();
        Valor v;
        double[] array = new double[6];

        array[0] = 3.444;
        array[1] = 1.444;
        array[2] = 56.444;
        array[3] = 32.444;
        array[4] = 0.444;
        array[5] = 0.442;

        for (int i = 0; i < array.length; i++) {
            v = new Valor(array[i], Classificacao.SETOSA);
            l.add(v);
        }

        System.out.println("Antes:\n" + l);
        l.ordenar();
        System.out.println("Depois:\n" + l);
    }
}
