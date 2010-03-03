package perceptron;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * Lista de padrões usados na iris.
 * @author Samir Coutinho Costa <samirfor@gmail.com>
 */
public class BancoDados {

    private List<Padrao> padroes;

    public BancoDados() {
        padroes = new ArrayList<Padrao>();
    }

    public Padrao getPadrao(int index) {
        return padroes.get(index);
    }

    public int tamanho() {
        return padroes.size();
    }

    public void clear() {
        padroes.clear();
    }

    public void setBancoDados(Padrao padrao, int indice) {
        padroes.set(indice, padrao);
    }

    public void add(Padrao padrao) {
        padroes.add(padrao);
    }

    public double getMaiorLarguraSepala() {
        Padrao p = padroes.get(0);
        double MaiorLarguraSepala = p.getLarguraSepala();

        for (int indice = 1; indice < padroes.size(); indice++) {
            p = padroes.get(indice);
            if (MaiorLarguraSepala < p.getLarguraSepala()) {
                MaiorLarguraSepala = p.getLarguraSepala();
            }
        }

        return MaiorLarguraSepala;
    }

    public double getMaiorComprimentoSepala() {
        Padrao p = padroes.get(0);
        double MaiorComprimentoSepala = p.getComprimentoSepala();

        for (int indice = 1; indice < padroes.size(); indice++) {
            p = padroes.get(indice);
            if (MaiorComprimentoSepala < p.getComprimentoSepala()) {
                MaiorComprimentoSepala = p.getComprimentoSepala();
            }
        }

        return MaiorComprimentoSepala;
    }

    public double getMaiorComprimentoPetala() {
        Padrao p = padroes.get(0);
        double MaiorComprimentoPetala = p.getComprimentoPetala();

        for (int indice = 1; indice < padroes.size(); indice++) {
            p = padroes.get(indice);
            if (MaiorComprimentoPetala < p.getComprimentoPetala()) {
                MaiorComprimentoPetala = p.getComprimentoPetala();
            }
        }

        return MaiorComprimentoPetala;
    }

    public double getMaiorLarguraPetala() {
        Padrao p = padroes.get(0);
        double MaiorLarguraPetala = p.getLarguraPetala();

        for (int indice = 1; indice < padroes.size(); indice++) {
            p = padroes.get(indice);
            if (MaiorLarguraPetala < p.getLarguraPetala()) {
                MaiorLarguraPetala = p.getLarguraPetala();
            }
        }

        return MaiorLarguraPetala;
    }

    public double getMenorLarguraSepala() {
        Padrao p = padroes.get(0);
        double MenorLarguraSepala = p.getLarguraSepala();

        for (int indice = 1; indice < padroes.size(); indice++) {
            p = padroes.get(indice);
            if (MenorLarguraSepala > p.getLarguraSepala()) {
                MenorLarguraSepala = p.getLarguraSepala();
            }
        }

        return MenorLarguraSepala;
    }

    public double getMenorComprimentoSepala() {
        Padrao p = padroes.get(0);
        double MenorComprimentoSepala = p.getComprimentoSepala();

        for (int indice = 1; indice < padroes.size(); indice++) {
            p = padroes.get(indice);
            if (MenorComprimentoSepala > p.getComprimentoSepala()) {
                MenorComprimentoSepala = p.getComprimentoSepala();
            }
        }

        return MenorComprimentoSepala;
    }

    public double getMenorComprimentoPetala() {
        Padrao p = padroes.get(0);
        double MenorComprimentoPetala = p.getComprimentoPetala();

        for (int indice = 1; indice < padroes.size(); indice++) {
            p = padroes.get(indice);
            if (MenorComprimentoPetala > p.getComprimentoPetala()) {
                MenorComprimentoPetala = p.getComprimentoPetala();
            }
        }

        return MenorComprimentoPetala;
    }

    public double getMenorLarguraPetala() {
        Padrao p = padroes.get(0);
        double MenorLarguraPetala = p.getLarguraPetala();

        for (int indice = 1; indice < padroes.size(); indice++) {
            p = padroes.get(indice);
            if (MenorLarguraPetala > p.getLarguraPetala()) {
                MenorLarguraPetala = p.getLarguraPetala();
            }
        }

        return MenorLarguraPetala;
    }

    public void shuffle() {
        Collections.shuffle(padroes);
    }
}
