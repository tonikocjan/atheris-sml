#lang racket

(define x1 (cond 
  [(equal? 3 1)
   (let () "a")]
  [(equal? 3 2)
   (let () "b")]
  [(equal? 3 3)
   (let () "c")]
  ))
x1
