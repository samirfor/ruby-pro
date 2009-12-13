package dao;

import app.Cliente;
import db.Conexao;
import excecao.NotInsertedClientException;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class ClienteDao {

    private boolean status;
    private static ClienteDao instance;

    private ClienteDao() {
    }

    public static ClienteDao getInstance() {
        if (instance == null) {
            instance = new ClienteDao();
        }
        return instance;
    }

    public void insert(Cliente cliente) throws SQLException, ClassNotFoundException, NotInsertedClientException {
        Connection conn = Conexao.getInstance();
        String sql;
        sql = "INSERT INTO cliente ";
        sql += "(cliente_id, nome, fone, rg, cpf, data_nasc) ";
        sql += "VALUES (?,?,?,?,?,?);";
        PreparedStatement pStm = conn.prepareStatement(sql);
        pStm.setInt(1, cliente.getId());
        pStm.setString(2, cliente.getNome());
        pStm.setLong(3, cliente.getFone());
        pStm.setLong(4, cliente.getRG());
        pStm.setLong(5, cliente.getCPF());
        pStm.setDate(6, (Date) cliente.getDataNascimento());

        int qtd_insert = pStm.executeUpdate();
        pStm.close();

        if (qtd_insert < 1) {
            throw new NotInsertedClientException();
        }

    }

    public void update(Cliente cliente) throws SQLException, ClassNotFoundException {

        Connection conn = Conexao.getInstance();
        String sql;
        sql = "UPDATE cliente ";
        sql += "SET (nome, fone, rg, cpf, data_nasc) ";
        sql += "VALUES (?,?,?,?,?) WHERE cliente_id = ";
        sql += cliente.getId() + ";";
        PreparedStatement pStm = conn.prepareStatement(sql);
        pStm.setString(1, cliente.getNome());
        pStm.setLong(2, cliente.getFone());
        pStm.setLong(3, cliente.getRG());
        pStm.setLong(4, cliente.getCPF());
        pStm.setDate(5, cliente.getDataNascimento());

        try {
            pStm.executeUpdate(sql);
            status = true;
        } catch (SQLException e) {
            status = false;
            System.out.print("Erro ao executar Query!");
            e.printStackTrace();
        }

    }

    public void delete(Cliente cliente) throws SQLException, ClassNotFoundException {
        Connection conn = Conexao.getInstance();
        String sql = "DELETE FROM cliente WHERE cliente_id = ?;";
        PreparedStatement pStm = conn.prepareStatement(sql);
        pStm.setInt(1, cliente.getId());
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

    public Cliente findById(int id) throws SQLException, ClassNotFoundException {
        Connection conn = Conexao.getInstance();
        String sql = "SELECT * FROM cliente WHERE cliente_id = ?;";
        PreparedStatement pStm = conn.prepareStatement(sql);
        pStm.setInt(1, id);
        ResultSet rs = pStm.executeQuery();
        Cliente c = new Cliente();
        if (rs.next()) {
            c.setId(rs.getInt("cliente_id"));
            c.setNome(rs.getString("nome"));
            c.setFone(rs.getLong("fone"));
            c.setRG(rs.getLong("rg"));
            c.setCPF(rs.getLong("cpf"));
        } else {
            c = null;
        }
        pStm.close();
        return c;

    }

    public List<Cliente> findAll() throws SQLException, ClassNotFoundException {
        String sql = "SELECT * FROM cliente;";
        List<Cliente> lista = new ArrayList<Cliente>();
        Connection conn = Conexao.getInstance();
        Statement stm = conn.createStatement();
        ResultSet rs = stm.executeQuery(sql);
        while (rs.next()) {
            Cliente c = new Cliente();
            c.setId(rs.getInt("cliente_id"));
            c.setNome(rs.getString("nome"));
            c.setFone(rs.getLong("fone"));
            c.setRG(rs.getLong("rg"));
            c.setCPF(rs.getLong("cpf"));
            lista.add(c);
        }
        stm.close();
        return lista;
    }

    protected void finalize() throws Throwable {
        Conexao.closeConnection();
        super.finalize();
    }
}
