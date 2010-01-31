package app;

import java.io.IOException;
import java.net.MalformedURLException;
import org.xml.sax.SAXException;

/**
 *
 * @author samir
 */
public class FormLogin {

    public static void usage() {
        System.out.println("Uso:");
        System.out.println("\tjava -jar MikrotikLogin [URL_SERVER] [LOGIN] [SENHA]");
        System.out.println("\tExemplo:\n\t\tjava -jar MikrotikLogin bennet.com.br samir 8888");
    }

    public static void main(String[] args) throws MalformedURLException, IOException, SAXException {
        System.out.println("MikroticLogin v1.0 by Samir");
        System.out.println("<samirfor@gmail.com>\n");
        System.out.println("GNU GENERAL PUBLIC LICENSE");
        System.out.println("Version 3, 29 June 2007");
        System.out.println("Copyright (C) 2007 Free Software Foundation, Inc. <http://fsf.org/>");
        System.out.println("Everyone is permitted to copy and distribute verbatim copies");
        System.out.println("of this license document, but changing it is not allowed\n");

        if (args.length != 3) {
            System.out.println("Quantidade de parâmetros inválida.");
            usage();
            System.exit(-1);
        }

        BrowserSilencioso browser = new BrowserSilencioso(args[0], args[1], args[2]);
        browser.open();
        System.out.println("\n\n" + args[1] + " autenticado com sucesso.");
        System.exit(0);
    }
}
