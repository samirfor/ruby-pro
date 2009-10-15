package regras;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Random;
import java.util.Scanner;
import jogador.Jogador;
import pecas.Peca;

// <editor-fold defaultstate="collapsed" desc=" UML Marker "> 
// #[regen=yes,id=DCE.18927EE1-2187-BC3F-A6DD-73AA479A4160]
// </editor-fold> 
public class JogoRegras implements Serializable {

    /**
     *  <p style="margin-top: 0">
     *        Lista com as pe&#231;as que poder&#227;o ser obtidas quando um jogador n&#227;o possuir 
     *        nenhuma pe&#231;a pr&#243;pria para jogar.
     *      </p>
     */
    // <editor-fold defaultstate="collapsed" desc=" UML Marker "> 
    // #[regen=yes,id=DCE.7BF6102A-E348-48B1-2921-10C77C495F0A]
    // </editor-fold> 
    private ArrayList<Peca> dorme;
    private boolean empatou;
    private boolean ganhou;
    /**
     *  <p style="margin-top: 0">
     *    Tabuleiro do jogo com todas as pe&#231;as j&#225; jogadas.
     *      </p>
     */
    // <editor-fold defaultstate="collapsed" desc=" UML Marker "> 
    // #[regen=yes,id=DCE.E30F3841-313E-9A99-9782-DE33A28F2156]
    // </editor-fold> 
    private ArrayList<Peca> tabuleiro;

    // <editor-fold defaultstate="collapsed" desc=" UML Marker "> 
    // #[regen=yes,id=DCE.DC07DAD2-D318-9792-F26B-08A93E441BCA]
    // </editor-fold> 
    public JogoRegras() {
        dorme = new ArrayList<Peca>();
        tabuleiro = new ArrayList<Peca>();
        empatou = false;
        ganhou = false;
    }

    public boolean isGanhou() {
        return ganhou;
    }

    public void setGanhou(boolean ganhou) {
        this.ganhou = ganhou;
    }

    public boolean isEmpatou() {
        return empatou;
    }

    public void setEmpatou(boolean empatou) {
        this.empatou = empatou;
    }

    // <editor-fold defaultstate="collapsed" desc=" UML Marker "> 
    // #[regen=yes,regenBody=yes,id=DCE.0621D08B-4E29-C155-4D74-509B86E349EF]
    // </editor-fold> 
    public ArrayList getDorme() {
        return dorme;
    }

    // <editor-fold defaultstate="collapsed" desc=" UML Marker "> 
    // #[regen=yes,regenBody=yes,id=DCE.1AB0BFE7-51EB-79F8-CC93-7D5DCB78BA2E]
    // </editor-fold> 
    public void setDorme(ArrayList val) {
        this.dorme = val;
    }

    public int[] getPontas() {
        int retorno[] = new int[2];

        retorno[0] = tabuleiro.get(0).getPeca()[0];
        retorno[1] = tabuleiro.get(tabuleiro.size() - 1).getPeca()[1];

        return retorno;
    }

    public String mostraPontas() {
        String s = "";
        s += "{" + getPontas()[0] + ", " + getPontas()[1] + "}";
        return s;
    }

    /**
     * Determina se o jogador da vez passou a vez ou não, observando se ele
     * tiver pelo menos uma peça com pelo menos um valor possível de se jogar.
     * @param jogador
     * @return
     * Retorna true se o jogador passou ou false se o jogador não passou a vez.
     */
    public boolean passou(Jogador jogador) {
        if (jogador.buscaValor(getPontas()[0]) != -1) {
            return false;
        } else {
            if (jogador.buscaValor(getPontas()[1]) != -1) {
                return false;
            } else {
                jogador.setStatus("Você passou.");
                System.out.println("Jogador " + jogador.getId() + " passou.");
                return true;
            }
        }
    }

    // <editor-fold defaultstate="collapsed" desc=" UML Marker "> 
    // #[regen=yes,id=DCE.3A0F3D41-2C04-B8EB-64A5-E31FAB872F0D]
    // </editor-fold>
    /**
     * Retira a peça da mão do jogador e coloca no tabuleiro na ponta
     * especificada no parâmetro ponta (-1 = esquerda ; 1 = direita ; 0 = primeira jogada).
     */
    public boolean jogada(Jogador jogador, int posicao, int ponta) {
        Peca peca = jogador.getPeca(posicao);

        if (ponta == 0) { // Primeira jogada
            tabuleiro.add(peca);
            jogador.getMao().remove(posicao);
            jogador.setStatus("Primeira jogada OK!");
            return true;
        } else if (ponta == 1) { // Lado direito
            if (validaJogada(jogador, peca, 1, posicao)) {
                peca = jogador.getPeca(posicao);
                tabuleiro.add(peca);
            } else {
                jogador.setStatus("Jogada inválida. Tente novamente.");
                return false;
            }
        } else if (ponta == -1) { // Lado esquerdo
            if (validaJogada(jogador, peca, -1, posicao)) {
                peca = jogador.getPeca(posicao); // atualiza a peca
                tabuleiro.add(0, peca);
            } else {
                jogador.setStatus("Jogada inválida. Tente novamente.");
                return false;
            }
        } else {
            jogador.setStatus("Jogada inválida: ponta inválida.");
            return false;
        }
        jogador.getMao().remove(posicao);
        jogador.setStatus("Jogada OK!");
        return true;
    }

