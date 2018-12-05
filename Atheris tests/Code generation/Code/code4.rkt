#lang racket

(define (a x y z)
  (string-append (string-append x y) z))
a
(define (b x y z)
  (string-append (string-append x y) "abc"))
b
(define (c x y z)
  (+ (+ x y) 10))
c
(define (d x y z)
  (or (and (and (> x 10) true) y) z))
d
(define (e x y z)
  (or (and (and (> x 10) true) y) z))
e
(define v (a "abc" "efg" "cdf"))
v
