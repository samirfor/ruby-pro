package app;

import java.sql.Date;

// <editor-fold defaultstate="collapsed" desc=" UML Marker "> 
// #[regen=yes,id=DCE.2CC0C1EA-FD4F-A60B-B5C5-07844C354126]
// </editor-fold> 
public class Cliente {

    // <editor-fold defaultstate="collapsed" desc=" UML Marker "> 
    // #[regen=yes,id=DCE.94EC769E-F56A-1D03-A1D0-C012560A926A]
    // </editor-fold> 
    private int id;
    // <editor-fold defaultstate="collapsed" desc=" UML Marker "> 
    // #[regen=yes,id=DCE.0824DF90-508A-43DA-CDC8-0151D52B9CC8]
    // </editor-fold> 
    private String nome;
    // <editor-fold defaultstate="collapsed" desc=" UML Marker "> 
    // #[regen=yes,id=DCE.C40DB5C8-D3CC-2C8B-EA8D-F9C77D4B62AA]
    // </editor-fold> 
    private Long fone;
    // <editor-fold defaultstate="collapsed" desc=" UML Marker "> 
    // #[regen=yes,id=DCE.F0100D52-E9DA-A548-1932-26FFADD192B6]
    // </editor-fold> 
    private Long RG;
    // <editor-fold defaultstate="collapsed" desc=" UML Marker "> 
    // #[regen=yes,id=DCE.B8BE3F54-74C4-03A9-75D4-4066A0E42514]
    // </editor-fold> 
    private Long CPF;
    // <editor-fold defaultstate="collapsed" desc=" UML Marker "> 
    // #[regen=yes,id=DCE.8A72FA0F-4DD2-D53D-CFF0-968A74679947]
    // </editor-fold> 
    private Date dataNascimento;

    public Cliente() {
    }

    public Long getCPF() {
        return CPF;
    }

    public void setCPF(Long CPF) {
        this.CPF = CPF;
    }

    public Long getRG() {
        return RG;
    }

    public void setRG(Long RG) {
        this.RG = RG;
    }

    public Date getDataNascimento() {
        return dataNascimento;
    }

    public void setDataNascimento(Date dataNascimento) {
        this.dataNascimento = dataNascimento;
    }

    public Long getFone() {
        return fone;
    }

    public void setFone(Long fone) {
        this.fone = fone;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getNome() {
        return nome;
    }

    public void setNome(String nome) {
        this.nome = nome;
    }
}

