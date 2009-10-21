/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package rs;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.Socket;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URLConnection;
import java.net.UnknownHostException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author multi
 */
public class Html {

    private URI uri;

    public Html() {
    }

    public boolean modificaHost(String link) {
        try {
            uri = new URI(link);
            Socket socket;
            try {
                socket = new Socket(uri.getHost(), 80);
                link = "http://" + socket.getInetAddress().getHostAddress() + uri.getPath();
                uri = new URI(link);
                return true;
            } catch (UnknownHostException ex) {
                Logger.getLogger(Main.class.getName()).log(Level.SEVERE, null, ex);
            } catch (IOException ex) {
                Logger.getLogger(Main.class.getName()).log(Level.SEVERE, null, ex);
            }
        } catch (URISyntaxException ex) {
            Logger.getLogger(Main.class.getName()).log(Level.SEVERE, null, ex);
        }
        return false;
    }

//    public boolean enviar(byte[] dados) throws IOException {
//        OutputStream output = null;
//        HttpConnection http = null;
//        try {
//            http = (HttpConnection) Connector.open(this.getHttpUrl(), Connector.READ_WRITE);
//            http.setRequestMethod(HttpConnection.POST);
//            http.setRequestProperty("Connection", "close");
//            output = http.openOutputStream();
//
//            if (output != null) {
//                output.write(dados);
//                output.flush();
//            }
//            return ((http.getResponseCode() == HttpConnection.HTTP_OK));
//        } finally {
//            if (http != null) {
//                http.close();
//            }
//            if (output != null) {
//                output.close();
//            }
//        }
//    }

    public String getBody() {
        StringBuilder stream = new StringBuilder();
        try {
            URLConnection conexao = uri.toURL().openConnection();
            InputStream entrada = conexao.getInputStream();
            byte[] buffer = new byte[1024];
            while (entrada.read(buffer) != -1) {
                stream.append(new String(buffer));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return stream.toString();
    }

    public String getHost() {
        return uri.getHost();
    }

    public String getPath() {
        return uri.getPath();
    }

    public String getLink() {
        return "http://" + uri.getHost() + uri.getPath();
    }

    public void toFile() throws FileNotFoundException, IOException {
        File arq = new File("texto.html");
        FileOutputStream fos = new FileOutputStream(arq);
        fos.write(getBody().getBytes());
    }
}
