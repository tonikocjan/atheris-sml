#lang racket

(define x (list 2 3 4 5))
x
(define x1 (cond 
  [(null? x)
   (let () 1)]
  [(and 
    (> (length x) 2)
    (equal? (car x) 2)
    (equal? (car (cdr x)) 3)
    )
   (let (
    [h3 (car (cdr (cdr x)))]
    [t (cdr (cdr (cdr x)))]
    ) 2)]
  [(and 
    (not (empty? x))
    (equal? (car (cdr x)) 5)
    )
   (let (
    [h1 (car x)]
    [t (cdr (cdr x))]
    ) 3)]
  [(not (empty? x))
   (let (
    [h (car x)]
    [t (cdr x)]
    ) 4)]
  ))
x1
(define xs (list true true true false))
xs
(define x2 (cond 
  [(and 
    (> (length xs) 2)
    (equal? (car xs) true)
    (equal? (car (cdr xs)) true)
    (equal? (car (cdr (cdr xs))) true)
    (null? (cdr (cdr (cdr xs))))
    )
   (let () 1)]
  [(and 
    (> (length xs) 2)
    (equal? (car xs) true)
    (equal? (car (cdr xs)) true)
    (equal? (car (cdr (cdr xs))) true)
    )
   (let (
    [tl (cdr (cdr (cdr xs)))]
    ) 2)]
  [(and 
    (not (empty? xs))
    (equal? (car xs) false)
    )
   (let (
    [tl (cdr xs)]
    ) 3)]
  ))
x2
(define y (cons (cons true (cons true (list 1 2 3))) true))
y
(define x3 (cond 
  [(and 
    (equal? (car (car y)) true)
    (equal? (car (cdr (car y))) true)
    (not (empty? (cdr (cdr (car y)))))
    (equal? (car (cdr (cdr (car y)))) 4)
    (equal? (cdr y) true)
    )
   (let (
    [tl (cdr (cdr (cdr (car y))))]
    ) 1)]
  [(and 
    (equal? (car (car y)) true)
    (equal? (car (cdr (car y))) true)
    (> (length (cdr (cdr (car y)))) 1)
    (equal? (car (cdr (cdr (car y)))) 2)
    (equal? (car (cdr (cdr (cdr (car y))))) 2)
    (equal? (cdr y) true)
    )
   (let (
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
    (equal? (car (cdr (car y))) true)
    (not (empty? (cdr (cdr (car y)))))
    (equal? (car (cdr (cdr (cdr (car y))))) 10)
    (equal? (cdr y) false)
    )
   (let (
    [hd (car (cdr (cdr (car y))))]
    [tl (cdr (cdr (cdr (cdr (car y)))))]
    ) 4)]
  [(and 
    (equal? (car (car y)) true)
    (equal? (car (cdr (car y))) true)
    (not (empty? (cdr (cdr (car y)))))
    (equal? (cdr y) false)
    )
   (let (
    [hd (car (cdr (cdr (car y))))]
    [tl (cdr (cdr (cdr (car y))))]
    ) 5)]
  [(and 
    (equal? (car (car y)) true)
    (equal? (car (cdr (car y))) true)
    (not (empty? (cdr (cdr (car y)))))
    (equal? (cdr y) false)
    )
   (let (
    [hd (car (cdr (cdr (car y))))]
    [tl (cdr (cdr (cdr (car y))))]
    ) 6)]
  ))
x3
