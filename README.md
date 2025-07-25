# Test simple UDP client-server timings in some Languages

## How

"requestor.c" is client C-program, create UDP socket (AF\_INET, SOCK\_DGRAM),
than for server endpoint, 4 times per second, it sends, wait and receive udp packet

npackets++ try:

    _t.start

    [requestor] -> (packet)-> [server-endpoint]
    ...
    [server-endpoint] ->(same packet echo answer) -> [requestor]

    _t.end

    t.acc += t.end-t.start

    t.try = t.acc / n


## Results

* All tests on the localhost
* $ uname -m -r
   - 6.8.0-64-generic x86_64
* Pack size 2048 bytes
   (fragmented by Linux kernel net stack)

| No | Environment     | Kind            | NPackets | t try     | src file           |
|----|-----------------|-----------------|----------|-----------|--------------------|
| 1. | GCC 13.3        | compiled prog   | 144000   | 0.000078s | srv.c              |
| 2. | CHICKEN 5.4.0   | compiled module | 137000   | 0.000124s | server-chicken.scm |
| 3. | Gambit 4.9.7    | compiled module | 137000   | 0.000118s | server-gambit.scm  |
| 4. | Guile 3.0.10    | interpreted     | 151000   | 0.000092s | server-guile.scm   |
| 5. | Racket 8.17[cs] | interpreted     | 151000   | 0.000332s | server-racket.scm  |
| 6. | Python 3.12.3   | interpreted     | 102000   | 0.000139s | server-python.py   |
|    |                 |                 |          |           |                    |
