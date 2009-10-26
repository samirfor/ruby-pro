package grafico;

import rs.Core;

/**
 *
 * @author Samir <samirfor@gmail.com>
 */
public class LinkGotcher {

    public static void main(String[] args) throws InterruptedException {
        try {
            Question.main(args);
        } catch (Exception e) {
            System.out.println("Não foi possível carregar interface gráfica.");
            System.out.println("Mudando para modo texto.");
            Core.main(args);
        }
    }
}
