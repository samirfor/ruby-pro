package dmc;

import java.util.ArrayList;

public class BancoDados {

    private ArrayList<Padrao> padroes;

    public BancoDados() {
        padroes = new ArrayList<Padrao>();
    }

    public Padrao getPadrao(int index) {
        return padroes.get(index);
    }

    public int size() {
        return padroes.size();
    }

    public void add(Padrao padrao) {
        padroes.add(padrao);
    }
}
