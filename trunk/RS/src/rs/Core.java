/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package rs;

import java.io.IOException;
import java.util.HashMap;
import java.util.Scanner;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 *
 * @author Samir <samirfor@gmail.com>
 */
public class Core {

    /**
     * @param args - link para download
     */
    public static void main(String[] args) throws InterruptedException {

        Html pagina, pagina2, postResp = null, download_link;
        Html rapidshare, ssl;
        Pattern padrao;
        Matcher pesquisa;
        Scanner ler = new Scanner(System.in);
        String link, servidor, download;

        System.out.println("::: Rapidshare V2 :::\n");
        System.out.println(">>> Criado por Samir <samirfor@gmail.com>\n");

        // Captura link
        if (args.length == 1) {
            link = args[0];
        } else {
            System.out.println("\nQual link?");
            link = ler.next();
        }

        padrao = Pattern.compile("http://rapidshare.com/files/\\S+");
        pesquisa = padrao.matcher(link);
        if (pesquisa.find()) {
            System.out.println("Obtendo: " + link);

            // Identifica servidor
            System.out.println("Conectando...");
            ssl = new Html("https://ssl.rapidshare.com");
            rapidshare = new Html("http://rapidshare.com");
            pagina = new Html(link);
            pagina.substituirTudo("http://rapidshare.com", "http://" + rapidshare.getHost());
            pagina.substituirTudo("https://ssl.rapidshare.com", "https://" + ssl.getHost());
            padrao = Pattern.compile("http://rs\\w+.rapidshare.com");
            pesquisa = padrao.matcher(pagina.getBody());
            if (pesquisa.find()) {
                servidor = pesquisa.group();
                System.out.println("Servidor identificado: " + servidor);

                // Envia form através de POST
                System.out.println("Enviando requisição de download...");
                pagina2 = new Html(servidor + pagina.getPath());
                pagina2.substituirTudo("http://rapidshare.com", "http://" + rapidshare.getHost());
                pagina2.substituirTudo("https://ssl.rapidshare.com", "https://" + ssl.getHost());
                HashMap<String, String> hash = new HashMap<String, String>();
                hash.put("dl.start", "Free");
                try {
                    postResp = new Html();
                    postResp.setLink(pagina2.getLink());
                    System.out.println("Clicando no Free...");
                    postResp.setBody(pagina2.submit(pagina2.getLink(), hash));
                    postResp.substituirTudo("http://rapidshare.com", "http://" + rapidshare.getHost());
                    postResp.substituirTudo("https://ssl.rapidshare.com", "https://" + ssl.getHost());
                } catch (Exception ex) {
                    Logger.getLogger(Core.class.getName()).log(Level.SEVERE, null, ex);
                }

                // Verifica se há tempo de espera
                padrao = Pattern.compile("Or try again in about \\d+");
                pesquisa = padrao.matcher(postResp.getBody());
                if (pesquisa.find()) {
                    int tempo = Integer.parseInt(pesquisa.group().substring(22));
                    System.out.println("Você baixou recentemente um arquivo. Aguardando" + tempo + " minutos.");
                    Thread.sleep(tempo * 60 * 1000);
                }

                // Verifica se há download ativo
                padrao = Pattern.compile("already downloading a file");
                pesquisa = padrao.matcher(postResp.getBody());
                if (pesquisa.find()) {
                    System.out.println("O rapidshare detectou um download em andamento.");
                    System.out.println("Aguarde esse download terminar para poder baixar.");
                    System.exit(1);
                }

                // Identificar link pra download
                padrao = Pattern.compile("http://rs\\S+\\\\");
                pesquisa = padrao.matcher(postResp.getBody());
                if (pesquisa.find()) {
                    download = pesquisa.group().replace("\\", "");
                    System.out.println("Link Download identificado: " + download);
                    // Captura tempo de espera
                    System.out.println("\nCapturando tempo de espera:");
                    padrao = Pattern.compile("var c=\\d+");
                    pesquisa = padrao.matcher(postResp.getBody());
                    if (pesquisa.find()) {
                        String tempo = pesquisa.group().substring(6);
                        for (int i = Integer.parseInt(tempo) + 1; i >= 0; i--) {
                            System.out.println("Resta " + i + " segundos.");
                            try {
                                Thread.sleep(1000);
                            } catch (InterruptedException ie) {
                            }
                        }
                        postResp.substituirTudo(pesquisa.group(), "var c=0");
                    } else {
                        System.out.println("Não foi possível capturar o tempo.");
                    }

                    download_link = new Html();
                    download_link.setLink(download);
                    System.out.println("Donwload mod: " + download_link.getLink());

                    // Download por wget
                    try {
                        System.out.println("Baixando com o wget...");
                        Runtime.getRuntime().exec("wget " + download_link.getLink() + " &").wait();
                        System.out.println("Download terminado.");
                    } catch (IOException ex) {
                        Logger.getLogger(Core.class.getName()).log(Level.SEVERE, null, ex);
                    }

//                    // Grava resultado no arquivo
//                    try {
//                        postResp.toFile("RapidDownload.html");
//                        System.out.println("Resultado foi salvo no arquivo.");
//                    } catch (FileNotFoundException ex) {
//                        Logger.getLogger(Core.class.getName()).log(Level.SEVERE, null, ex);
//                    } catch (IOException ex) {
//                        Logger.getLogger(Core.class.getName()).log(Level.SEVERE, null, ex);
//                    }
                } else {
                    System.out.println("Não foi possível capturar o link de download.");
                }
            } else {
                System.out.println("Servidor não identificado.");
            }
        } else {
            System.out.println("Link inválido.");
        }
    }
}
