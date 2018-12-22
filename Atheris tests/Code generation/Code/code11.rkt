#lang racket

(define x 10)
x
(define y false)
y
(struct X (_) #:transparent)
(struct Y (_) #:transparent)

(define z (cond 
  [(equal? (list x Y) (list 10 X)) true]
  [(equal? (list x Y) (list 10 Y)) false]
  ))
z
(define e (cond 
  [(equal? (list true (list true true)) (list true (list true true))) 0]
  [(equal? (list true (list true true)) (list true (list true false))) 1]
  [(equal? (list true (list true true)) (list true (list false true))) 2]
  [(equal? (list true (list true true)) (list true (list false false))) 3]
  [(equal? (list true (list true true)) (list false (list true true))) 4]
  [(equal? (list true (list true true)) (list false (list true false))) 5]
  [(equal? (list true (list true true)) (list false (list false true))) 6]
  [(equal? (list true (list true true)) (list false (list false false))) 7]
  ))
e
