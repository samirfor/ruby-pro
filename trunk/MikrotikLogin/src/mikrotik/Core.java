package mikrotik;

import java.util.HashMap;
import java.util.Scanner;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 *
 * @author Samir <samirfor@gmail.com>
 */
public class Core {

    /**
     * @param args - link para download
     * @throws InterruptedException 
     */
    public static void main(String[] args) throws InterruptedException {

        Html pagina, pagina2, postResp = null, download_link;
        Pattern padrao;
        Matcher pesquisa;
        Scanner ler = new Scanner(System.in);
        String link, senha;

        System.out.println("::: Mikrotik Login V1.0 :::\n");
        System.out.println(">>> Criado por Samir <samirfor@gmail.com>\n");

        link = "http://10.0.0.1/login";

        pagina = new Html(link);

        // Core MD5
        padrao = Pattern.compile("document.sendin.password.value = hexMD5(\\S+");
        pesquisa = padrao.matcher(pagina.getBody());
        if (pesquisa.find()) {
            senha = pesquisa.group().replaceAll("document.sendin.password.value = hexMD5(", "");
//            MD5.run(link);
        } else {
            System.out.println("Não foi possível capturar o hash MD5.");
        }
        // Envia form através de POST
        System.out.println("Enviando requisição de login...");
        HashMap<String, String> hash = new HashMap<String, String>();
        hash.put("username", "samir");
        hash.put("password", "");
        hash.put("dst", "http://www.google.com");
        hash.put("popup", "true");
//        try {
//            postResp = new Html();
//            postResp.setLink(pagina2.getLink());
//            System.out.println("Clicando no Free...");
//            postResp.setBody(pagina2.submit(pagina2.getLink(), hash));
//            postResp.substituirTudo("http://rapidshare.com", "http://" + rapidshare.getHost());
//            postResp.substituirTudo("https://ssl.rapidshare.com", "https://" + ssl.getHost());
//        } catch (Exception ex) {
//            Logger.getLogger(Core.class.getName()).log(Level.SEVERE, null, ex);
//        }
//
//        // Verifica se há tempo de espera
//        padrao = Pattern.compile("Or try again in about \\d+");
//        pesquisa = padrao.matcher(postResp.getBody());
//        if (pesquisa.find()) {
//            int tempo = Integer.parseInt(pesquisa.group().substring(22));
//            System.out.println("Você baixou recentemente um arquivo. Aguardando " + tempo + " minutos.");
//            Thread.sleep(tempo * 60 * 1000);
//            System.out.println("Execute novamente para fazer o download.");
//        }
//
//        // Verifica se há download ativo
//        padrao = Pattern.compile("already downloading a file");
//        pesquisa = padrao.matcher(postResp.getBody());
//        if (pesquisa.find()) {
//            System.out.println("O rapidshare detectou um download em andamento.");
//            System.out.println("Aguarde esse download terminar para poder baixar.");
//            System.exit(1);
//        }
//
//        // Identificar link pra download
//        padrao = Pattern.compile("http://rs\\S+\\\\");
//        pesquisa = padrao.matcher(postResp.getBody());
//        if (pesquisa.find()) {
//            download = pesquisa.group().replace("\\", "");
//            System.out.println("Link Download identificado: " + download);
//            // Captura tempo de espera
//            System.out.println("\nCapturando tempo de espera:");
//            padrao = Pattern.compile("var c=\\d+");
//            pesquisa = padrao.matcher(postResp.getBody());
//            if (pesquisa.find()) {
//                String tempo = pesquisa.group().substring(6);
//                for (int i = Integer.parseInt(tempo) + 1; i >= 0; i--) {
//                    System.out.println("Resta " + i + " segundos.");
//                    try {
//                        Thread.sleep(1000);
//                    } catch (InterruptedException ie) {
//                    }
//                }
//                postResp.substituirTudo(pesquisa.group(), "var c=0");
//            } else {
//                System.out.println("Não foi possível capturar o tempo.");
//            }
//
//            download_link = new Html();
//            download_link.setLink(download);
//            System.out.println("Donwload mod: " + download_link.getLink());
//
//            // Download por wget
//            String comando = "gnome-terminal -e 'cd $HOME && wget ";
//            comando += download_link.getLink() + "'";
//            System.out.println("Baixando com o wget...");
//            try {
//                Runtime.getRuntime().exec(comando);
//            } catch (IOException iOException) {
//                System.out.println("Erro de I/O.");
//                System.err.println(iOException);
//            }
//            System.out.println("Download terminado.");
//
////                    // Grava resultado no arquivo
////                    try {
////                        postResp.toFile("RapidDownload.html");
////                        System.out.println("Resultado foi salvo no arquivo.");
////                    } catch (FileNotFoundException ex) {
////                        Logger.getLogger(Core.class.getName()).log(Level.SEVERE, null, ex);
////                    } catch (IOException ex) {
////                        Logger.getLogger(Core.class.getName()).log(Level.SEVERE, null, ex);
////                    }
//        } else {
//            System.out.println("Não foi possível capturar o link de download.");
//        }
    }
}
