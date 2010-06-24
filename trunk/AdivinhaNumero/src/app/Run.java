/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package app;

import gui.MainInterface;

/**
 *
 * @author samir
 */
public class Run {

    public Run() {
    }

    public static void main(String[] args) {
        System.out.println("Iniciando programa...");
        try {
            MainInterface.main(args);
        } catch (Exception e) {
            System.out.println("Não foi possível abrir em modo gráfico.");
        }
    }
}
