#lang racket

(struct Bus (int1))
(struct Avto (string1 string2 int1))
(struct Pes (_))

(define x (Bus 10))
x
(define y (Avto "abc" "efg" 10))
y
(define z (Pes 0))
z
(define a (cons x (list y z)))
a
