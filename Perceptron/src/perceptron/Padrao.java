package perceptron;

/**
 * 
 * @author Samir Coutinho Costa <samirfor@gmail.com>
 */
public class Padrao {

    private double comprimentoSepala;
    private double larguraSepala;
    private double comprimentoPetala;
    private double larguraPetala;
    private Classificacao tipo;

    public Padrao(double comprimentoSepala, double larguraSepala, double comprimentoPetala, double larguraPetala, Classificacao tipo) {
        this.comprimentoSepala = comprimentoSepala;
        this.larguraSepala = larguraSepala;
        this.comprimentoPetala = comprimentoPetala;
        this.larguraPetala = larguraPetala;
        this.tipo = tipo;
    }

    public double getComprimentoSepala() {
        return comprimentoSepala;
    }

    public void setComprimentoSepala(double comprimento) {
        this.comprimentoSepala = comprimento;
    }

    public double getLarguraSepala() {
        return larguraSepala;
    }

    public void setLarguraSepala(double largura) {
        this.larguraSepala = largura;
    }

    public double getComprimentoPetala() {
        return comprimentoPetala;
    }

    public void setComprimentoPetala(double comprimento) {
        this.comprimentoPetala = comprimento;
    }

    public double getLarguraPetala() {
        return larguraPetala;
    }

    public void setLarguraPetala(double largura) {
        this.larguraPetala = largura;
    }

    public Classificacao getTipo() {
        return tipo;
    }

    public void setTipo(Classificacao classe) {
        this.tipo = classe;
    }
}
