package decorator;

public class Azeitona extends DecoratorCondimento {

    Pizza pizza;

    public Azeitona(Pizza pz) {
        pizza = pz;
    }

    @Override
    public String getDescricao() {
        return pizza.getDescricao() + ", Azeitona ";
    }

    @Override
    public double custo() {
        return .25 + pizza.custo();
    }
}
