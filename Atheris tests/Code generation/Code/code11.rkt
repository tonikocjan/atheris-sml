#lang racket

(define e (cond 
  [(and 
    (equal? (car (cons true (cons true true))) true)
    (equal? (car (cdr (cons true (cons true true)))) true)
    (equal? (cdr (cdr (cons true (cons true true)))) true)
    )
   (let () 0)]
  [(and 
    (equal? (car (cons true (cons true true))) true)
    (equal? (car (cdr (cons true (cons true true)))) true)
    (equal? (cdr (cdr (cons true (cons true true)))) false)
    )
   (let () 1)]
  [(and 
    (equal? (car (cons true (cons true true))) true)
    (equal? (car (cdr (cons true (cons true true)))) false)
    (equal? (cdr (cdr (cons true (cons true true)))) true)
    )
   (let () 2)]
  [(and 
    (equal? (car (cons true (cons true true))) true)
    (equal? (car (cdr (cons true (cons true true)))) false)
    (equal? (cdr (cdr (cons true (cons true true)))) false)
    )
   (let () 3)]
  [(and 
    (equal? (car (cons true (cons true true))) false)
    (equal? (car (cdr (cons true (cons true true)))) true)
    (equal? (cdr (cdr (cons true (cons true true)))) true)
    )
   (let () 4)]
  [(and 
    (equal? (car (cons true (cons true true))) false)
    (equal? (car (cdr (cons true (cons true true)))) true)
    (equal? (cdr (cdr (cons true (cons true true)))) false)
    )
   (let () 5)]
  [(and 
    (equal? (car (cons true (cons true true))) false)
    (equal? (car (cdr (cons true (cons true true)))) false)
    (equal? (cdr (cdr (cons true (cons true true)))) true)
    )
   (let () 6)]
  [(and 
    (equal? (car (cons true (cons true true))) false)
    (equal? (car (cdr (cons true (cons true true)))) false)
    (equal? (cdr (cdr (cons true (cons true true)))) false)
    )
   (let () 7)]
  ))
e
