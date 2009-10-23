package rs;

import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author samir
 */
public class Executa {

    public static void main(String[] args) {
        String pagina = "http://security.ubuntu.com/ubuntu/pool/main/l/linux/linux-image-2.6.27-9-generic_2.6.27-9.19_i386.deb";
        try {
            Runtime.getRuntime().exec("wget "+pagina+" &");
        } catch (IOException ex) {
            Logger.getLogger(Executa.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
}
