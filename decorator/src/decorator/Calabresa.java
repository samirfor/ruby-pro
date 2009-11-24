package decorator;

public class Calabresa extends Pizza {

    public Calabresa() {
        setDescricao("Pizza de calabresa");
    }

    @Override
    public double custo() {
        return 21.99;
    }
}