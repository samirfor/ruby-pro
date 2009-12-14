package dao;

import app.Filme;
import app.Genero;
import db.Conexao;
import excecao.NotInsertedClientException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class FilmeDao {

    private static FilmeDao instance;
    private boolean status;

    private FilmeDao() {
    }

    public static FilmeDao getInstance() {
        if (instance == null) {
            instance = new FilmeDao();
        }
        return instance;
    }

    public void insert(Filme filme) throws SQLException, ClassNotFoundException, NotInsertedClientException {
        Connection conn = Conexao.getInstance();
        String sql;
        sql = "INSERT INTO filme ";
        sql += "(titulo, ano, duracao, diretor, genero_id) ";
        sql += "VALUES (?,?,?,?,?);";
        PreparedStatement pStm = conn.prepareStatement(sql);
        pStm.setString(1, filme.getTitulo());
        pStm.setInt(2, filme.getAno());
        pStm.setInt(3, filme.getDuracao());
        pStm.setString(4, filme.getDiretor());
        pStm.setInt(5, filme.getGenero().getId());


        int qtd_insert = pStm.executeUpdate();
        pStm.close();

        if (qtd_insert < 1) {
            throw new NotInsertedClientException();
        }

    }

    public void update(Filme filme, Genero genero) throws SQLException, ClassNotFoundException {

        Connection conn = Conexao.getInstance();
        String sql;
        sql = "UPDATE filme ";
        sql += "SET (titulo, ano, duracao, diretor, genero_id) ";
        sql += "VALUES (?,?,?,?,?) WHERE filme_id = ?;";
        PreparedStatement pStm = conn.prepareStatement(sql);
        pStm.setString(1, filme.getTitulo());
        pStm.setInt(2, filme.getAno());
        pStm.setInt(3, filme.getDuracao());
        pStm.setString(4, filme.getDiretor());
        pStm.setInt(5, genero.getId());
        pStm.setInt(6, filme.getId());

        try {
            pStm.executeUpdate(sql);
            status = true;
        } catch (SQLException e) {
            status = false;
            System.out.print("Erro ao executar Query!");
            e.printStackTrace();
        }

    }

    public void delete(Filme filme) throws SQLException, ClassNotFoundException {
        Connection conn = Conexao.getInstance();
        String sql = "DELETE FROM filme WHERE filme_id = ?;";
        PreparedStatement pStm = conn.prepareStatement(sql);
        pStm.setInt(1, filme.getId());
        try {
            pStm.execute(sql);
            pStm.close();
            status = true;
        } catch (SQLException e) {
            status = false;
            System.out.print("Erro ao executar Query!");
            e.printStackTrace();
        }
    }

    public Filme findById(int id) throws SQLException, ClassNotFoundException {
        Connection conn = Conexao.getInstance();
        String sql = "SELECT * FROM filme WHERE filme_id = ?;";
        PreparedStatement pStm = conn.prepareStatement(sql);
        pStm.setInt(1, id);
        ResultSet rs = pStm.executeQuery();
        Filme f = new Filme();
        if (rs.next()) {
            f.setId(rs.getInt("filme_id"));
            f.setTitulo(rs.getString("titulo"));
            f.setAno(rs.getInt("duracao"));
            f.setDiretor(rs.getString("diretor"));
            f.getGenero().setId(rs.getInt("genero_id"));
        } else {
            f = null;
        }
        pStm.close();
        return f;

    }

    public List<Filme> findAll() throws SQLException, ClassNotFoundException {
        String sql = "SELECT f.*, g.descricao FROM filme f , genero g WHERE f.genero_id = g.genero_id ORDER BY f.filme_id";
        List<Filme> lista = new ArrayList<Filme>();
        Connection conn = Conexao.getInstance();
        Statement stm = conn.createStatement();
        ResultSet rs = stm.executeQuery(sql);
        while (rs.next()) {
            Filme f = new Filme();
            f.setId(rs.getInt("filme_id"));
            f.setTitulo(rs.getString("titulo"));
            f.setAno(rs.getInt("ano"));
            f.setDuracao(rs.getInt("duracao"));
            f.setDiretor(rs.getString("diretor"));
            f.getGenero().setId(rs.getInt("genero_id"));
            f.getGenero().setDescricao(rs.getString("descricao"));
            lista.add(f);
        }
        stm.close();
        return lista;
    }

//    protected void finalize() throws Throwable {
//        Conexao.closeConnection();
//        super.finalize();
//    }
}

