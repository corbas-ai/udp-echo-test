#include <stdio.h>
#include <error.h>
#include <errno.h>
#include <string.h>
#include <stdlib.h>

#include <sys/socket.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <netdb.h>

const char default_host[] = "localhost";
int default_port = 4568;

int
make_server(struct in_addr* paddr, int port)
{
  int sock = socket(AF_INET, SOCK_DGRAM, 0);
  struct sockaddr_in saddr = {
    .sin_family = AF_INET,
    .sin_addr = *paddr,
    .sin_port = htons(port)
  };

  if (bind (sock, (struct sockaddr*) &saddr, sizeof(saddr)) == -1){
    error(1, errno, "Cant bind %s:%d", inet_ntoa(*paddr), port);
  }else{
    printf("Bind C UDP on %s:%d\n", inet_ntoa(*paddr), port);
  }
  return sock;
}

void
srv(int sock){
  int pack_size = 4096;
  char pack[pack_size];
  for(int i = 0;;i++){
    struct sockaddr_in saddr;
    socklen_t saddr_len = sizeof(saddr);
    int r = recvfrom(sock, pack, pack_size, 0,
                     (struct sockaddr*)&saddr, &saddr_len);
    int s = sendto(sock, pack, r, MSG_DONTWAIT,
                   (struct sockaddr*)&saddr, saddr_len);
    printf("%d.recv %d bytes, ack %d\r", i, r, s);
    fflush(stdout);
  }
}

int
main(int argc, char** argv)
{
  const char* _host = default_host;
  int port = default_port;
  if (argc > 1) {
    _host = argv[1];
  }
  char* pos = strchr(_host, ':');
  char* host = NULL;
  if (pos != NULL) {
    port = atoi(pos+1);
    host = strndup(_host, pos - _host);
  }else{
    host = strdup(_host);
  }
  struct hostent* hent = gethostbyname(host);
  if(hent == NULL){
    error(1,errno, "Unresolved %s\n", host);
  }

  if (hent->h_addr_list[0] == NULL){
    error(2,0,"Zero addr of %s\n", host);
  }

  struct in_addr* addr = (struct in_addr*) hent->h_addr_list[0];
  int s = make_server(addr, port);

  srv(s);

  free(host);
  return 0;
}
