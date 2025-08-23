(module server-chicken
    (test)

  (import scheme
          (chicken base)
          udp)

  (define pack-size 2024)

  (define make-server
    (lambda (host port)
      (let ((sock (udp-open-socket)))
        (udp-bind! sock host port)
        (print "Bind CHICKEN UDP on " host ":" port)
        sock)))


  (define srv
    (lambda (s)
      (let loop ((i 0) )
        (let-values (((r pack from from-port)
                      (udp-recvfrom s pack-size)))
          (udp-sendto s from from-port pack)
          (print* i ". recv " r " bytes. Ack\r"))
        (loop (+ 1 i)))))


  (define (test #!optional (host "localhost") (port 4568))
    (let ((s #f))
      (dynamic-wind
          (lambda () (set! s (make-server host port)))
          (lambda () (srv s))
          (lambda () (udp-close-socket s)))))

) ;; module end

;; to install dependencies
;; $ chicken-install udp

;; to compile:
;; $ csc -s -J -O3 server-chicken.scm

;; to run:
;; $ csi -R server-chicken -e "(test)"
