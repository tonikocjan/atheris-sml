#lang racket

(define x 10)
x
(define y false)
y
(struct X (_) #:transparent)
(struct Y (_) #:transparent)

(define z (cond 
  [(equal? (cons 10 X) (cons x Y)) (let () true)]
  [(equal? (cons 10 Y) (cons x Y)) (let () false)]
  ))
z
(define e (cond 
  [(equal? (cons true (cons true true)) (cons true (cons true true))) (let () 0)]
  [(equal? (cons true (cons true false)) (cons true (cons true true))) (let () 1)]
  [(equal? (cons true (cons false true)) (cons true (cons true true))) (let () 2)]
  [(equal? (cons true (cons false false)) (cons true (cons true true))) (let () 3)]
  [(equal? (cons false (cons true true)) (cons true (cons true true))) (let () 4)]
  [(equal? (cons false (cons true false)) (cons true (cons true true))) (let () 5)]
  [(equal? (cons false (cons false true)) (cons true (cons true true))) (let () 6)]
  [(equal? (cons false (cons false false)) (cons true (cons true true))) (let () 7)]
  ))
e
