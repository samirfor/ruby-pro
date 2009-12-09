package dao;

import java.sql.ResultSet;
import java.sql.Statement;

public class ClienteDAO {

    private boolean status;
    private Statement stm;
    private ResultSet rs;

    private ClienteDAO() {
        connect();
    }

    public static ClienteDAO getInstance() {
        if (instance == null) {
            instance = new ClienteDAO();
        }
        return instance;
    }

    public void insert(Cliente cliente) {
        String sql = "insert into clientes(nome) values('" + cliente.getNome() + "')";

        try {
            stm.executeUpdate(sql);
            status = true;
        } catch (SQLException e) {
            status = false;
            System.out.print("Erro ao executar Query!");
            e.printStackTrace();
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
            };


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
}
