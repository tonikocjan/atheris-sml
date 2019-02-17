#lang racket

(define x (lambda (x)
  (lambda (y)
    (lambda (z)
      (z x y)))))
x
(define a (((x 20) 30) (lambda (x y)
  (+ x y))))
a
(define b (((x "abc") "efg") (lambda (x y)
  (string-append x y))))
b
(define c (((x 20) 30) (lambda (x y)
  (+ x y))))
c
(define d (((x "abc") "efg") (lambda (x y)
  (string-append x y))))
d
