package decorator;

public class Queijo extends Pizza {

    public Queijo() {
        setDescricao("Pizza de queijo");
    }

    @Override
    public double custo() {
        return 19.90;
    }
}