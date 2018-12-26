#lang racket

(struct X (_) #:transparent)
(struct Y (_) #:transparent)

(define (f x)
  (cond
    [(X? x) 1]
    [(Y? x) 2]
    ))
f
(define x (f (X 0)))
x
(define y (f (Y 0)))
y
