package decorator;

public class Oregano extends DecoratorCondimento {

    Pizza pizza;

    public Oregano(Pizza pz) {
        pizza = pz;
    }

    @Override
    public String getDescricao() {
        return pizza.getDescricao() + ", Oregano";
    }

    @Override
    public double custo() {
        return .30 + pizza.custo();
    }
}
