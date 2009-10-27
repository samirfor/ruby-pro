
import java.io.IOException;
import java.io.InputStream;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import mikrotik.LerArquivo;

/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
/**
 *
 * @author samir
 */
public class HexMD5 {

    public static void main(String[] args) throws IOException {
        Pattern padrao;
        Matcher pesquisa;
        String senha = null, aux = null;
        String texto;

        texto = LerArquivo.ler("/home/samir/login.htm");
        System.out.println(texto);

        // Core MD5
        padrao = Pattern.compile("hexMD5\\S+");
        System.out.println("Padrao => " + padrao.toString());
        pesquisa = padrao.matcher(texto);
        if (pesquisa.find()) {
            senha = pesquisa.group().replaceAll("hexMD5\\(\'", "").replaceAll("\'", "");
            aux = senha;
//            MD5.run(link);
            System.out.println("Senha: " + senha);

        } else {
            System.out.println("Não bateu.");
        }

        padrao = Pattern.compile("password.value + \'\\S+");
        System.out.println("Padrao => " + padrao.toString());
        pesquisa = padrao.matcher(texto);

        if (pesquisa.find()) {
            senha = pesquisa.group().replaceAll("password.value + \'", "");
            aux += senha;
//            MD5.run(link);
            System.out.println("Senha: " + senha);
            System.out.println("Aux: " + aux);

        } else {
            System.out.println("Não bateu.");
        }
    }
}
