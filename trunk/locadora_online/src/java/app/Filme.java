package app;

// <editor-fold defaultstate="collapsed" desc=" UML Marker "> 
// #[regen=yes,id=DCE.F0EDD20A-9A3D-E84D-248A-ECD71A1200BD]
// </editor-fold> 
public class Filme {

    // <editor-fold defaultstate="collapsed" desc=" UML Marker ">
    // #[regen=yes,id=DCE.5AAC5DDE-8B8B-849E-D35E-E00013E8D006]
    // </editor-fold>
    private int id;
    // <editor-fold defaultstate="collapsed" desc=" UML Marker "> 
    // #[regen=yes,id=DCE.3B8E3928-B6CE-8D4B-40E8-292D02A01E45]
    // </editor-fold> 
    private String titulo;
    // <editor-fold defaultstate="collapsed" desc=" UML Marker "> 
    // #[regen=yes,id=DCE.65D6DA6B-932E-9350-5064-AA4B4560693C]
    // </editor-fold> 
    private Integer ano;
    // <editor-fold defaultstate="collapsed" desc=" UML Marker "> 
    // #[regen=yes,id=DCE.D0D2B3CB-5997-82A8-D4CE-3AAB5644EC01]
    // </editor-fold> 
    private Integer duracao;
    // <editor-fold defaultstate="collapsed" desc=" UML Marker "> 
    // #[regen=yes,id=DCE.53556548-9767-CF15-6BA0-ACB2696A0325]
    // </editor-fold> 
    private String diretor;
    private Genero genero = new Genero();

    public Filme() {
    }

    public Genero getGenero() {
        return genero;
    }

    public void setGenero(Genero genero) {
        this.genero = genero;
    }

    public void setGeneroId(Integer id) {
        genero.setId(id);
    }

    public Integer getGeneroId() {
        return genero.getId();
    }

    public Integer getAno() {
        return ano;
    }

    public void setAno(Integer ano) {
        this.ano = ano;
    }

    public String getDiretor() {
        return diretor;
    }

    public void setDiretor(String diretor) {
        this.diretor = diretor;
    }

    public Integer getDuracao() {
        return duracao;
    }

    public void setDuracao(Integer duracao) {
        this.duracao = duracao;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getTitulo() {
        return titulo;
    }

    public void setTitulo(String titulo) {
        this.titulo = titulo;
    }
}

