package decorator;

public class Palmito extends DecoratorCondimento {

    Pizza pizza;

    public Palmito(Pizza pz) {
        pizza = pz;
    }

    @Override
    public String getDescricao() {
        return pizza.getDescricao() + ", Palmito ";
    }

    @Override
    public double custo() {
        return .50 + pizza.custo();
    }
}
