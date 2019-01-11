#lang racket

(define x (cons true false))
x
(define y (cons (list 1 2) (list (cons true false) (cons true true))))
y
(define x1 (cond 
  [(equal? 1 1)
   (let () (cond 
    [(and 
      (equal? (car x) true)
      (equal? (cdr x) true)
      )
     (let () 1)]
    [(and 
      (equal? (car x) true)
      (equal? (cdr x) false)
      )
     (let () (cond 
      [(and 
        (not (empty? (car y)))
        (equal? (car (car y)) 1)
        (> (length (cdr y)) 1)
        (equal? (car (car (cdr y))) true)
        (equal? (cdr (car (cdr y))) false)
        (equal? (car (car (cdr (cdr y)))) true)
        (equal? (cdr (car (cdr (cdr y)))) true)
        (null? (cdr (cdr (cdr y))))
        )
       (let (
        [tl1 (cdr (car y))]
        ) 2)]
      [(and 
        (not (empty? (car y)))
        (equal? (car (car y)) 1)
        (> (length (cdr y)) 1)
        (equal? (car (car (cdr y))) true)
        (equal? (cdr (car (cdr y))) false)
        (equal? (car (car (cdr (cdr y)))) true)
        (equal? (cdr (car (cdr (cdr y)))) false)
        )
       (let (
        [tl1 (cdr (car y))]
        [tl2 (cdr (cdr (cdr y)))]
        ) 3)]
      ))]
    ))]
  [(equal? 1 2)
   (let () 4)]
  ))
x1
