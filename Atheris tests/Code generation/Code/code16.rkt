#lang racket

(struct NODE (x0 x1 x2) #:transparent)
(struct LEAF (x0) #:transparent)

(define (min tree)
  (cond 
    [(LEAF? tree) (let ([x (LEAF-x0 tree)]) x)]
    [(NODE? tree) (let (
      [x (NODE-x0 tree)]
      [left (NODE-x1 tree)]
      [right (NODE-x2 tree)])
    (define l (min left))
    l
    (define r (min right))
    r
    (if (and (< x l) (< x r))
      x
      (if (< l r)
        l
        r)))]
    ))
min
(define big_tree (NODE 1 (NODE 2 (LEAF 5) (LEAF 7)) (NODE 10 (LEAF 10) (NODE 1 (NODE 100 (LEAF 10) (LEAF 100)) (LEAF 500)))))
big_tree
(define x1 (min (LEAF 10)))
x1
(define x2 (min big_tree))
x2
