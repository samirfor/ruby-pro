package pecas;

// <editor-fold defaultstate="collapsed" desc=" UML Marker "> 

import java.io.Serializable;

// #[regen=yes,id=DCE.40437170-2D96-ABA2-24F5-8C411A64E20A]
// </editor-fold> 
public class Peca implements Serializable {

    // <editor-fold defaultstate="collapsed" desc=" UML Marker "> 
    // #[regen=yes,id=DCE.A47F5C03-A50B-73C6-6222-BB7A476AC04B]
    // </editor-fold> 
    int pecas[];

    // <editor-fold defaultstate="collapsed" desc=" UML Marker "> 
    // #[regen=yes,id=DCE.0526C788-1BC0-8D20-1227-F5F92BE29B1B]
    // </editor-fold> 
    public Peca(int i, int j) {
        pecas = new int[2];
        pecas[0] = i;
        pecas[1] = j;
    }

    // <editor-fold defaultstate="collapsed" desc=" UML Marker "> 
    // #[regen=yes,regenBody=yes,id=DCE.0545DDDA-99EE-2CEE-9B4C-53D1A8AD0C69]
    // </editor-fold> 
    public int[] getPeca() {
        return pecas;
    }

    // <editor-fold defaultstate="collapsed" desc=" UML Marker "> 
    // #[regen=yes,regenBody=yes,id=DCE.ADE79DCB-C4D0-F6CA-9CAE-9098BDD5DDD5]
    // </editor-fold> 
    public void setPeca(int[] val) {
        this.pecas = val;
    }

    @Override
    public String toString() {
        String s = "{" + pecas[0] + ", " + pecas[1] + "}\n";
        return s;
    }

    public boolean equals(Peca p) {
        if (pecas[0] == p.getPeca()[0] && pecas[1] == p.getPeca()[1]) {
            return true;
        }
        else {
            return false;
        }
    }



}

