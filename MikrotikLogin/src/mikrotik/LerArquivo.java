package mikrotik;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;

/**
 *
 * @author samir
 */
public class LerArquivo {

    public static String ler(String path) {
        try {
            BufferedReader in = new BufferedReader(new FileReader(path));
            String str = "";
            while (in.ready()) {
                str += in.readLine() + "\n";
            }
            in.close();
            return str;
        } catch (IOException e) {
            e.printStackTrace();
            System.out.println("Não foi possivel ler o arquivo.");
            return null;
        }
    }
}
