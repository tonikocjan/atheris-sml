#lang racket

(define x (lambda (x)
  (lambda (y)
    (lambda (z)
      (z x y)))))
x
(define y (((x 20) 30) (lambda (x y)
  (+ x y))))
y
(define z (((x "abc") "efg") (lambda (x y)
  (string-append x y))))
z
