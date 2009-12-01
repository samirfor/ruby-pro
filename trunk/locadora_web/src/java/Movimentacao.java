
import java.util.Date;


// <editor-fold defaultstate="collapsed" desc=" UML Marker "> 
// #[regen=yes,id=DCE.1A9E5537-8D61-3B1C-343F-9ADE7BB0A00A]
// </editor-fold> 
public class Movimentacao {

    // <editor-fold defaultstate="collapsed" desc=" UML Marker "> 
    // #[regen=yes,id=DCE.FC264772-0136-6A3D-2C7E-7C73A0ADADD3]
    // </editor-fold> 
    private int id;

    // <editor-fold defaultstate="collapsed" desc=" UML Marker "> 
    // #[regen=yes,id=DCE.41E14DED-DCF8-B7AA-5305-FDC707288FC9]
    // </editor-fold> 
    private Date data;

    // <editor-fold defaultstate="collapsed" desc=" UML Marker "> 
    // #[regen=yes,id=DCE.760AAE0B-3C22-25B9-923F-82410406127E]
    // </editor-fold> 
    private Date dataEntrega;

    public Movimentacao() {
    }

    public Date getData() {
        return data;
    }

    public void setData(Date data) {
        this.data = data;
    }

    public Date getDataEntrega() {
        return dataEntrega;
    }

    public void setDataEntrega(Date dataEntrega) {
        this.dataEntrega = dataEntrega;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

}

