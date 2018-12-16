#lang racket

(define x (list (cons "a" 10) (cons "b" "string") (cons "promise" (list (cons "evaled" false) (cons "f" (lambda (x)
  (* x x)))))))
x
(define a ((cdr (assoc "f" (cdr (assoc "promise" x)))) 10))
a
