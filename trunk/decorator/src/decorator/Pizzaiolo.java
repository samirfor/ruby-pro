package decorator;

public class Pizzaiolo {

    public static void main(String[] args) {

        Pizza pz = new Queijo();

        pz = new Tomate(pz);
        pz = new Oregano(pz);
        pz = new Palmito(pz);

        System.out.println("Pedido: ");
        System.out.println(pz.getDescricao());
        System.out.println("Preço: R$ " + pz.custo());

        Pizza pz2 = new Calabresa();

        pz2 = new Tomate(pz2);
        pz2 = new Oregano(pz2);
        pz2 = new Azeitona(pz2);

        System.out.println("Pedido: ");
        System.out.println(pz2.getDescricao());
        System.out.println("Preço: R$ " + pz2.custo());

    }
}
