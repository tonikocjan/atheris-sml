#lang racket

(define x (list 2 3 4 5))
x
(define x1 (cond 
  [(empty? x) (let () 1)]
  [(> (length x) 2)  (let (
    [h1 (car x)]
    [h2 (car (cdr x))]
    [h3 (car (cdr (cdr x)))]
    [t (cdr (cdr (cdr x)))]) 2)]
  [(> (length x) 1)  (let (
    [h1 (car x)]
    [h2 (car (cdr x))]
    [t (cdr (cdr x))]) 3)]
  [(> (length x) 0)  (let (
    [h (car x)]
    [t (cdr x)]) 4)]
  ))
x1
