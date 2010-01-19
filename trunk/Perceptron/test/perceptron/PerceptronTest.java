/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package perceptron;

import org.junit.After;
import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;
import static org.junit.Assert.*;

/**
 *
 * @author samir
 */
public class PerceptronTest {

    public PerceptronTest() {
    }

    @BeforeClass
    public static void setUpClass() throws Exception {
    }

    @AfterClass
    public static void tearDownClass() throws Exception {
    }

    @Before
    public void setUp() {
    }

    @After
    public void tearDown() {
    }

    @Test
    public void testPerceptron() {
        Perceptron p = new Perceptron();
        System.out.println("Pesos antes do treino: ");
        p.imprimeMatriz(p.pesos);
        p.calculoDelta();
        System.out.println("Pesos após o treino: ");
        p.imprimeMatriz(p.pesos);
    }
}
