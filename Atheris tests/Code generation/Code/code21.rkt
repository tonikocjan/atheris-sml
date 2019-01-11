#lang racket

(define y (cons (cons false (cons true (list 1 2 3))) false))
y
(define x1 (cond 
  [(and 
    (equal? (car (car y)) true)
    (equal? (car (cdr (car y))) true)
    (> (length y) 0) 
    (equal? (car (cdr y)) true)
    )
   (let (
    [hd (car (car (cdr (cdr (car y)))))]
    [tl (cdr (car (cdr (cdr (car y)))))]
    ) 1)]
  [(and 
    (equal? (car (car y)) true)
    (equal? (car (cdr (car y))) false)
    (> (length y) 0) 
    (equal? (car (cdr y)) false)
    )
   (let (
    [hd (car (car (cdr (cdr (car y)))))]
    [tl (cdr (car (cdr (cdr (car y)))))]
    ) 2)]
  ))
x1
