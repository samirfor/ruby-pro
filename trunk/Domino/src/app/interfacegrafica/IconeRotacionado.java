package app.interfacegrafica;

import java.awt.Component;
import java.awt.Graphics2D;
import java.awt.Graphics;
import java.awt.Rectangle;
import java.awt.geom.AffineTransform;
import javax.swing.Icon;

/**
 *  A classe IconeRotacionado permite mudar a orientação de um Icon rotacionando
 *  o Icon antes de painted. Esta classe suporta as seguintes orientações:
 *
 * <ul>
 * <li>BAIXO - rotaciona 90 graus
 * <li>CIMA (padrão) - rotaciona 90 graus
 * <li>CABECA_PRA_BAIXO - rotaciona 180 graus
 * <li>SOBRE_CENTRO - o icone é rotacionado a um ângulo específico em torno do 
 * centro. O ângulo de rotação é especificado quando a classe é criada.
 * </ul>
 */
public class IconeRotacionado implements Icon {

    public enum Rotate {

        BAIXO,
        CIMA,
        CABECA_PRA_BAIXO,
        SOBRE_CENTRO;
    }
    private Icon icone;
    private Rotate rotate;
    private double angulo;

    /**
     *  Contrutor para criar um IconeRotacionado para BAIXO.
     *
     *  @param icone  o Icon to rotacionar
     */
    public IconeRotacionado(Icon icone) {
        this(icone, Rotate.CIMA);
    }

    /**
     *  Cria um IconeRotacionado
     *
     *  @param icone  o Icon to rotacionar
     *  @param rotate  a direção de rotação
     */
    public IconeRotacionado(Icon icone, Rotate rotate) {
        this.icone = icone;
        this.rotate = rotate;
    }

    /**
     *  Cria um IconeRotacionado. O icone será rotacionado em torno do centro.
     *  Este construtor setará automaticamente o enumerador Rotate para SOBRE_CENTRO.
     *  Para icones retangulares, o ícone será colado antes da rotação
     *  para ter certeza que não será pintado em cima do resto do componente.
     *
     *  @param icone    o Icon para rotacão
     *  @param angulo   o ângulo de rotação
     */
    public IconeRotacionado(Icon icone, double angulo) {
        this(icone, Rotate.SOBRE_CENTRO);
        this.angulo = angulo;
    }

    /**
     *  Obtém um Icon para ser rotacionado.
     *
     *  @return o Icon the Icon para ser rotacionado.
     */
    public Icon getIcone() {
        return icone;
    }

    /**
     *  Obtém o enumerador Rotate que indica a direção de rotação.
     *
     *  @return o enumerador Rotate
     */
    public Rotate getRotate() {
        return rotate;
    }

    /**
     *  Obtém o ângulo de rotação. Use somente para Rotate.SOBRE_CENTRO.
     *
     *  @return o ângulo de rotação.
     */
    public double getAngulo() {
        return angulo;
    }

//
//  Implementa a Interface Icon
//
    /**
     *  Obtém o comprimento deste ícone.
     *
     *  @return o comprimento de um ícone em pixels.
     */
    @Override
    public int getIconWidth() {
        if (rotate == Rotate.CABECA_PRA_BAIXO || rotate == Rotate.SOBRE_CENTRO) {
            return icone.getIconWidth();
        } else {
            return icone.getIconHeight();
        }
    }

    /**
     *  Obtém a altura deste ícone.
     *
     *  @return a altura do ícone em pixels.
     */
    @Override
    public int getIconHeight() {
        if (rotate == Rotate.CABECA_PRA_BAIXO || rotate == Rotate.SOBRE_CENTRO) {
            return icone.getIconHeight();
        } else {
            return icone.getIconWidth();
        }
    }

    /**
     *  Pinta os componentes destes ícone num local específico.
     *
     *  @param c O componente no qual o ícone é pintado
     *  @param g o contexto gráfico
     *  @param x a coordenada X do ícone no canto superior esquedo
     *  @param y a coordenada Y do ícone no canto superior esquedo
     */
    @Override
    public void paintIcon(Component c, Graphics g, int x, int y) {
        Graphics2D g2 = (Graphics2D) g.create();

        int cWidth = icone.getIconWidth() / 2;
        int cHeight = icone.getIconHeight() / 2;
        int xAdjustment = (icone.getIconWidth() % 2) == 0 ? 0 : -1;
        int yAdjustment = (icone.getIconHeight() % 2) == 0 ? 0 : -1;

        if (rotate == Rotate.BAIXO) {
            g2.translate(x + cHeight, y + cWidth);
            g2.rotate(Math.toRadians(90));
            icone.paintIcon(c, g2, -cWidth, yAdjustment - cHeight);
        } else if (rotate == Rotate.CIMA) {
            g2.translate(x + cHeight, y + cWidth);
            g2.rotate(Math.toRadians(-90));
            icone.paintIcon(c, g2, xAdjustment - cWidth, -cHeight);
        } else if (rotate == Rotate.CABECA_PRA_BAIXO) {
            g2.translate(x + cWidth, y + cHeight);
            g2.rotate(Math.toRadians(180));
            icone.paintIcon(c, g2, xAdjustment - cWidth, yAdjustment - cHeight);
        } else if (rotate == Rotate.SOBRE_CENTRO) {
            Rectangle r = new Rectangle(x, y, icone.getIconWidth(), icone.getIconHeight());
            g2.setClip(r);
            AffineTransform original = g2.getTransform();
            AffineTransform at = new AffineTransform();
            at.concatenate(original);
            at.rotate(Math.toRadians(angulo), x + cWidth, y + cHeight);
            g2.setTransform(at);
            icone.paintIcon(c, g2, x, y);
            g2.setTransform(original);
        }
    }
}
