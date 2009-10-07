package jogador;

import java.util.ArrayList;
import pecas.Peca;

/**
 *  <p style="margin-top: 0">
 *        Obt&#233;m os dados de um determinado jogador como, as pe&#231;as em sua m&#227;o.
 *      </p>
 */
// <editor-fold defaultstate="collapsed" desc=" UML Marker "> 
// #[regen=yes,id=DCE.D80BA623-998F-7D93-8338-194BC66DC9ED]
// </editor-fold> 
public class Jogador {

    // <editor-fold defaultstate="collapsed" desc=" UML Marker "> 
    // #[regen=yes,id=DCE.7B662070-D8B0-A672-33B5-BB3B024C100E]
    // </editor-fold> 
    private boolean ganhou;
    // <editor-fold defaultstate="collapsed" desc=" UML Marker "> 
    // #[regen=yes,id=DCE.D73A1FA4-B3BE-CCA4-A4F3-EC2502A6F521]
    // </editor-fold> 
    private ArrayList<Peca> mao;

    // <editor-fold defaultstate="collapsed" desc=" UML Marker "> 
    // #[regen=yes,id=DCE.E610E17F-17E6-033A-6073-B39E657155D2]
    // </editor-fold> 
    public Jogador() {
        mao = new ArrayList<Peca>();
    }

    // <editor-fold defaultstate="collapsed" desc=" UML Marker "> 
    // #[regen=yes,regenBody=yes,id=DCE.D4352D1A-BC89-20CE-AD59-6A020AED135E]
    // </editor-fold> 
    public ArrayList<Peca> getMao() {
        return mao;
    }

    // <editor-fold defaultstate="collapsed" desc=" UML Marker "> 
    // #[regen=yes,regenBody=yes,id=DCE.FA340F54-D8CB-A64D-0D7F-9607E1EB154A]
    // </editor-fold> 
    public void setMao(ArrayList<Peca> mao) {
        this.mao = mao;
    }

    // <editor-fold defaultstate="collapsed" desc=" UML Marker "> 
    // #[regen=yes,regenBody=yes,id=DCE.B4BC9155-7972-E3FA-CCCB-A4A8749982CD]
    // </editor-fold> 
    public boolean isGanhou() {
        return ganhou;
    }

    // <editor-fold defaultstate="collapsed" desc=" UML Marker "> 
    // #[regen=yes,regenBody=yes,id=DCE.F36F234B-7CF0-7399-D3D1-36C0518774FE]
    // </editor-fold> 
    public void setGanhou(boolean val) {
        this.ganhou = val;
    }

    public String mostrarMao() {
        String s = "";
        for (int i = 0; i < mao.size(); i++) {
            s += i + ": " + mao.get(i);
        }
        return s;
    }

    public Peca getPeca(int index) {
        return mao.get(index);
    }

    public int getSomatorio(Peca peca) {
        return peca.getPeca()[0] + peca.getPeca()[1];
    }
}

