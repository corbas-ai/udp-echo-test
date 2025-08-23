#!/usr/bin/env gosh

(use gauche.net)
(use gauche.uvector)

(define (make-server addr)
  (let ((s (make-socket PF_INET SOCK_DGRAM)))
    (cond ((string? addr)
           (let* ((sn (string-split addr ":"))
                  (host (car sn))
                  (port (if (< 1 (length sn)) (string->number (cadr sn)) 4556))
                  (he (sys-gethostbyname host))
                  (a0 (car (slot-ref he 'addresses)))
                  (addr (make <sockaddr-in> :host a0 :port port)))
             (socket-bind s addr)))
          (else (socket-bind s addr)))
    (print "Start Gauche UDP server on " addr)
    s))


(define (srv s)
  (let ((pack (make-bytevector 4096))
        (laddrs (list (socket-getsockname s))))
    (let loop ((i 0))
      (let*-values (((r addr) (socket-recvfrom! s pack laddrs))
                    ((s) (socket-sendto s (bytevector-copy pack 0 r) addr )))
        (format #t "~a. ack to ~a  ~a bytes \r" i addr s)
        (flush)
        (loop (+ 1 i))))))


(define (test arg)
  (let ((s #f))
    (dynamic-wind
        (lambda () (set! s (make-server arg)))
        (lambda () (srv s))
        (lambda () (socket-close s)))))


(define (main args)
  (let ((hostaddr (cond ((null? (cdr args)) "localhost:4577")
                        (else (cadr args)))))
    (test hostaddr)))


;; mkscript
;; $ chmod +x server-gauche.scm
;;
;; run
;; $ ./server-gauche.scm localhost:4566

