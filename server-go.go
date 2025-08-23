package main

import (
	"os"
	"net"
	"fmt"
)

func makeServer(addr string) (*net.UDPConn, error) {
	udpAddr, err := net.ResolveUDPAddr("udp", addr)
	if err != nil {
		return nil, err
	}
	conn, err := net.ListenUDP("udp", udpAddr)
	if err == nil {
		fmt.Printf("Bind Go UDP on %v\n", addr)
	}
	return conn, err
}

func srv(s *net.UDPConn) {

	var pack [4096]byte
	for {
		r, addr, err := s.ReadFromUDP(pack[0:])
		if err != nil {
			fmt.Println(err)
		}
		w, err := s.WriteToUDP(pack[0:r], addr)
		if err != nil {
			fmt.Println(err)
		}
		fmt.Printf("Ack to %v %d bytes\r", addr, w)
	}
}


func main() {
	host := "localhost:4562"
	if len(os.Args) > 1 {
		host = os.Args[1]
	}

	s, err := makeServer(host)

	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}

	srv(s)
}
