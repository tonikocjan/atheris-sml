#lang racket

(struct X (_) #:transparent)
(struct Y (_) #:transparent)

(define (f x)
  (cond
    [(equal? (list X true) x) 1]
    [(equal? (list X false) x) 2]
    [(equal? (list Y true) x) 3]
    [(equal? (list Y false) x) 4]
    ))
f
(define a (f (list X true)))
a
(define b (f (list X false)))
b
(define c (f (list Y true)))
c
(define d (f (list Y false)))
d
