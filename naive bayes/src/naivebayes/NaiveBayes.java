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
public class NaiveBayes {

    private ArrayList<PadraoIris> treinamento;

    public NaiveBayes(ArrayList<PadraoIris> treinamento) {
        this.treinamento = treinamento;
    }

    public Classificacao classificar(double tamanhoSepala, double larguraSepala, double tamanhoPetala, double larguraPetala) {
        MediaAritmetica media = new MediaAritmetica(treinamento);
        DesvioPadrao desvioPadrao = new DesvioPadrao(treinamento);
        double mediaAritmetica = 0.0, variancia = 0.0, classeSetosa = 0.0, classeVersicolor = 0.0, classeVirginica = 0.0;
        double setosa[] = new double[4];
        double versicolor[] = new double[4];
        double virginica[] = new double[4];


        //probabilidade de ser versicolor
        mediaAritmetica = media.getMediaLarguraPetala(Classificacao.VERSICOLOR);
        variancia = Math.pow(desvioPadrao.getDesvioPadraoLarguraPetala(Classificacao.VERSICOLOR), 2);
        versicolor[0] = getDistribuicaoNormal(mediaAritmetica, variancia, larguraPetala);
        
        mediaAritmetica = media.getMediaTamanhoPetala(Classificacao.VERSICOLOR);
        variancia = Math.pow(desvioPadrao.getDesvioPadraoTamanhoPetala(Classificacao.VERSICOLOR), 2);
        versicolor[1] =getDistribuicaoNormal(mediaAritmetica, variancia, tamanhoPetala);
        

        mediaAritmetica = media.getMediaLarguraSepala(Classificacao.VERSICOLOR);
        variancia = Math.pow(desvioPadrao.getDesvioPadraoLarguraSepala(Classificacao.VERSICOLOR), 2);
        versicolor[2] = getDistribuicaoNormal(mediaAritmetica, variancia, larguraSepala);
        

        mediaAritmetica = media.getMediaTamanhoSepala(Classificacao.VERSICOLOR);
        variancia = Math.pow(desvioPadrao.getDesvioPadraoTamanhoSepala(Classificacao.VERSICOLOR), 2);
        versicolor[3] = getDistribuicaoNormal(mediaAritmetica, variancia, tamanhoSepala);
       

        classeVersicolor = versicolor[0] * versicolor[1] * versicolor[2] * versicolor[3];
       

        //probabilidade de ser setosa
        mediaAritmetica = media.getMediaLarguraPetala(Classificacao.SETOSA);
        variancia = Math.pow(desvioPadrao.getDesvioPadraoLarguraPetala(Classificacao.SETOSA), 2);
        setosa[0] = getDistribuicaoNormal(mediaAritmetica, variancia, larguraPetala);
        

        mediaAritmetica = media.getMediaTamanhoPetala(Classificacao.SETOSA);
        variancia = Math.pow(desvioPadrao.getDesvioPadraoTamanhoPetala(Classificacao.SETOSA), 2);
        setosa[1] =getDistribuicaoNormal(mediaAritmetica, variancia, tamanhoPetala);
        


        mediaAritmetica = media.getMediaLarguraSepala(Classificacao.SETOSA);
        variancia = Math.pow(desvioPadrao.getDesvioPadraoLarguraSepala(Classificacao.SETOSA), 2);
        setosa[2] = getDistribuicaoNormal(mediaAritmetica, variancia, larguraSepala);
        

        mediaAritmetica = media.getMediaTamanhoSepala(Classificacao.SETOSA);
        variancia = Math.pow(desvioPadrao.getDesvioPadraoTamanhoSepala(Classificacao.SETOSA), 2);
        setosa[3] = getDistribuicaoNormal(mediaAritmetica, variancia, tamanhoSepala);

        classeSetosa = setosa[0] * setosa[1] * setosa[2] * setosa[3];
    
        mediaAritmetica = media.getMediaLarguraPetala(Classificacao.VIRGINICA);
        variancia = Math.pow(desvioPadrao.getDesvioPadraoLarguraPetala(Classificacao.VIRGINICA), 2);
        virginica[0] = getDistribuicaoNormal(mediaAritmetica, variancia, larguraPetala);
       

        mediaAritmetica = media.getMediaTamanhoPetala(Classificacao.VIRGINICA);
        variancia = Math.pow(desvioPadrao.getDesvioPadraoTamanhoPetala(Classificacao.VIRGINICA), 2);
        virginica[1] = getDistribuicaoNormal(mediaAritmetica, variancia, tamanhoPetala);


        mediaAritmetica = media.getMediaLarguraSepala(Classificacao.VIRGINICA);
        variancia = Math.pow(desvioPadrao.getDesvioPadraoLarguraSepala(Classificacao.VIRGINICA), 2);
        virginica[2] = getDistribuicaoNormal(mediaAritmetica, variancia, larguraSepala);
        

        mediaAritmetica = media.getMediaTamanhoSepala(Classificacao.VIRGINICA);
        variancia = Math.pow(desvioPadrao.getDesvioPadraoTamanhoSepala(Classificacao.VIRGINICA), 2);
        virginica[3] = getDistribuicaoNormal(mediaAritmetica, variancia, tamanhoSepala);


        classeVirginica = virginica[0] * virginica[1] * virginica[2] * virginica[3];
      
        if ((classeVersicolor >= classeSetosa) && (classeVersicolor >= classeVirginica)) {
            // System.out.println("versicolor");
            return Classificacao.VERSICOLOR;
        } else if ((classeSetosa >= classeVersicolor) && (classeSetosa >= classeVirginica)) {
            //System.out.println("setosa");
            return Classificacao.SETOSA;
        } else {
            //System.out.println("virginica");
            return Classificacao.VIRGINICA;
        }


    }

    public double getDistribuicaoNormal(double media, double variancia, double atributo) {
        double value;
        double neperiano = 2.718281828459045;
        double pi = 3.141592653589793;

       value= Math.exp(-(atributo-media)*(atributo-media)/(2*variancia)) / Math.sqrt(2 * pi * variancia);

        return value;
    }
}

