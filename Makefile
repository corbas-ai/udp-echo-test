P:=requestor
O:=requestor.o
CFLAGS = -Wall
SRV:=srv



all: $P $(SRV)

$(SRV): srv.o
	gcc -o srv srv.o


.PHONY: clean


clean:
	rm -f requestor srv
