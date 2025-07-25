import sys
import socketserver

class Echo(socketserver.BaseRequestHandler):
    icntr = 0

    def handle(self):
        data, sock_ = self.request
        sock_.sendto(data, self.client_address)
        print(f"{Echo.icntr}. recv {len(data)} from {self.client_address[0]}", end='\r')
        Echo.icntr += 1


if __name__ == "__main__":
    host = ("localhost", 7654)
    if len(sys.argv) > 1:
        host_,port_ = sys.argv[1].split(":")
        host = (host_, int(port_))
    with socketserver.UDPServer(host, Echo) as server:
        print(f"Python UDP bind on {host}")
        server.serve_forever()

# to run:
# $ python server-python.py
