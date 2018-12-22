#lang racket

(struct NEXT (x0) #:transparent)
(struct ZERO (_) #:transparent)

(define (toInt a)
  (cond 
    [(ZERO? a) 0]
    [(NEXT? a) (let ([i (NEXT-x0 a)]) (+ 1 (toInt i)))]
    ))
toInt
(define x (NEXT (ZERO 0)))
x
(define a (toInt x))
a
