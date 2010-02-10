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
        //System.out.println("ver larg petala/  media :"+mediaAritmetica+" variancia :"+variancia );
        //System.out.println("valor 1 :"+versicolor[0] );
        System.out.println("==== VERSICOLOR ====");
        System.out.println("MÉDIA LARGURA DA PETALA :" + mediaAritmetica);
        System.out.println("VARIANCIA :" + variancia);

        mediaAritmetica = media.getMediaTamanhoPetala(Classificacao.VERSICOLOR);
        variancia = Math.pow(desvioPadrao.getDesvioPadraoTamanhoPetala(Classificacao.VERSICOLOR), 2);
        versicolor[1] =getDistribuicaoNormal(mediaAritmetica, variancia, tamanhoPetala);
        //System.out.println("ver tam petala/  media :"+mediaAritmetica+" variancia :"+variancia );
        //System.out.println("valor 2 :"+versicolor[1] );
        System.out.println("MÉDIA TAMANHO DA PETALA :" + mediaAritmetica);
        System.out.println("VARIANCIA :" + variancia);

        mediaAritmetica = media.getMediaLarguraSepala(Classificacao.VERSICOLOR);
        variancia = Math.pow(desvioPadrao.getDesvioPadraoLarguraSepala(Classificacao.VERSICOLOR), 2);
        versicolor[2] = getDistribuicaoNormal(mediaAritmetica, variancia, larguraSepala);
        //System.out.println("ver larg sepala/  media :"+mediaAritmetica+" variancia :"+variancia );
        // System.out.println("valor 3 :"+versicolor[2] );
        System.out.println("MÉDIA LARGURA DA SEPALA :" + mediaAritmetica);
        System.out.println("VARIANCIA :" + variancia);

        mediaAritmetica = media.getMediaTamanhoSepala(Classificacao.VERSICOLOR);
        variancia = Math.pow(desvioPadrao.getDesvioPadraoTamanhoSepala(Classificacao.VERSICOLOR), 2);
        versicolor[3] = getDistribuicaoNormal(mediaAritmetica, variancia, tamanhoSepala);
        //System.out.println("ver tam sepala/  media :"+mediaAritmetica+" variancia :"+variancia );
        //System.out.println("valor 4 :"+versicolor[3] );
        System.out.println("MÉDIA TAMANHO DA SEPALA :" + mediaAritmetica);
        System.out.println("VARIANCIA :" + variancia);

        classeVersicolor = versicolor[0] * versicolor[1] * versicolor[2] * versicolor[3];
        //System.out.println("classeVersicolor" + classeVersicolor);

        //probabilidade de ser setosa
        System.out.println("==== SETOSA ====");
        mediaAritmetica = media.getMediaLarguraPetala(Classificacao.SETOSA);
        variancia = Math.pow(desvioPadrao.getDesvioPadraoLarguraPetala(Classificacao.SETOSA), 2);
        setosa[0] = getDistribuicaoNormal(mediaAritmetica, variancia, larguraPetala);
        //System.out.println("setosa largura petala "+mediaAritmetica+" variancia "+variancia);
        //System.out.println("valor 1 : "+setosa[0]);
        System.out.println("MÉDIA LARGURA DA PETALA :" + mediaAritmetica);
        System.out.println("VARIANCIA :" + variancia);

        mediaAritmetica = media.getMediaTamanhoPetala(Classificacao.SETOSA);
        variancia = Math.pow(desvioPadrao.getDesvioPadraoTamanhoPetala(Classificacao.SETOSA), 2);
        setosa[1] =getDistribuicaoNormal(mediaAritmetica, variancia, tamanhoPetala);
        //System.out.println("setosa tamanho petala "+mediaAritmetica+" variancia "+variancia);
        //System.out.println("valor 2 : "+setosa[1]);
        System.out.println("MÉDIA TAMANHO DA PETALA :" + mediaAritmetica);
        System.out.println("VARIANCIA :" + variancia);


        mediaAritmetica = media.getMediaLarguraSepala(Classificacao.SETOSA);
        variancia = Math.pow(desvioPadrao.getDesvioPadraoLarguraSepala(Classificacao.SETOSA), 2);
        setosa[2] = getDistribuicaoNormal(mediaAritmetica, variancia, larguraSepala);
        //System.out.println("setosa largura sepala "+mediaAritmetica+" variancia "+variancia);
        //System.out.println("valor 3 : "+setosa[2]);
        System.out.println("MÉDIA LARGURA DA SEPALA :" + mediaAritmetica);
        System.out.println("VARIANCIA :" + variancia);


        mediaAritmetica = media.getMediaTamanhoSepala(Classificacao.SETOSA);
        variancia = Math.pow(desvioPadrao.getDesvioPadraoTamanhoSepala(Classificacao.SETOSA), 2);
        setosa[3] = getDistribuicaoNormal(mediaAritmetica, variancia, tamanhoSepala);
        //System.out.println("setosa tamanho sepala "+mediaAritmetica+" variancia "+variancia);
        //System.out.println("valor 4 : "+setosa[3]);
        System.out.println("MÉDIA TAMANHO DA SEPALA :" + mediaAritmetica);
        System.out.println("VARIANCIA :" + variancia);


        classeSetosa = setosa[0] * setosa[1] * setosa[2] * setosa[3];
        //System.out.println("classeSetosa" + classeSetosa);


        System.out.println("==== VIRGINICA ===");
        //probabilidade de ser virginica
        mediaAritmetica = media.getMediaLarguraPetala(Classificacao.VIRGINICA);
        variancia = Math.pow(desvioPadrao.getDesvioPadraoLarguraPetala(Classificacao.VIRGINICA), 2);
        virginica[0] = getDistribuicaoNormal(mediaAritmetica, variancia, larguraPetala);
        //System.out.println("virginica largura petala "+mediaAritmetica+" variancia "+variancia);
        //System.out.println("valor 1 : "+setosa[0]);
        System.out.println("MÉDIA LARGURA DA PETALA :" + mediaAritmetica);
        System.out.println("VARIANCIA :" + variancia);


        mediaAritmetica = media.getMediaTamanhoPetala(Classificacao.VIRGINICA);
        variancia = Math.pow(desvioPadrao.getDesvioPadraoTamanhoPetala(Classificacao.VIRGINICA), 2);
        virginica[1] = getDistribuicaoNormal(mediaAritmetica, variancia, tamanhoPetala);
        //System.out.println("virginica tamanho petala "+mediaAritmetica+" variancia "+variancia);
        //System.out.println("valor 2 : "+setosa[1]);
        System.out.println("MÉDIA TAMANHO DA PETALA :" + mediaAritmetica);
        System.out.println("VARIANCIA :" + variancia);


        mediaAritmetica = media.getMediaLarguraSepala(Classificacao.VIRGINICA);
        variancia = Math.pow(desvioPadrao.getDesvioPadraoLarguraSepala(Classificacao.VIRGINICA), 2);
        virginica[2] = getDistribuicaoNormal(mediaAritmetica, variancia, larguraSepala);
        // System.out.println("virginica largura sepala "+mediaAritmetica+" variancia "+variancia);
        // System.out.println("valor 3 : "+setosa[2]);
        System.out.println("MÉDIA LARGURA DA SEPALA :" + mediaAritmetica);
        System.out.println("VARIANCIA :" + variancia);


        mediaAritmetica = media.getMediaTamanhoSepala(Classificacao.VIRGINICA);
        variancia = Math.pow(desvioPadrao.getDesvioPadraoTamanhoSepala(Classificacao.VIRGINICA), 2);
        virginica[3] = getDistribuicaoNormal(mediaAritmetica, variancia, tamanhoSepala);
        //System.out.println("virginica tamanho sepala "+mediaAritmetica+" variancia "+variancia);
        //System.out.println("valor 4 : "+setosa[3]);
        System.out.println("MÉDIA TAMANHO DA SEPALA :" + mediaAritmetica);
        System.out.println("VARIANCIA :" + variancia);


        classeVirginica = virginica[0] * virginica[1] * virginica[2] * virginica[3];
        // System.out.println("classeVirginica" + classeVirginica);

        //System.out.println("  " + tamanhoSepala + " " + larguraSepala + " " + tamanhoPetala + " " + larguraPetala);

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

       // value = (1 * Math.pow(neperiano, - Math.pow(atributo - media, 2) / (2 * variancia))) / Math.sqrt(2 * pi * variancia);

       value= Math.exp(-(atributo-media)*(atributo-media)/(2*variancia)) / Math.sqrt(2 * pi * variancia);

        return value;
    }
}

