#lang racket

(struct NEXT (x0) #:transparent)
(struct ZERO (_) #:transparent)

(define (sorted xs)
  (if (null? xs)
    true
    (if (null? (cdr xs))
      true
      (and (< (car xs) (car (cdr xs))) (sorted (cdr xs))))))
sorted
(define x1 (sorted null))
x1
(define x2 (sorted (list 1)))
x2
(define x3 (sorted (list 1 2 3)))
x3
(define x4 (sorted (list 2 1 3)))
x4
(define (zip xs ys)
  (if (or (null? xs) (null? ys))
    null
    (cons (cons (car xs) (car ys)) (zip (cdr xs) (cdr ys)))))
zip
(define x5 (zip (list 1 2 3) (list "a" "b" "c")))
x5
(define x6 (zip (list 1 2 3) (list "a" "b" "c" "d")))
x6
(define x7 (zip (list 1 2 3 4) (list "a" "b" "c")))
x7
(define (reverse xs)
  (define (reverse_ xs acc)
    (if (null? xs)
      acc
      (reverse_ (cdr xs) (cons (car xs) acc))))
  reverse_
  (reverse_ xs null))
reverse
(define x8 (reverse (list 1 2 3 4)))
x8
(define (toNatural a)
  (if (< a 0)
    (ZERO 0)
    (if (equal? a 0)
      (ZERO 0)
      (NEXT (toNatural (- a 1))))))
toNatural
(define x9 (toNatural 0))
x9
(define x10 (toNatural 1))
x10
(define x11 (toNatural 3))
x11
(define (isEven a)
  (define (toInt a)
    (cond 
      [(ZERO? a) 0]
      [(NEXT? a) (let ([b (NEXT-x0 a)]) (+ 1 (toInt b)))]
      ))
  toInt
  (equal? (modulo (toInt a) 2) 0))
isEven
(define x12 (isEven (toNatural 5)))
x12
(define x13 (isEven (toNatural 6)))
x13
(define x14 (isEven (toNatural 7)))
x14
(define x15 (isEven (toNatural 8)))
x15
(define (isOdd a)
  (not (isEven a)))
isOdd
(define x16 (isOdd (toNatural 5)))
x16
(define x17 (isOdd (toNatural 6)))
x17
(define x18 (isOdd (toNatural 7)))
x18
(define x19 (isOdd (toNatural 8)))
x19
(define (previous a)
  (cond 
    [(ZERO? a) ZERO]
    [(NEXT? a) (let ([prev (NEXT-x0 a)]) prev)]
    ))
previous
(define x20 (previous (toNatural 3)))
x20
(define x21 (previous (toNatural 2)))
x21
(define (subtract a b)
  (cond 
    [(ZERO? a) (cond 
      [(ZERO? b) ZERO]
      [(NEXT? b) (let ([w0 (NEXT-x0 b)]) ZERO)]
      )]
    [(NEXT? a) (let ([x (NEXT-x0 a)]) (cond 
      [(ZERO? b) a]
      [(NEXT? b) (let ([y (NEXT-x0 b)]) (subtract x y))]
      ))]
    ))
subtract
(define x22 (subtract (toNatural 5) (toNatural 3)))
x22
(define x23 (subtract (toNatural 5) (toNatural 4)))
x23
(define x24 (subtract (toNatural 3) (toNatural 3)))
x24
(define x25 (subtract (toNatural 0) (toNatural 0)))
x25
(define (any f xs)
  (if (null? xs)
    false
    (or (f (car xs)) (any f (cdr xs)))))
any
(define x26 (any (lambda (x)
  (< x 2)) (list 1 2 3 4 5)))
x26
(define x27 (any (lambda (x)
  (< x 2)) (list 3 4 5)))
x27
(define (all f xs)
  (if (null? xs)
    true
    (and (f (car xs)) (all f (cdr xs)))))
all
(define x28 (all (lambda (x)
  (< x 2)) (list 1 1 1 1 1)))
x28
(define x29 (all (lambda (x)
  (< x 2)) (list 1 2 3 4 5)))
x29
(define x30 (all (lambda (x)
  (< x 2)) (list 3 4 5)))
x30
