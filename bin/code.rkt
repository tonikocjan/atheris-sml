#lang racket

(define (pow x y)
  (match-define-values (a b) (values 10 20))
  a b
  (if (equal? y 0) 1 (+ (pow x (- y 1)) a)))
pow
(define x (pow 3 3))
x
