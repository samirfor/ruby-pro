package db;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class Conexao {

    private static Connection instance;
    private static String banco = "postgres";
    private static String host = "10.50.0.199";
    private static String porta = "5432";
    private static String user = "postgres";
    private static String passwd = "1234";
    private static String url = "jdbc:postgresql://" + host + ":" + porta + "/" + banco;

    private Conexao() {
    }

    public static Connection getInstance() throws SQLException, ClassNotFoundException {
        if (instance == null) {
            Class.forName("org.postgresql.Driver");
            instance = DriverManager.getConnection(url);
        }
        return instance;
    }

    public static void restartConnection() throws ClassNotFoundException, SQLException {
        instance = DriverManager.getConnection(url, user, passwd);
    }

    public static void closeConnection() throws SQLException {
        instance.close();
        instance = null;
    }
}
