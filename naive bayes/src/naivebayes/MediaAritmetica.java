/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package naivebayes;

import java.util.ArrayList;

/**
 *
 * @author JonasRodrigues
 */
public class MediaAritmetica {

    ArrayList<PadraoIris> array;

    public MediaAritmetica(ArrayList<PadraoIris> array) {
        this.array = array;
    }

    public double getMediaLarguraPetala(Classificacao classe) {
        double media = 0.0;
        int tamanho = 0;

        for (int i = 0; i < array.size(); i++) {
            if (classe == array.get(i).getClasse()) {
                media = media + array.get(i).getLargura_petala();
                tamanho++;
            }
        }
        if (tamanho == 0) {
            return 0;
        }
        return media / tamanho;

    }

    public double getMediaLarguraSepala(Classificacao classe) {
        double media = 0;
        int tamanho = 0;

        for (int i = 0; i < array.size(); i++) {
            if (classe == array.get(i).getClasse()) {
                media = media + array.get(i).getLargura_sepala();
                tamanho++;
            }
        }
        if (tamanho == 0) {
            return 0;
        }
        return media / tamanho;

    }

    public double getMediaTamanhoPetala(Classificacao classe) {
        double media = 0;
        int tamanho = 0;

        for (int i = 0; i < array.size(); i++) {
            if (classe == array.get(i).getClasse()) {
                media = media + array.get(i).getTamanho_petala();
                tamanho++;
            }
        }
        if (tamanho == 0) {
            return 0;
        }
        return media / tamanho;

    }

    public double getMediaTamanhoSepala(Classificacao classe) {
        double media = 0;
        int tamanho = 0;

        for (int i = 0; i < array.size(); i++) {
            if (classe == array.get(i).getClasse()) {
                media = media + array.get(i).getTamanho_sepala();
                tamanho++;
            }
        }
        if (tamanho == 0) {
            return 0;
        }
        return media / tamanho;

    }
}
