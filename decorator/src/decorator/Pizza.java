package decorator;

public abstract class Pizza {

    private String descricao = "Pizza desconhecida";

    public void setDescricao(String desc) {
        descricao = desc;
    }

    public String getDescricao() {
        return descricao;
    }

    public abstract double custo();
}