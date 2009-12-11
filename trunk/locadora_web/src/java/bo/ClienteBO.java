package bo;

import app.Cliente;
import dao.ClienteDAO;
import db.Conexao;
import excecao.IdNotFilledException;
import excecao.NameNotFilledException;
import java.sql.SQLException;
import java.util.List;
import sun.reflect.generics.reflectiveObjects.NotImplementedException;

public class ClienteBO {

    private static ClienteBO instance;

    public static ClienteBO getInstance() {
        if (instance == null) {
            instance = new ClienteBO();
        }
        return instance;
    }

    private ClienteBO() {
    }

    public void insert(Cliente cliente) throws ClassNotFoundException,
            SQLException, NotImplementedException, NameNotFilledException,
            IdNotFilledException {
        
        // realizar alguma validação
        if (cliente.getId() == -1) {
            throw new IdNotFilledException();
        }

        if (cliente.getNome() == null || cliente.getNome().equals("")) {
            throw new NameNotFilledException();
        }

        ClienteDAO.getInstance().insert(cliente);

    }

    public void update(Cliente cliente) throws ClassNotFoundException,SQLException {
    }

    public void delete(Cliente cliente) throws ClassNotFoundException, SQLException {
    }

    public List<Cliente> findAll() throws ClassNotFoundException, SQLException {
        return null;
    }

    public Cliente findById(int id) throws ClassNotFoundException, SQLException {

        return null;
    }

    @Override
    protected void finalize() throws Throwable {
        Conexao.closeConnection();
        super.finalize();
    }
}
