package dmc;

public class Padrao {

    private double comprimento_sepala;
    private double largura_sepala;
    private double comprimento_petala;
    private double largura_petala;
    private Classificacao classe;

    public Padrao(double comprimento_sepala, double largura_sepala, double comprimento_petala, double largura_petala, Classificacao classe) {
        this.comprimento_sepala = comprimento_sepala;
        this.largura_sepala = largura_sepala;
        this.comprimento_petala = comprimento_petala;
        this.largura_petala = largura_petala;
        this.classe = classe;
    }

    public double getComprimentoSepala() {
        return comprimento_sepala;
    }

    public void setComprimentoSepala(double comprimento) {
        this.comprimento_sepala = comprimento;
    }

    public double getLarguraSepala() {
        return largura_sepala;
    }

    public void setLarguraSepala(double largura) {
        this.largura_sepala = largura;
    }

    public double getComprimentoPetala() {
        return comprimento_petala;
    }

    public void setComprimentoPetala(double comprimento) {
        this.comprimento_petala = comprimento;
    }

    public double getLarguraPetala() {
        return largura_petala;
    }

    public void setLarguraPetala(double largura) {
        this.largura_petala = largura;
    }

    public Classificacao getClasse() {
        return classe;
    }

    public void setClasse(Classificacao classe) {
        this.classe = classe;
    }
}
