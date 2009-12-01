
import java.util.Date;


// <editor-fold defaultstate="collapsed" desc=" UML Marker "> 
// #[regen=yes,id=DCE.9085111D-FAA3-ECB9-FE6B-6AF7DD878902]
// </editor-fold> 
public class ItemMovimentacao {

    // <editor-fold defaultstate="collapsed" desc=" UML Marker "> 
    // #[regen=yes,id=DCE.98B53DBF-6C01-62BA-409C-FA9D9D5A64FC]
    // </editor-fold> 
    private int id;

    // <editor-fold defaultstate="collapsed" desc=" UML Marker "> 
    // #[regen=yes,id=DCE.D92E55B4-B4A3-72AB-E7C2-D8E9DF50B04B]
    // </editor-fold> 
    private Date data;

    // <editor-fold defaultstate="collapsed" desc=" UML Marker "> 
    // #[regen=yes,id=DCE.3C826BF0-99C7-705E-B4EF-C2696284FBC3]
    // </editor-fold> 
    private Date dataEntrega;

    public ItemMovimentacao() {
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

