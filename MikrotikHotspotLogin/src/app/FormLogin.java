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
        System.out.println("\tjava -jar MikrotikLogin [IPSERVIDOR] [LOGIN]");
        System.out.println("\tExemplo:\n\t\tjava -jar MikrotikLogin 10.0.0.1 samir");
    }

    public static void main(String[] args) throws MalformedURLException, IOException, SAXException {
//        args[0] = "10.0.0.1";
//        args[1] = "samir";

        System.out.println("MikroticLogin v1.0 by Samir");
        System.out.println("<samirfor@gmail.com>\n");
        System.out.println("GNU GENERAL PUBLIC LICENSE");
        System.out.println("Version 3, 29 June 2007");
        System.out.println("Copyright (C) 2007 Free Software Foundation, Inc. <http://fsf.org/>");
        System.out.println("Everyone is permitted to copy and distribute verbatim copies");
        System.out.println("of this license document, but changing it is not allowed\n");

        if (args.length != 2) {
            System.out.println("Quantidade de parâmetros inválida.");
            usage();
            System.exit(-1);
        }

        BrowserSilencioso browser = new BrowserSilencioso(args[0], args[1]);
        browser.open();
        System.out.println("\n\n" + args[1] + " autenticado com sucesso.");
        System.exit(0);
    }
}
