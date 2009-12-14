package dao;

import app.ItemMovimentacao;
import app.Movimentacao;
import db.Conexao;
import excecao.NotInsertedClientException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class MovimentacaoDao {

    private static MovimentacaoDao instance;
    private boolean status;

    private MovimentacaoDao() {
    }

    public static MovimentacaoDao getInstance() {
        if (instance == null) {
            instance = new MovimentacaoDao();
        }
        return instance;
    }

    public void insert(Movimentacao movimentacao) throws SQLException, ClassNotFoundException, NotInsertedClientException {
        Connection conn = Conexao.getInstance();
        String sql;
        sql = "INSERT INTO movimentacao (data_locacao, cliente_id) ";
        sql += "VALUES (?,?);";
        PreparedStatement pStm = conn.prepareStatement(sql);
        pStm.setDate(1, movimentacao.getDataLocacao());
        pStm.setInt(2, movimentacao.getClienteId());

        int qtd_insert = pStm.executeUpdate();

        if (qtd_insert < 1) {
            throw new NotInsertedClientException();
        }

        pStm.close();

    }

    public void update(Movimentacao movimentacao) throws SQLException, ClassNotFoundException {

        Connection conn = Conexao.getInstance();
        String sql;
        sql = "UPDATE movimentacao SET (data_locacao, data_entrega, cliente_id) ";
        sql += "VALUES (?,?,?) WHERE movimentacao_id = ?;";
        PreparedStatement pStm = conn.prepareStatement(sql);
        pStm.setDate(1, movimentacao.getDataLocacao());
        pStm.setDate(2, movimentacao.getDataEntrega());
        pStm.setInt(3, movimentacao.getClienteId());
        pStm.setInt(4, movimentacao.getId());

        try {
            pStm.executeUpdate(sql);
            status = true;
        } catch (SQLException e) {
            status = false;
            System.out.print("Erro ao executar Query!");
            e.printStackTrace();
        }

    }

    public void delete(Movimentacao movimentacao) throws SQLException, ClassNotFoundException {
        Connection conn = Conexao.getInstance();
        String sql = "DELETE FROM movimentacao WHERE movimentacao_id = ?;";
        PreparedStatement pStm = conn.prepareStatement(sql);
        pStm.setInt(1, movimentacao.getId());
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

    public Movimentacao findById(int id) throws SQLException, ClassNotFoundException {
        Connection conn = Conexao.getInstance();
        String sql = "SELECT * FROM movimentacao WHERE movimentacao_id = ?;";
        PreparedStatement pStm = conn.prepareStatement(sql);
        pStm.setInt(1, id);
        ResultSet rs = pStm.executeQuery();
        Movimentacao m = new Movimentacao();
        if (rs.next()) {
            m.setId(rs.getInt("movimentacao_id"));
            m.setDataEntrega(rs.getDate("data_entrega"));
            // tem o dvd da tabela????
        } else {
            m = null;
        }
        pStm.close();
        return m;

    }

    public List<ItemMovimentacao> findAll() throws SQLException, ClassNotFoundException {
        String sql = "SELECT * FROM item_movimentacao;";
        List<ItemMovimentacao> lista = new ArrayList<ItemMovimentacao>();
        Connection conn = Conexao.getInstance();
        Statement stm = conn.createStatement();
        ResultSet rs = stm.executeQuery(sql);
        while (rs.next()) {
            ItemMovimentacao i = new ItemMovimentacao();
            i.setId(rs.getInt("item_id"));
            i.setDataEntrega(rs.getDate("data_entrega"));
            //tem o dvd da tabela???
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

