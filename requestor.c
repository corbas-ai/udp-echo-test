#include <stdio.h>

#include <string.h>
#include <stdlib.h>
#include <memory.h>
#include <error.h>
#include <errno.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <time.h>
#include <sys/epoll.h>

const char default_target[] = "localhost:4567";
int pack_size = 2024;

#define PAYLOAD "the quick brown fox jumps over the lazy dog.\n"

int
main(int argc, char** argv)
{
  const char* target = default_target;
  char pack[pack_size];
  bzero(pack, pack_size);
  strncpy(pack, PAYLOAD, pack_size);

  if (argc > 1){
    target = argv[1];
  }
  char* pdelim = strchr(target,':');
  char* host = NULL;
  int port = -1;
  if (pdelim){
    host = strndup(target, pdelim - target);
    port = atol(pdelim+1);
  } else {
    host = strdup(target);
    port = 4567;
  }
  printf("%s target endpoint %s:%d\n", argv[0], host, port);
  struct hostent* hent = gethostbyname(host);
  if (hent == NULL) {
    error(1, errno, "can not resolve %s host\n", host);
  }
  struct in_addr** addr_list = (struct in_addr**) hent->h_addr_list;
  struct in_addr* addr = NULL;
  for (int i = 0; addr_list[i] != NULL; i++){
    printf("\t find endpoint[%d] is %s\n", i, inet_ntoa(*addr_list[i]));
    if (addr == NULL){
      addr = addr_list[i];
      break;
    }
  }
  if (addr == NULL){
    error(2,0,"not find addr of target %s\n", host);
  }
  int sock = socket(AF_INET, SOCK_DGRAM|SOCK_CLOEXEC, 0);
  if (sock == -1){
    error(3, errno, "can not create socket");
  }
  struct sockaddr_in saddr = {
    .sin_family = AF_INET,
    .sin_addr = *addr,
    .sin_port = htons(port),
  };
  double acc_tm = 0.0;
  for (int nt = 1 ;; nt++){
    struct timespec ts,te;
    printf("%d. \tSend...", nt);
    clock_gettime(CLOCK_MONOTONIC, &ts);
    int s = sendto(sock, pack, pack_size,  MSG_DONTWAIT, (struct sockaddr*)&saddr,
                   sizeof(saddr));

    if (s == -1) {
      if(errno == EAGAIN) {
        printf("%d.EAGAIN\n",nt);
        continue;
      }
      error(4, errno, "%d. Send error.", nt);
    }
    char recv_buff[pack_size];
    struct sockaddr_in from;
    socklen_t from_len;
    int r = recvfrom(sock, recv_buff, pack_size, 0,
                     (struct sockaddr*)&from, &from_len);
    clock_gettime(CLOCK_MONOTONIC, &te);
    if (r != s) {
      error(5, errno, "%d. recv error send %d bytes recv %d", nt, s, r);
    } else {
      double tm = (te.tv_sec+te.tv_nsec*1e-9)- (ts.tv_sec+1e-9*ts.tv_nsec);
      acc_tm += tm;
      int cmp = memcmp(pack,recv_buff,r);
      printf(" send %d and recv %d bytes eq? %s , per %0.6f secs [accumulated %0.6f]\r", s, r,
             cmp==0? "EQ": "NOT!", tm, acc_tm / nt);
      fflush(stdout);
    }
    struct timespec sleep_time = {.tv_sec = 0, .tv_nsec = 250e6l};
    nanosleep(&sleep_time, NULL);
  }

  free(host);
  return 0;
}
