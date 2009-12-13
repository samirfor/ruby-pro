package app;

import java.sql.Date;

// <editor-fold defaultstate="collapsed" desc=" UML Marker "> 
// #[regen=yes,id=DCE.B87BE2ED-02EB-93A2-A8AD-799F95C4B035]
// </editor-fold> 
public class DVD {

    // <editor-fold defaultstate="collapsed" desc=" UML Marker "> 
    // #[regen=yes,id=DCE.0B5B7FE7-75DA-40F4-0A17-EC44EEB1EB48]
    // </editor-fold> 
    private int id;
    // <editor-fold defaultstate="collapsed" desc=" UML Marker "> 
    // #[regen=yes,id=DCE.58C0365C-769E-F327-961B-B8C1BB794396]
    // </editor-fold> 
    private Date dataCompra;
    // <editor-fold defaultstate="collapsed" desc=" UML Marker "> 
    // #[regen=yes,id=DCE.E33FB6C8-A501-FA98-FD29-D2EAEB1421A7]
    // </editor-fold> 
    private Double preco;
    private Situacao situacao;
    private Filme filme;

    public DVD() {
    }

    public Date getDataCompra() {
        return dataCompra;
    }

    public void setDataCompra(Date dataCompra) {
        this.dataCompra = dataCompra;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public Double getPreco() {
        return preco;
    }

    public void setPreco(Double preco) {
        this.preco = preco;
    }

    public Filme getFilme() {
        return filme;
    }

    public void setFilme(Filme filme) {
        this.filme = filme;
    }

    public Integer getFilmeId() {
        return filme.getId();
    }

    public void setFilmeId(Integer id) {
        filme.setId(id);
    }

    public Situacao getSituacao() {
        return situacao;
    }

    public void setSituacao(Situacao situacao) {
        this.situacao = situacao;
    }

    public void setSituacaoId(Integer id) {
        situacao.setId(id);
    }

    public Integer getSituacaoId() {
        return situacao.getId();
    }
}

