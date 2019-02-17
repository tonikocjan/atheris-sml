#lang racket

(define x (+ 10 20))
x
(define y (/ 10.5 2.3))
y
(define z (and true (< 10 5)))
z
(define a (and (<= 5 10) (>= 2.5 3.2)))
a
(define b (or (and (and (and (equal? true true) (equal? 5 5)) (equal? "abc" "efg")) (< (* 5 5) 13)) (> (- 3.3 2.3) 0.0)))
b
(define c (string-append "123" "456"))
c
(define d (- 0 1))
d
(define e (modulo 5 2))
e
(define f (not true))
f
