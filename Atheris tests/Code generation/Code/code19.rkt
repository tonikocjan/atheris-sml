#lang racket

(define xs (list false false true))
xs
(define x1 (cond 
  [(and (> (length xs) 0) (equal? (car xs) true)) (let (
    [tl (cdr xs)]) 1)]
  [(and (> (length xs) 0) (equal? (car xs) false)) (let (
    [tl (cdr xs)]) 2)]
  ))
x1
(define xss (list (cons true (cons 20 true)) (cons true (cons 20 false)) (cons false (cons 30 false))))
xss
(define x2 (cond 
  [(and (> (length xss) 0) (equal? (car xss) (cons true (cons 20 true)))) (let (
    [tl (cdr xss)]) 1)]
  [(and (> (length xss) 0) (equal? (car xss) (cons false (cons 10 true)))) (let (
    [tl (cdr xss)]) 2)]
  [(and (> (length xss) 0) (equal? (car xss) (cons true (cons 12 true)))) (let (
    [tl (cdr xss)]) 3)]
  ))
x2
