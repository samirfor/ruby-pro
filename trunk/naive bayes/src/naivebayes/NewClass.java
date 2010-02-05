/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package naivebayes;

import java.util.ArrayList;
import java.util.Vector;

/**
 *
 * @author jonas
 */
public class NewClass {
    
    private ArrayList<PadraoIris> padroes  = new ArrayList<PadraoIris>();

    public NewClass(double iris[][]) {

        for (int i = 0; i < iris.length; i++) {
            
            Classificacao classe =null;
            if(iris[i][4]==1.0){
                classe = classe.SETOSA;

            } else if(iris[i][4]==2.0){

                 classe = classe.VERSICOLOR;
            } else if(iris[i][4]==3.0){

                 classe = classe.VIRGINICA;
            }
            padroes.add(new PadraoIris(iris[i][0], iris[i][1], iris[i][2], iris[i][3],  classe));

        }


    }

    public void getIntervalo() {
         for (int i = 0; i <padroes.size(); i++) {
            System.out.print(padroes.get(i).getTamanho_sepala());
         }

    }
}


