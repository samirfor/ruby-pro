/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package rs;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.HashMap;
import java.util.Scanner;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author Samir <samirfor@gmail.com>
 */
public class Main {

    /**
     * @param args - link para download
     */
    public static void main(String[] args) {

        Html pagina, pagina2, postResp = null;
        Scanner ler = new Scanner(System.in);
        String link, servidor, respostaPost;
        int primeiro_indice, ultimo_indice;

        System.out.println("::: Rapidshare V2 :::\n");
        System.out.println(">>> Criado por Samir <samirfor@gmail.com>\n");

        // Captura link
        if (args.length == 1) {
            link = args[0];
        } else {
            System.out.println("\nQual link?");
            link = ler.next();
        }

        // Identifica servidor
        System.out.println("Conectando...");
        pagina = new Html(link);
        primeiro_indice = pagina.buscaString("http://rs");
        ultimo_indice = primeiro_indice + 27;
        servidor = pagina.getBody().substring(primeiro_indice, ultimo_indice);
        System.out.println("Servidor identificado: " + servidor);

        // Envia form através de POST
        System.out.println("Enviando requisição de download...");
        pagina2 = new Html(servidor + pagina.getPath());
        HashMap<String, String> hash = new HashMap<String, String>();
        hash.put("dl.start", "Free");
        try {
            postResp = new Html();
            postResp.setLink(pagina2.getLink());
            System.out.println("action: " + pagina2.getLink());
            postResp.setBody(pagina2.submit(pagina2.getLink(), hash));
        } catch (Exception ex) {
            Logger.getLogger(Main.class.getName()).log(Level.SEVERE, null, ex);
        }

        // Grava resultado no arquivo
        try {
            postResp.toFile("postResp.html");
            System.out.println("Resultado foi salvo no arquivo.");
        } catch (FileNotFoundException ex) {
            Logger.getLogger(Main.class.getName()).log(Level.SEVERE, null, ex);
        } catch (IOException ex) {
            Logger.getLogger(Main.class.getName()).log(Level.SEVERE, null, ex);
        }
        try {
            pagina2.toFile("pagina2.html");
            System.out.println("Resultado foi salvo no arquivo.");
        } catch (FileNotFoundException ex) {
            Logger.getLogger(Main.class.getName()).log(Level.SEVERE, null, ex);
        } catch (IOException ex) {
            Logger.getLogger(Main.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
}
