# Test the simple UDP client-server 'echo' timing in some Languages

## How

The "requestor.c" is client program which create UDP socket (AF\_INET, SOCK\_DGRAM),
than for particular server endpoint, 4 times per second, client sends wait and receive udp packet
in this way

npackets++ try:

    _t.start

    [requestor] -> (packet)-> [server-endpoint]
    ...
    [server-endpoint] ->(same packet echo answer) -> [requestor]

    _t.end

    t.acc += t.end-t.start

    t.try = t.acc / n


## Test environment

* All tests runs on the localhost
* $ uname -m -r
   - 6.8.0-64-generic x86_64
* Packet size 2048 bytes
   (fragmented by Linux kernel's net stack)
* All pairs requestor <> server* doing in parallel

## Results

| No | Environment     | Kind            | NPackets | t try     | src file           |
|----|-----------------|-----------------|----------|-----------|--------------------|
| 1. | GCC 13.3        | compiled prog   | 144000   | 0.000078s | srv.c              |
| 2. | CHICKEN 5.4.0   | compiled module | 137000   | 0.000124s | server-chicken.scm |
| 3. | Gambit 4.9.7    | compiled module | 137000   | 0.000118s | server-gambit.scm  |
| 4. | Guile 3.0.10    | interpreted     | 151000   | 0.000092s | server-guile.scm   |
| 5. | Racket 8.17[cs] | interpreted     | 151000   | 0.000332s | server-racket.scm  |
| 6. | Python 3.12.3   | interpreted     | 102000   | 0.000139s | server-python.py   |
|    |                 |                 |          |           |                    |


## Next

I'll try Rhombus, Java maybe something else

## Remark

UDP still in use today, fo example SNMP, NTP, RSyslog, and gazillion of proprietary [oneway] cast|multicast protocols.
