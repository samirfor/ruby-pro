/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package rs;

import java.util.ArrayList;
import java.util.Scanner;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 *
 * @author multi
 */
public class Main {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {

        Html pagina = new Html();
        Html servidor = new Html();
        Scanner ler = new Scanner(System.in);
        String link, pag;
        Pattern padraoServidor = Pattern.compile("\\S+$");
        StringBuilder sb = new StringBuilder();

        System.out.println("::: Rapidshare V2 :::\n");
        System.out.println(">>> Criado por Samir <samirfor@gmail.com>\n");
        System.out.println("\nQual link?");
//        link = ler.next();
        link = "http://rapidshare.com/files/290179269/BB3.6_Oct.Ep.3.shan.mkv.001";

        if (pagina.modificaHost(link)) {
            System.out.println("Link mod: " + pagina.getLink());

            pag = pagina.getBody();
            Matcher fit = padraoServidor.matcher(pagina.getBody());
            System.out.println(fit.matches());
//            ArrayList<String> resultados = new ArrayList<String>();
//            System.out.println(pagina.getBody().split(padrao)[0]);
        }
    }
}
