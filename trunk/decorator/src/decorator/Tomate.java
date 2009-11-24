package decorator;

public class Tomate extends DecoratorCondimento {

    Pizza pizza;

    public Tomate(Pizza pz) {
        pizza = pz;
    }

    @Override
    public String getDescricao() {
        return pizza.getDescricao() + ", Tomate ";
    }

    @Override
    public double custo() {
        return .10 + pizza.custo();
    }
}
