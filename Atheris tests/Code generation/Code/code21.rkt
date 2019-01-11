#lang racket

(define y (cons (cons true (cons true (list 1 2 3))) true))
y
(define x1 (cond 
  [(and 
    (equal? (car (car y)) true)
    (equal? (car (cdr (car y))) true)
    (> (length (cdr (cdr (car y)))) 0) 
    (equal? (cdr y) true)
    )
   (let (
    [hd (car (cdr (cdr (car y))))]
    [tl (cdr (cdr (cdr (car y))))]
    ) 1)]
  [(and 
    (equal? (car (car y)) true)
    (equal? (car (cdr (car y))) false)
    (> (length (cdr (cdr (car y)))) 0) 
    (equal? (cdr y) false)
    )
   (let (
    [hd (car (cdr (cdr (car y))))]
    [tl (cdr (cdr (cdr (car y))))]
    ) 2)]
  ))
x1
