#lang racket

(provide test)

(define pack-size 2024)

(define (make-server host port)
  (let ((s (udp-open-socket)))
    (udp-bind! s host port)
    (printf "Bind Racket UDP on ~a:~a~%" host port)
    s))


(define (srv s)
  (define pack (make-bytes pack-size))
  (let loop ((i 0))
    (let*-values ([(r from from-port) (udp-receive! s pack)]
                  [(sd) (udp-send-to* s from from-port pack 0 r)])
      (when sd
        (printf "~a. receive ~a bytes from ~a:~a. ack.  \r"
                i r from from-port))
      (loop (+ 1 i)))))


(define (test)
  (let ((s #f))
    (dynamic-wind
      (lambda () (set! s (make-server "localhost" 4568)))
      (lambda () (srv s))
      (lambda () (udp-close s)))))


(module* main #f
  (test))
;; to run:
;; $ racket -t server-racket.rkt
