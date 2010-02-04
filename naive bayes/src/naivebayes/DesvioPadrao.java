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
public class DesvioPadrao {

    private ArrayList<PadraoIris> array;

    public DesvioPadrao(ArrayList<PadraoIris> array) {
        this.array = array;
    }

    public double getDesvioPadraoLarguraPetala(Classificacao classe) {
        double desvioPadrao = 0;
        int tamanho = 0;
        MediaAritmetica value = new MediaAritmetica(array);
        double media = value.getMediaLarguraPetala(classe);

        for (int i = 0; i < array.size(); i++) {
            if (classe == array.get(i).getClasse()) {
                desvioPadrao = desvioPadrao + Math.pow(array.get(i).getLargura_petala() - media, 2);
                tamanho++;
            }
        }
        if (tamanho == 0){
            return 0;
        }
        return Math.sqrt(desvioPadrao / tamanho);

    }

    public double getDesvioPadraoLarguraSepala(Classificacao classe) {
        double desvioPadrao = 0;
        int tamanho = 0;
        MediaAritmetica value = new MediaAritmetica(array);
        double media = value.getMediaLarguraSepala(classe);

        for (int i = 0; i < array.size(); i++) {
            if (classe == array.get(i).getClasse()) {
                desvioPadrao = desvioPadrao + Math.pow(array.get(i).getLargura_sepala() - media, 2);
                tamanho++;
            }
        }
        if (tamanho == 0){
            return 0;
        }
        return Math.sqrt(desvioPadrao / tamanho);

    }

    public double getDesvioPadraoTamanhoPetala(Classificacao classe) {
        double desvioPadrao = 0;
        int tamanho = 0;
        MediaAritmetica value = new MediaAritmetica(array);
        double media = value.getMediaTamanhoPetala(classe);

        for (int i = 0; i < array.size(); i++) {
            if (classe == array.get(i).getClasse()) {
                desvioPadrao = desvioPadrao + Math.pow(array.get(i).getTamanho_petala() - media, 2);
                tamanho++;
            }
        }
        if (tamanho == 0){
            return 0;
        }
        return Math.sqrt(desvioPadrao / tamanho);
    }

    public double getDesvioPadraoTamanhoSepala(Classificacao classe) {
        double desvioPadrao = 0;
        int tamanho = 0;
        MediaAritmetica value = new MediaAritmetica(array);
        double media = value.getMediaTamanhoSepala(classe);

        for (int i = 0; i < array.size(); i++) {
            if (classe == array.get(i).getClasse()) {
                desvioPadrao = desvioPadrao + Math.pow(array.get(i).getTamanho_sepala() - media, 2);
                tamanho++;
            }
        }
        if (tamanho == 0){
            return 0;
        }
         //System.out.println("DESVIO  "+ desvioPadrao);
         //System.out.println("TAMANHO DA SEPALA  DESVIO : "+media);
        return Math.sqrt(desvioPadrao / tamanho);


    }
}
