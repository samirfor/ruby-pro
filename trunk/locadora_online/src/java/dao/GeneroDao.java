package dao;

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

public class GeneroDao {

    private static GeneroDao instance;
    private boolean status;

    private GeneroDao() {
    }

    public static GeneroDao getInstance() {
        if (instance == null) {
            instance = new GeneroDao();
        }
        return instance;
    }

    public void insert(Genero genero) throws SQLException, ClassNotFoundException, NotInsertedClientException {
        Connection conn = Conexao.getInstance();
        String sql;
        sql = "INSERT INTO genero (descricao) VALUES (?);";
        PreparedStatement pStm = conn.prepareStatement(sql);
        pStm.setString(1, genero.getDescricao());

        int qtd_insert = pStm.executeUpdate();
        pStm.close();

        if (qtd_insert < 1) {
            throw new NotInsertedClientException();
        }

    }

    public void update(Genero genero) throws SQLException, ClassNotFoundException {

        Connection conn = Conexao.getInstance();
        String sql;
        sql = "UPDATE genero SET (descricao) VALUES (?) WHERE genero_id = ?;";
        PreparedStatement pStm = conn.prepareStatement(sql);
        pStm.setString(1, genero.getDescricao());

        try {
            pStm.executeUpdate(sql);
            status = true;
        } catch (SQLException e) {
            status = false;
            System.out.print("Erro ao executar Query!");
            e.printStackTrace();
        }

    }

    public void delete(Genero genero) throws SQLException, ClassNotFoundException {
        Connection conn = Conexao.getInstance();
        String sql = "DELETE FROM genero WHERE genero_id = ?;";
        PreparedStatement pStm = conn.prepareStatement(sql);
        pStm.setInt(1, genero.getId());
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

    public Genero findById(int id) throws SQLException, ClassNotFoundException {
        Connection conn = Conexao.getInstance();
        String sql = "SELECT * FROM genero WHERE genero_id = ?;";
        PreparedStatement pStm = conn.prepareStatement(sql);
        pStm.setInt(1, id);
        ResultSet rs = pStm.executeQuery();
        Genero g = new Genero();
        if (rs.next()) {
            g.setId(rs.getInt("genero_id"));
            g.setDescricao(rs.getString("descricao"));
        } else {
            g = null;
        }
        pStm.close();
        return g;

    }

    public List<Genero> findAll() throws SQLException, ClassNotFoundException {
        String sql = "SELECT * FROM genero;";
        List<Genero> lista = new ArrayList<Genero>();
        Connection conn = Conexao.getInstance();
        Statement stm = conn.createStatement();
        ResultSet rs = stm.executeQuery(sql);
        while (rs.next()) {
            Genero f = new Genero();
            f.setId(rs.getInt("genero_id"));
            f.setDescricao(rs.getString("descricao"));
            lista.add(f);
        }
        stm.close();
        return lista;
    }

    protected void finalize() throws Throwable {
        Conexao.closeConnection();
        super.finalize();
    }
}

