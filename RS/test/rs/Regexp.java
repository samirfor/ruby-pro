/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package rs;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 *
 * @author samir
 */
public class Regexp {

    public static void main(String[] args) {
        String s = "afjebkjgej kdgj ewkkkdiksr\n\n\t\risihtvar c=149;apidshare.com/aeejh.rar ea";
        s += "ocument.dlf.action=\'http://rs276tl.rapidshare.com/files/296235273/8829980/CSI.NY.S06E05.HDTV.XviD-2HD.part1.rar\\\';\" Telia";
        Pattern padrao = Pattern.compile("http://rs\\S+\\\\");//, Pattern.MULTILINE | Pattern.DOTALL | Pattern.CASE_INSENSITIVE);
        Matcher pesquisa = padrao.matcher(s);

        if (pesquisa.find()) {
            System.out.println(s);
            System.out.println(pesquisa.group());
        } else {
            System.out.println("Não bateu nada. :\\");
        }
    }
}
