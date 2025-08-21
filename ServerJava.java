import java.io.*;
import java.net.*;
import java.util.*;
import java.nio.channels.*;


public class ServerJava {
    static final int packSize = 4096;
    static final int IPTOS_LOWDELAY = 0x10;

    private static DatagramSocket makeServer(String host, int port)
        throws UnknownHostException, SocketException {

        InetAddress addr = InetAddress.getByName(host);
        DatagramSocket sock = new DatagramSocket(port, addr);
        sock.setTrafficClass(IPTOS_LOWDELAY);
        System.out.println("Server bind on" + host + ":" + port);
        return sock;
    }

    private static void srv(DatagramSocket sock) {
        byte[] dt = new byte [packSize];
        DatagramPacket pack = new DatagramPacket(dt, packSize);
        try{
            for(int i = 0;;++i) {
               sock.receive(pack);
               sock.send(pack);
               InetAddress source = pack.getAddress();
               System.out.print("" + i + ". recv+ack from " +
                                source + " \r" );
               System.out.flush();
            }
        }
        catch(Exception e){
            System.err.println("Потерял управление КП3, на имитаторе");
        }
    }

    public static void main(String[] args) {
        String addr = "localhost:4567";
        if (0 < args.length) {
            addr = args[0];
        }
        String[] addrport = addr.split(":");
        String host = addrport[0];
        try{
            int port = Integer.parseInt(addrport[1]);

            System.out.println("try " + host + ":" + port);
            DatagramSocket s = makeServer(host, port);
            srv(s);
        }catch(Exception e){
            System.err.println("Socket or something Error" + e);
        }

    }
}

/*

  compile:
  $ javac ServerJava.java

  run:
  $ java ServerJava "localhost:4555"

*/
