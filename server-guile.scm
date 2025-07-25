#!
!#
(define-library (server-guile)
  (export test)
  (import (scheme base)
          (guile)
          (rnrs bytevectors gnu))

  (begin
    (define pack-size 2024)

    (define make-server
      (lambda (host port)
        (let* ((ht (car (getaddrinfo host)))
               (s (socket PF_INET SOCK_DGRAM 0))
               (saddr (make-socket-address
                       (addrinfo:fam ht)
                       (sockaddr:addr (addrinfo:addr ht))
                       port)))
          (bind s saddr)
          (format #t "bind sock on ~a:~a~%" (addrinfo:addr ht) port)
          s)))

    (define (srv s)
      (define pack (make-bytevector pack-size))
      (let loop ((i 0))
        (let* ((rc (recvfrom! s pack 0))
               (r (car rc))
               (from (cdr rc))
               (sl (sendto s (bytevector-slice pack 0 r) from)))
          (format #t "~a. recv ~a bytes. ack to ~a\r" i r
                  (inet-ntop (sockaddr:fam from)
                             (sockaddr:addr from)))
          (loop (+ 1 i)))))

    (define (test args)
      (let ((s #f))
        (dynamic-wind
            (lambda () (set! s (make-server "localhost" 4569)))
            (lambda () (srv s))
            (lambda () (shutdown s 2)))))
    ))


;; to run:
;; $ guile --r7rs -e '(@ (server-guile) test)' -s server-guile.scm
