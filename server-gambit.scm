(define pack-size 4096)

(define (make-server host port)
  (open-udp `(local-address: ,host local-port-number: ,port)))


(define (srv s)
  (let loop ((i 0) (pack (make-u8vector pack-size 0)))
    (let* ((r (udp-read-subu8vector pack 0 pack-size s))
           (from-info (udp-source-socket-info s)))
      (when from-info
        (udp-destination-set! (socket-info-address from-info)
                              (socket-info-port-number from-info)
                              s)
        (udp-write-subu8vector pack 0 r s)
        (print i ".req " r " bytes pack from " from-info " reply\r"))
      (loop (+ 1 i) pack))))


(define (test)
  (let ((s (make-server "localhost" 4565)))
    (print "Gambit UDP on localhost:4565\n")
    (srv s)))


;; to compile:
;; $ gsc -dynamic server-gambit.scm

;; to run:
;; $ gsi . server-gambit -e "(test)"
