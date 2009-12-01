
import java.util.Date;


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
    private double preco;

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

    public double getPreco() {
        return preco;
    }

    public void setPreco(double preco) {
        this.preco = preco;
    }

}

