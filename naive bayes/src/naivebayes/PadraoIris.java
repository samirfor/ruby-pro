/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package naivebayes;

/**
 *
 * @author JonasRodrigues
 */
public class PadraoIris {

    private double tamanho_sepala;
    private double largura_sepala;
    private double tamanho_petala;
    private double largura_petala;
    private Classificacao classe;

    public PadraoIris(double tamanho_sepala, double largura_sepala, double tamanho_petala, double largura_petala, Classificacao classe) {
        this.tamanho_sepala = tamanho_sepala;
        this.largura_sepala = largura_sepala;
        this.tamanho_petala = tamanho_petala;
        this.largura_petala = largura_petala;
        this.classe = classe;

    }

    public Classificacao getClasse() {
        return classe;
    }

    public void setClasse(Classificacao classe) {
        this.classe = classe;
    }

    public double getLargura_petala() {
        return largura_petala;
    }

    public void setLargura_petala(double largura_petala) {
        this.largura_petala = largura_petala;
    }

    public double getLargura_sepala() {
        return largura_sepala;
    }

    public void setLargura_sepala(double largura_sepala) {
        this.largura_sepala = largura_sepala;
    }

    public double getTamanho_petala() {
        return tamanho_petala;
    }

    public void setTamanho_petala(double tamanho_petala) {
        this.tamanho_petala = tamanho_petala;
    }

    public double getTamanho_sepala() {
        return tamanho_sepala;
    }

    public void setTamanho_sepala(double tamanho_sepala) {
        this.tamanho_sepala = tamanho_sepala;
    }
}
