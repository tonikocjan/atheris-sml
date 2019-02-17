#lang racket

(struct Bus (x0) #:transparent)
(struct Avto (x0 x1 x2) #:transparent)
(struct Pes (_) #:transparent)

(define x (Bus 10))
x
(define y (Avto "abc" "efg" 10))
y
(define z (Pes 0))
z
(define a (cons x (list y z)))
a
