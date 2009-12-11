package dao;

public class FilmeDao {

    private static FilmeDao instance;

    private FilmeDao() {
    }

    public static FilmeDao getInstance() {
        if (instance == null) {
            instance = new FilmeDao();
        }
        return instance;
    }
}