    // <editor-fold defaultstate="collapsed" desc=" UML Marker "> 
    // #[regen=yes,id=DCE.19E9676D-E964-D6EF-BEF0-762C2AD11BC6]
    // </editor-fold> 
    public String mostrarTabuleiro() {
        String s = "";
        for (int i = 0; i < tabuleiro.size(); i++) {
            s += i + ": " + tabuleiro.get(i);
        }
        return s;
    }

    // <editor-fold defaultstate="collapsed" desc=" UML Marker "> 
    // #[regen=yes,id=DCE.E74B6943-FA6A-A6F2-739B-89503452274F]
    // </editor-fold> 
    public Peca reordenar(Jogador jogador, Peca peca) {

        Peca retorno;
        int aux[];

        aux = peca.getPeca();
        retorno = new Peca(aux[1], aux[0]);

        return retorno; // retorna peça invertida
    }

    // <editor-fold defaultstate="collapsed" desc=" UML Marker "> 
    // #[regen=yes,regenBody=yes,id=DCE.30CFAF78-F4E0-DD4C-7D6E-2CD2EE6AE6EB]
    // </editor-fold> 
    public ArrayList getTabuleiro() {
        return tabuleiro;
    }

    // <editor-fold defaultstate="collapsed" desc=" UML Marker "> 
    // #[regen=yes,regenBody=yes,id=DCE.24ECB337-AB33-F0F1-5DB8-9A9EFB890047]
    // </editor-fold> 
    public void setTabuleiro(ArrayList val) {
        this.tabuleiro = val;
    }

    public void embaraiarTabuleiro() {

        Random numeroRandom = new Random();
        ArrayList<Peca> tabuleiro_embaraiado = new ArrayList<Peca>();
        int index_aleatorio = 0;
        int tamanho = tabuleiro.size();

        for (int i = 0; i < tamanho; i++) {
            if (i != tamanho - 1) {
                index_aleatorio = numeroRandom.nextInt(tamanho - i - 1);
            }
            tabuleiro_embaraiado.add(tabuleiro.get(index_aleatorio));
            tabuleiro.remove(index_aleatorio);
        }
        tabuleiro_embaraiado.remove(28);
        tabuleiro = tabuleiro_embaraiado;
    }

    public void criarTabuleiro() {
        for (int j = 0; j < 7; j++) {
            for (int k = j; k < 7; k++) {
                Peca peca = new Peca(j, k);
                tabuleiro.add(peca);
            }
        }

        /**
         * Adicionamos uma peça fictícia para a carroça de 6 ser
         * devidamente sorteada.
         */
        Peca peca_ficticia = new Peca(9, 9);
        tabuleiro.add(peca_ficticia);
        embaraiarTabuleiro();
    }

    public void criarEmpate(Jogador j, int i) {
        Peca peca;
        ArrayList<Peca> mao = new ArrayList<Peca>();

        peca = new Peca(i, i);
        mao.add(peca);
        i--;
        peca = new Peca(i, i);
        mao.add(peca);
        j.setMao(mao);
    }

    /**
     * Retorna true se conseguiu realizar a operação e false se não.
     */
    public boolean darMao(Jogador jogador) {

        if (tabuleiro.size() != 0) {
            for (int i = 0; i < 7; i++) {
                jogador.getMao().add(tabuleiro.get(i));
                tabuleiro.remove(i);
            }
            return true;
        } else {
            System.out.println("Não há peças no tabuleiro.");
            return false;
        }
    }

    /**
     * Após definir a mão dos jogadores, se restarem peças,
     * este método será chamado.
     */
    public void definirDorme() {
        dorme.addAll(tabuleiro);
        tabuleiro.clear();
    }

    public String mostrarDorme() {
        String s = "";
        for (int i = 0; i < dorme.size(); i++) {
            s += i + ": " + dorme.get(i);
        }
        return s;
    }

    /**
     * Se caso um jogador passar, este método será chamado e move as peças
     * do dorme para a mão do jogador.
     * @param jogador
     * @return
     */
    public boolean puxaDorme(Jogador jogador) {
        if (dorme.size() != 0) {
            jogador.getMao().add(dorme.get(0));
            dorme.remove(0);
            jogador.setStatus("Você puxou do dorme.");
            System.out.println("Jogador " + jogador.getId() + " puxou do dorme.");
            return true;
        } else {
            jogador.setStatus("Você passou a vez.");
            System.out.println("Jogador " + jogador.getId() + " passou a vez.");
            return false;
        }
    }

