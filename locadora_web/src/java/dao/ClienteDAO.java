package dao;

import app.Cliente;
import db.Conexao;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class ClienteDAO {

    private boolean status;
    private static ClienteDAO instance;

    private ClienteDAO() {
    }

    public static ClienteDAO getInstance() {
        if (instance == null) {
            instance = new ClienteDAO();
        }
        return instance;
    }

    public void insert(Cliente cliente) throws SQLException, ClassNotFoundException {
        Connection conn = Conexao.getInstance();
        String sql;
        sql = "INSERT INTO cliente ";
        sql += "(cliente_id, nome, fone, rg, cpf, data_nasc) ";
        sql += "values(?,?,?,?,?,?)";
        PreparedStatement pStm = conn.prepareStatement(sql);
        pStm.setInt(1, cliente.getId());
        pStm.setString(2, cliente.getNome());
        pStm.setString(3, String.valueOf(cliente.getFone()));
        pStm.setString(4, String.valueOf(cliente.getRG()));
        pStm.setString(5, String.valueOf(cliente.getCPF()));
        pStm.setString(6, String.valueOf(cliente.getDataNascimento()));

        int qtd_insert = pStm.executeUpdate();
        pStm.close();

        if (qtd_insert < 1) {
            throw new NotInsertedClientException();
        }

    }

    public void update(Cliente cliente) {
        String sql = "update clientes set  nome = '" + cliente.getNome() + "'";
        sql += " where id = " + cliente.getId();

        try {
            stm.executeUpdate(sql);
            status = true;
        } catch (SQLException e) {
            status = false;
            System.out.print("Erro ao executar Query!");
            e.printStackTrace();
        }

    }

    public void delete(Cliente cliente) {

        String sql = "delete from clientes";
        sql += " where id = " + cliente.getId();

        try {
            stm.execute(sql);
            status = true;
        } catch (SQLException e) {
            status = false;
            System.out.print("Erro ao executar Query!");
            e.printStackTrace();
        }
    }

    public Cliente findById(int id) {
        String sql = "select * from clientes ";
        sql += " where id = " + id;
        Cliente cliente = null;
        try {
            rs = stm.executeQuery(sql);

            if (rs.next()) {
                cliente = fillBean(rs);
            }
            status = true;
        } catch (SQLException e) {
            status = false;
            System.out.print("Erro ao executar Query!");
            e.printStackTrace();
        }

        return cliente;
    }

    public List<Cliente> findAll() {
        String sql = "select * from clientes ";
        Cliente cliente = null;

        List<Cliente> lista = new ArrayList<Cliente>();
        try {
            rs = stm.executeQuery(sql);

            while (rs.next()) {
                cliente = fillBean(rs);
                lista.add(cliente);
            }
            ;


            status = true;
        } catch (SQLException e) {
            status = false;
            System.out.print("Erro ao executar Query!");
            e.printStackTrace();
        }

        return lista;
    }

    private ClienteDAO fillBean(ResultSet rs) {

        ClienteDAO cliente = null;

        try {
            cliente = new ClienteDAO();
            cliente.setId(Integer.parseInt(rs.getString("id")));
            cliente.setNome(rs.getString("nome"));
        } catch (SQLException e) {
            status = false;
            System.out.print("Erro ao executar Query!");
            e.printStackTrace();
        }

        return cliente;

    }

    public ResultSet connect() throws SQLException, ClassNotFoundException {
        Connection conn = Conexao.getInstance();
        stm = conn.createStatement();

        return this.rs;
    }
}
