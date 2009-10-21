/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package rs;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Scanner;
import java.util.logging.Level;
import java.util.logging.Logger;
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
        Pattern padraoServidor = Pattern.compile("http://rs\\d{1,3}\\S\\+.com", Pattern.MULTILINE);
        StringBuilder sb = new StringBuilder();

        System.out.println("::: Rapidshare V2 :::\n");
        System.out.println(">>> Criado por Samir <samirfor@gmail.com>\n");
        System.out.println("\nQual link?");
//        link = ler.next();
        link = "http://rapidshare.com/files/290179269/BB3.6_Oct.Ep.3.shan.mkv.001";

        if (pagina.modificaHost(link)) {
            System.out.println("Link mod: " + pagina.getLink());

            try {
                pagina.toFile();
            } catch (FileNotFoundException ex) {
                Logger.getLogger(Main.class.getName()).log(Level.SEVERE, null, ex);
            } catch (IOException ex) {
                Logger.getLogger(Main.class.getName()).log(Level.SEVERE, null, ex);
            }
            
            System.out.println(pagina.getBody().indexOf("http://rs"));
            System.out.println(pagina.getBody().substring(pagina.getBody().indexOf("http://rs"), (pagina.getBody().indexOf("http://rs"))+27));
//            ArrayList<String> resultados = new ArrayList<String>();
//            System.out.println(pagina.getBody().split(padrao)[0]);
            // http://rs000.rapidshare.com
        }
    }
}