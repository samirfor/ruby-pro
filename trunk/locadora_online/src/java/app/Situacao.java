package app;

// <editor-fold defaultstate="collapsed" desc=" UML Marker "> 
// #[regen=yes,id=DCE.6E4F29F0-3EE5-D20C-A1D8-7FDF15A7F6CC]
// </editor-fold> 
public class Situacao {

    // <editor-fold defaultstate="collapsed" desc=" UML Marker "> 
    // #[regen=yes,id=DCE.6FDA73D5-6DBD-5286-AD13-9A0EDF34E7BF]
    // </editor-fold> 
    private int id;
    // <editor-fold defaultstate="collapsed" desc=" UML Marker "> 
    // #[regen=yes,id=DCE.8E80A3CC-6BD1-7E48-434F-334CF9BE95A5]
    // </editor-fold> 
    private String descricao;

    public Situacao() {
    }

    public String getDescricao() {
        return descricao;
    }

    public void setDescricao(String descricao) {
        this.descricao = descricao;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }
}