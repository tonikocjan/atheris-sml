#lang racket

(define (f x)
  (cond
    [(equal? true x) 1]
    [(equal? false x) 2]
    ))
f
(define x (f true))
x
(define y (f false))
y
