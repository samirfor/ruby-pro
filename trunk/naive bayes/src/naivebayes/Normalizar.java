/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package naivebayes;

import java.util.ArrayList;

/**
 *
 * @author jonas
 */
public class Normalizar {

    private ArrayList<PadraoIris> padroes = new ArrayList<PadraoIris>();

    public Normalizar(double iris[][]) {

        for (int i = 0; i < iris.length; i++) {

            Classificacao classe = null;
            if (iris[i][4] == 1.0) {
                classe = classe.SETOSA;

            } else if (iris[i][4] == 2.0) {

                classe = classe.VERSICOLOR;
            } else if (iris[i][4] == 3.0) {

                classe = classe.VIRGINICA;
            }
            padroes.add(new PadraoIris(iris[i][0], iris[i][1], iris[i][2], iris[i][3], classe));
        }
    }

    public void normalizaTamanhoPetala() {
        double maxValor = padroes.get(0).getTamanho_petala();
        double minValor = padroes.get(0).getTamanho_petala();
        // ArrayList<Double> tamanhoPetala = new ArrayList<Double>();
        double valorNormalizado;


        for (int i = 1; i < padroes.size(); i++) {
            if (maxValor < padroes.get(i).getTamanho_petala()) {
                maxValor = padroes.get(i).getTamanho_petala();
            }
            if (minValor > padroes.get(i).getTamanho_petala()) {
                minValor = padroes.get(i).getTamanho_petala();
            }
        }
        

        // System.out.println("max valor : "+maxValor+"|  min valor : "+minValor);
        for (int k = 0; k < padroes.size(); k++) {
            valorNormalizado = (padroes.get(k).getTamanho_petala() - minValor) / (maxValor - minValor);
            padroes.get(k).setTamanho_petala(valorNormalizado);
        }
    }

    public void normalizaLarguraPetala() {
        double maxValor = padroes.get(0).getLargura_petala();
        double minValor = padroes.get(0).getLargura_petala();
        // ArrayList<Double> tamanhoPetala = new ArrayList<Double>();
        double valorNormalizado;


        for (int i = 1; i < padroes.size(); i++) {
            if (maxValor < padroes.get(i).getLargura_petala()) {
                maxValor = padroes.get(i).getLargura_petala();
            }
        }
        for (int j = 1; j < padroes.size(); j++) {
            if (minValor > padroes.get(j).getLargura_petala()) {
                minValor = padroes.get(j).getLargura_petala();
            }

        }

        // System.out.println("max valor : "+maxValor+"|  min valor : "+minValor);
        for (int k = 0; k < padroes.size(); k++) {
            valorNormalizado = (padroes.get(k).getLargura_petala() - minValor) / (maxValor - minValor);
            padroes.get(k).setLargura_petala(valorNormalizado);
        }

    }
     public void normalizaTamanhoSepala() {
        double maxValor = padroes.get(0).getTamanho_sepala();
        double minValor = padroes.get(0).getTamanho_sepala();
        // ArrayList<Double> tamanhoPetala = new ArrayList<Double>();
        double valorNormalizado;


        for (int i = 1; i < padroes.size(); i++) {
            if (maxValor < padroes.get(i).getTamanho_sepala()) {
                maxValor = padroes.get(i).getTamanho_sepala();
            }
        }
        for (int j = 1; j < padroes.size(); j++) {
            if (minValor > padroes.get(j).getTamanho_sepala()) {
                minValor = padroes.get(j).getTamanho_sepala();
            }

        }

        // System.out.println("max valor : "+maxValor+"|  min valor : "+minValor);
        for (int k = 0; k < padroes.size(); k++) {
            valorNormalizado = (padroes.get(k).getTamanho_sepala() - minValor) / (maxValor - minValor);
            padroes.get(k).setTamanho_sepala(valorNormalizado);
        }

    }
     public void normalizaLarguraSepala() {
        double maxValor = padroes.get(0).getLargura_sepala();
        double minValor = padroes.get(0).getLargura_sepala();
        // ArrayList<Double> tamanhoPetala = new ArrayList<Double>();
        double valorNormalizado;


        for (int i = 1; i < padroes.size(); i++) {
            if (maxValor < padroes.get(i).getLargura_sepala()){
                maxValor = padroes.get(i).getLargura_sepala();
            }
        }
        for (int j = 1; j < padroes.size(); j++) {
            if (minValor > padroes.get(j).getLargura_sepala()) {
                minValor = padroes.get(j).getLargura_sepala();
            }

        }

        // System.out.println("max valor : "+maxValor+"|  min valor : "+minValor);
        for (int k = 0; k < padroes.size(); k++) {
            valorNormalizado = (padroes.get(k).getLargura_sepala() - minValor) / (maxValor - minValor);
            padroes.get(k).setLargura_sepala(valorNormalizado);
        }

    }
     public double[][] getDadosNormalizados(){
        double [][] iris = new double[150][5];

         normalizaLarguraPetala();
         normalizaLarguraSepala();
         normalizaTamanhoPetala();
         normalizaTamanhoSepala();

         for (int i = 0; i < 150; i++) {
             iris [i][0]= padroes.get(i).getTamanho_sepala();
             iris [i][1]= padroes.get(i).getLargura_sepala();
             iris [i][2]= padroes.get(i).getTamanho_petala();
             iris [i][3]= padroes.get(i).getLargura_petala();
             if(padroes.get(i).getClasse() == Classificacao.SETOSA){
                iris [i][4] = 1.0;
             }else if(padroes.get(i).getClasse() == Classificacao.VERSICOLOR){
                 iris [i][4]=2.0;
             }else{
                 iris [i][4]=3.0;
             }

         }

         return iris;
     }
}


