package perceptron;

/**
 * 
 * @author Samir Coutinho Costa <samirfor@gmail.com>
 */
public class Padrao {

    private double comprimentoSepala; //comprimento de sépala
    private double larguraSepala;//largura de sépala
    private double comprimentoPetala; //comprimento de pétala
    private double larguraPetala; //largura de pétala
    private Classificacao classificacao;

    public Padrao(double comprimentoSepala, double larguraSepala, double comprimentoPetala, double larguraPetala, Classificacao classe) {
        this.comprimentoSepala = comprimentoSepala;
        this.larguraSepala = larguraSepala;
        this.comprimentoPetala = comprimentoPetala;
        this.larguraPetala = larguraPetala;
        this.classificacao = classe;
    }

    public double getComprimentoSepala() {
        return comprimentoSepala;
    }

    public void setComprimentoSepala(double comprimentoSepala) {
        this.comprimentoSepala = comprimentoSepala;
    }

    public double getLarguraSepala() {
        return larguraSepala;
    }

    public void setLarguraSepala(double larguraSepala) {
        this.larguraSepala = larguraSepala;
    }

    public double getComprimentoPetala() {
        return comprimentoPetala;
    }

    public void setComprimentoPetala(double comprimentoPetala) {
        this.comprimentoPetala = comprimentoPetala;
    }

    public double getLarguraPetala() {
        return larguraPetala;
    }

    public void setLarguraPetala(double larguraPetala) {
        this.larguraPetala = larguraPetala;
    }

    public void setClassificacao(Classificacao classificacao) {
        this.classificacao = classificacao;
    }

    public Classificacao getClassificacao() {
        return classificacao;
    }
}