    /**
     * Enquanto houver dorme, o jogador que passar vai puxar e o método retorna
     * true. Se não houver dorme, retorna false.
     * @param jogador
     * @return
     */
    public boolean passouVez(Jogador jogador) {
        int i = 1;

        while (passou(jogador)) {           // Enquanto o jogador passar:
            if (getDorme().size() != 0) {   // Se houver dorme
                jogador.setStatus("Você passou " + i + " vezes.");
                i++;
                puxaDorme(jogador);         // O jogador puxa.
            } else {                        // Se não houver dorme
                jogador.setStatus("Você passou a vez.");
                return true;
            }
        }
        return false;                       // Jogador não passou a vez
    }

    public int buscaMaiorCarrocao(Jogador jogador) {
        for (int i = 6; i > -1; i--) {
            Peca carrocao = new Peca(i, i);
            for (int j = 0; j < jogador.getMao().size(); j++) {
                if (carrocao.equals(jogador.getMao().get(j))) {
                    return j;
                }
            }
        }
        return -1;
    }

    /**
     * Define quem jogará primeiro de acordo com as suas peças.
     * Retorna 1 se o jogador 1 jogar primeiro;
     * Retorna 2 se o jogador 2 jogar primeiro;
     * Retorna 0 se ninguém jogar.
     */
    public int primeiraJogada(Jogador jogador1, Jogador jogador2) {
        int index_J1, index_J2;
        int carrocao_J1, carrocao_J2;

        // Busca no jogador1
        index_J1 = buscaMaiorCarrocao(jogador1);
        if (index_J1 != -1) { // Encontrou um carroção no jogador 1
            carrocao_J1 = jogador1.getMao().get(index_J1).getPeca()[0]; // Guarda o número do carroção

            // Busca no jogador2
            index_J2 = buscaMaiorCarrocao(jogador2);
            if (index_J2 != -1) { // Encontrou um carroção no jogador 2
                carrocao_J2 = jogador2.getMao().get(index_J2).getPeca()[0]; // Guarda o número do carroção
            } else { // O jogador 2 não tem carroção, o jogador 1 joga seu carroção.
                jogada(jogador1, index_J1, 0);
                return 1;
            }

            // Compara os carroções
            if (carrocao_J1 > carrocao_J2) {
                jogada(jogador1, index_J1, 0);
                return 1;
            } else {
                jogada(jogador2, index_J2, 0);
                return 2;
            }
        } else { // Não encontrou carroção no jogador 1
            index_J2 = buscaMaiorCarrocao(jogador2);
            if (index_J2 != -1) {
                jogada(jogador2, index_J2, 0);
                return 2;
            } else {
                // Ninguém num tem nenhum carroção, égua mah!
                // Reiniciando o jogo...
                return 0;
            }
        }
    }

    public boolean validaJogada(Jogador jogador, Peca peca_escolhida, int ponta, int index_mao) {
        Peca peca_invertida;

        // Teste se o index_mao está aceitável
        if (index_mao >= 0 && index_mao < jogador.getMao().size()) {
            if (ponta == 1) {
                if (peca_escolhida.getPeca()[0] == tabuleiro.get(tabuleiro.size() - 1).getPeca()[1]) {
                    return true;
                } else if (peca_escolhida.getPeca()[1] == tabuleiro.get(tabuleiro.size() - 1).getPeca()[1]) {
                    peca_invertida = reordenar(jogador, peca_escolhida);
                    jogador.getMao().set(index_mao, peca_invertida);
                    return true;
                }
            } else {  // ponta == -1
                if (peca_escolhida.getPeca()[0] == tabuleiro.get(0).getPeca()[0]) {
                    peca_invertida = reordenar(jogador, peca_escolhida);
                    jogador.getMao().set(index_mao, peca_invertida);
                    return true;
                } else if (peca_escolhida.getPeca()[1] == tabuleiro.get(0).getPeca()[0]) {
                    return true;
                }
            }
        }
        return false;
    }

    public void soutJogada(Jogador jogador) {
        Scanner ler = new Scanner(System.in);
        int posicao = -2, ponta = -2;
        boolean resposta;

        jogador.setStatus("Agora é sua vez.");
        System.out.println(jogador.getStatus());
        System.out.println("\n\n>>>>>>>>>>>>\nTabuleiro:");
        System.out.println(mostrarTabuleiro());
        System.out.println("\nJogada:");
        System.out.println("Suas peças:");
        System.out.println(jogador.mostrarMao());
        do {
            System.out.print("Escolher peça número: ");
            posicao = ler.nextInt();
            System.out.print("\nPonta: (-1) para cima e (1) para baixo\n");
            ponta = ler.nextInt();
            resposta = jogada(jogador, posicao, ponta);
            System.out.println(">> " + jogador.getStatus());
        } while (!resposta);
    }
}
