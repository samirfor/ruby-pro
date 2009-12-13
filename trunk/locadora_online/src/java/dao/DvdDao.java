package dao;

import app.DVD;
import db.Conexao;
import excecao.NotInsertedClientException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class DvdDao {

    private static DvdDao instance;
    private boolean status;

    private DvdDao() {
    }

    public static DvdDao getInstance() {
        if (instance == null) {
            instance = new DvdDao();
        }
        return instance;
    }

    public void insert(DVD dvd) throws SQLException, ClassNotFoundException, NotInsertedClientException {
        Connection conn = Conexao.getInstance();
        String sql;
        sql = "INSERT INTO dvd (data_compra, preco, filme_id) VALUES (?,?,?);";
        PreparedStatement pStm = conn.prepareStatement(sql);
        pStm.setDate(1, dvd.getDataCompra());
        pStm.setDouble(2, dvd.getPreco());
        pStm.setInt(3, dvd.getFilmeId());

        int qtd_insert = pStm.executeUpdate();
        pStm.close();

        if (qtd_insert < 1) {
            throw new NotInsertedClientException();
        }

    }

    public void update(DVD dvd) throws SQLException, ClassNotFoundException {

        Connection conn = Conexao.getInstance();
        String sql;
        sql = "UPDATE dvd SET (data_compra, preco, situacao, filme_id) ";
        sql += "VALUES (?,?,?,?) WHERE dvd_id = ?;";
        PreparedStatement pStm = conn.prepareStatement(sql);
        pStm.setDate(1, dvd.getDataCompra());
        pStm.setDouble(2, dvd.getPreco());
        pStm.setInt(3, dvd.getSituacaoId());
        pStm.setInt(4, dvd.getFilmeId());
        pStm.setInt(5, dvd.getId());

        try {
            pStm.executeUpdate(sql);
            status = true;
        } catch (SQLException e) {
            status = false;
            System.out.print("Erro ao executar Query!");
            e.printStackTrace();
        }

    }

    public void delete(DVD dvd) throws SQLException, ClassNotFoundException {
        Connection conn = Conexao.getInstance();
        String sql = "DELETE FROM dvd WHERE dvd_id = ?;";
        PreparedStatement pStm = conn.prepareStatement(sql);
        pStm.setInt(1, dvd.getId());
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

    public DVD findById(int id) throws SQLException, ClassNotFoundException {
        Connection conn = Conexao.getInstance();
        String sql = "SELECT * FROM dvd WHERE dvd_id = ?;";
        PreparedStatement pStm = conn.prepareStatement(sql);
        pStm.setInt(1, id);
        ResultSet rs = pStm.executeQuery();
        DVD d = new DVD();
        if (rs.next()) {
            d.setId(rs.getInt("dvd_id"));
            d.setDataCompra(rs.getDate("data_compra"));
            d.setPreco(rs.getDouble("preco"));
            d.setSituacaoId(rs.getInt("situacao"));
            d.setFilmeId(rs.getInt("filme_id"));
        } else {
            d = null;
        }
        pStm.close();
        return d;

    }

    public List<DVD> findAll() throws SQLException, ClassNotFoundException {
        String sql = "SELECT * FROM dvd;";
        List<DVD> lista = new ArrayList<DVD>();
        Connection conn = Conexao.getInstance();
        Statement stm = conn.createStatement();
        ResultSet rs = stm.executeQuery(sql);
        while (rs.next()) {
            DVD d = new DVD();
            d.setId(rs.getInt("dvd_id"));
            d.setDataCompra(rs.getDate("data_compra"));
            d.setPreco(rs.getDouble("preco"));
            d.setSituacaoId(rs.getInt("situacao"));
            d.setFilmeId(rs.getInt("filme_id"));
            lista.add(d);
        }
        stm.close();
        return lista;
    }

    @Override
    protected void finalize() throws Throwable {
        Conexao.closeConnection();
        super.finalize();
    }
}

