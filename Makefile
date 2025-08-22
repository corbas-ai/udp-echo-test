P:=requestor
O:=requestor.o
CFLAGS = -Wall
SRV:=srv
JS:=ServerJava.class


all: $P $(SRV) $(JS)

$(SRV): srv.o
	gcc -o srv srv.o

$(JS): ServerJava.java
	javac ServerJava.java


.PHONY: clean


clean:
	rm -f requestor srv ServerJava.class
