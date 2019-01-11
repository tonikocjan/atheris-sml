#lang racket

(define y (cons (cons true (cons true (list 1 2 3))) true))
y
(define x1 (cond 
  [(and 
    (equal? (car (car y)) true)
    (equal? (car (cdr (car y))) true)
    (> (length (cdr (cdr (car y)))) 1)
    (equal? (car (cdr (cdr (car y)))) 1)
    (equal? (car (cdr (cdr (cdr (car y))))) 2)
    (null? (cdr (cdr (cdr (cdr (car y))))))
    (equal? (cdr y) true)
    )
   (let () 1)]
  [(and 
    (equal? (car (car y)) true)
    (equal? (car (cdr (car y))) true)
    (not (empty? (cdr (cdr (car y)))))
    (equal? (car (cdr (cdr (cdr (car y))))) 2)
    (equal? (cdr y) true)
    )
   (let (
    [hd (car (cdr (cdr (car y))))]
    [tl (cdr (cdr (cdr (cdr (car y)))))]
    ) 2)]
  [(and 
    (equal? (car (car y)) true)
    (equal? (car (cdr (car y))) true)
    (not (empty? (cdr (cdr (car y)))))
    (equal? (cdr y) true)
    )
   (let (
    [hd (car (cdr (cdr (car y))))]
    [tl (cdr (cdr (cdr (car y))))]
    ) 3)]
  [(and 
    (equal? (car (car y)) true)
    (equal? (car (cdr (car y))) false)
    (not (empty? (cdr (cdr (car y)))))
    (equal? (cdr y) false)
    )
   (let (
    [hd (car (cdr (cdr (car y))))]
    [tl (cdr (cdr (cdr (car y))))]
    ) 4)]
  ))
x1
