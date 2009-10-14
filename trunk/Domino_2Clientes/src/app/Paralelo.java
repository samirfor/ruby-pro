package app;

public class Paralelo extends Thread {

    private int identificacao;

    public int getIdentificacao() {
        return identificacao;
    }

    public void setIdentificacao(int identificacao) {
        this.identificacao = identificacao;
    }

    public Paralelo(int id) {
        this.identificacao = id;
    }

    @Override
    public void run() {
        
        try {

            sleep((long) (Math.random() * 1000));
        } catch (InterruptedException e) {
            System.out.println("Fim da thread " + getId());
        }
    }
}
