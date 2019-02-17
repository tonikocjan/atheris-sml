#lang racket

(define (mul x)
  (lambda (y)
    (lambda (z)
      (* (* x y) z))))
mul
(define x (((mul 10) 20) 30))
x
