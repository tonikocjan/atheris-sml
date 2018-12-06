#lang racket

(define (pow x y)
  (define (pow x y)
    (if (equal? y 0) 1 (* x (pow x (- y 1)))))
  pow
  (pow x y))
pow
(define x (pow 3 3))
x
