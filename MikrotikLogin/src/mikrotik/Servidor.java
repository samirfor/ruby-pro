package mikrotik;

import java.net.InetAddress;

/**
 *
 * @author samir
 */
public class Servidor {

    private String host;
    private String ip;

    public Servidor(String host) {
        this.host = host;
    }

    public Servidor() {
    }

    public String getHost() {
        return host;
    }

    public void setHost(String host) {
        this.host = host;
    }

    public String getIp() {
        return ip;
    }

    public void setIp(String ip) {
        this.ip = ip;
    }

    public boolean isAlive() {
        try {
            if (InetAddress.getByName(host).isReachable(5000)) {
                return true;
            } else {
                return false;
            }
        } catch (Exception e) {
            return false;
        }
    }
}
