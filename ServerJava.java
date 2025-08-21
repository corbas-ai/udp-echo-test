import java.io.*;
import java.net.*;
import java.util.*;
import java.nio.channels.*;


public class ServerJava {
    public static int packSize = 4096;
    private static DatagramChannel makeServer(String host, int port) throws UnknownHostException, SocketException {
        InetAddress addr = InetAddress.getByName(host);
        DatagramChannel sock = new DatagramChannel(port);
        return sock;
    }

    private static void srv(DatagramChannel sock) {
        byte[] dt = new byte [packSize];
        DatagramPacket pack = new DatagramPacket(dt, packSize);
        Selector sel = new Selector.open();
        sel.register(sock, SelectionKey.OP_READ);
        try{
            for(int i = 0;;++i) {
               sock.receive(pack);
               InetAddress source = pack.getAddress();
               sock.send(pack);
               System.out.print("" + i + ". recv+ack\r");
               System.out.flush();
            }
        }
        catch(Exception e){
            System.err.println("Потерял управление КП3, на имитаторе");
        }
    }

    public static void main(String[] args) {
        String addr = "localhost:7688";
        if (0 < args.length) {
            addr = args[0];
        }
        String[] addrport = addr.split(":");
        String host = addrport[0];
        int port = Integer.parseInt(addrport[1]);
        try{
            System.out.println("try " + host + ":" + port);
            DatagramChannel s = makeServer(host, port);
            srv(s);
            System.out.println("Server bind on" + host + ":" + port);
        }catch(Exception e){
            System.err.println("Socket or something Error");
        }

    }
}

/*

  compile:
  $ javac ServerJava.java

  run:
  $ java ServerJava "localhost:4555"

*/
