package dao;

import app.ItemMovimentacao;
import db.Conexao;
import excecao.NotInsertedClientException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class ItemMovimentacaoDao {

    private static ItemMovimentacaoDao instance;
    private boolean status;

    private ItemMovimentacaoDao() {
    }

    public static ItemMovimentacaoDao getInstance() {
        if (instance == null) {
            instance = new ItemMovimentacaoDao();
        }
        return instance;
    }

    public void insert(ItemMovimentacao itemMovimentacao) throws SQLException,
            ClassNotFoundException, NotInsertedClientException {
        Connection conn = Conexao.getInstance();
        String sql;
        sql = "INSERT INTO item_movimentacao (item_id, data_entrega, dvd) ";
        sql += "VALUES (?,?,?);";
        PreparedStatement pStm = conn.prepareStatement(sql);
        pStm.setInt(1, itemMovimentacao.getId());
        pStm.setDate(2, itemMovimentacao.getDataEntrega());
        pStm.setInt(3, itemMovimentacao.getDvd().getId());


        int qtd_insert = pStm.executeUpdate();
        pStm.close();

        if (qtd_insert < 1) {
            throw new NotInsertedClientException();
        }

    }

    public void update(ItemMovimentacao itemMovimentacao) throws SQLException,
            ClassNotFoundException {

        Connection conn = Conexao.getInstance();
        String sql;
        sql = "UPDATE item_movimentacao ";
        sql += "SET (data_entrega, dvd) ";
        sql += "VALUES (?,?) WHERE item_id = ?;";
        PreparedStatement pStm = conn.prepareStatement(sql);
        pStm.setDate(1, itemMovimentacao.getDataEntrega());
        pStm.setInt(2, itemMovimentacao.getDvd().getId());
        pStm.setInt(2, itemMovimentacao.getId());

        try {
            pStm.executeUpdate(sql);
            status = true;
        } catch (SQLException e) {
            status = false;
            System.out.print("Erro ao executar Query!");
            e.printStackTrace();
        }

    }

    public void delete(ItemMovimentacao itemMovimentacao) throws SQLException,
            ClassNotFoundException {
        Connection conn = Conexao.getInstance();
        String sql = "DELETE FROM item_movimentacao WHERE item_id = ?;";
        PreparedStatement pStm = conn.prepareStatement(sql);
        pStm.setInt(1, itemMovimentacao.getId());
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

    public ItemMovimentacao findById(int id) throws SQLException,
            ClassNotFoundException {
        Connection conn = Conexao.getInstance();
        String sql = "SELECT * FROM item_movimentacao WHERE item_id = ?;";
        PreparedStatement pStm = conn.prepareStatement(sql);
        pStm.setInt(1, id);
        ResultSet rs = pStm.executeQuery();
        ItemMovimentacao i = new ItemMovimentacao();
        if (rs.next()) {
            i.setId(rs.getInt("item_id"));
            i.setDataEntrega(rs.getDate("data_entrega"));
            // tem o dvd da tabela????
        } else {
            i = null;
        }
        pStm.close();
        return i;

    }

    public List<ItemMovimentacao> findAll() throws SQLException,
            ClassNotFoundException {
        String sql = "SELECT * FROM item_movimentacao;";
        List<ItemMovimentacao> lista = new ArrayList<ItemMovimentacao>();
        Connection conn = Conexao.getInstance();
        Statement stm = conn.createStatement();
        ResultSet rs = stm.executeQuery(sql);
        while (rs.next()) {
            ItemMovimentacao i = new ItemMovimentacao();
            i.setId(rs.getInt("item_id"));
            i.setDataEntrega(rs.getDate("data_entrega"));
            i.getDvd().setId(rs.getInt("dvd"));
            lista.add(i);
        }
        stm.close();
        return lista;
    }

//    @Override
//    protected void finalize() throws Throwable {
//        Conexao.closeConnection();
//        super.finalize();
//    }
}

