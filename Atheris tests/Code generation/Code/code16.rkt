#lang racket

(struct NEXT (x0) #:transparent)
(struct ZERO (_) #:transparent)

(define (toInt a)
  (cond 
    [(ZERO? a)
     (let () 0)]
    [(NEXT? a)
     (let ([i (NEXT-x0 a)]) (+ 1 (toInt i)))]
    ))
toInt
(define x1 (toInt (ZERO 0)))
x1
(define x2 (toInt (NEXT (ZERO 0))))
x2
(define x3 (toInt (NEXT (NEXT (ZERO 0)))))
x3
(define x4 (toInt (NEXT (NEXT (NEXT (NEXT (NEXT (ZERO 0))))))))
x4
(define (add a b)
  (cond 
    [(ZERO? b)
     (let () a)]
    [(NEXT? b)
     (let ([i (NEXT-x0 b)]) (add (NEXT a) i))]
    ))
add
(define two (NEXT (NEXT (ZERO 0))))
two
(define four (NEXT (NEXT (NEXT (NEXT (ZERO 0))))))
four
(define eight (NEXT (NEXT (NEXT (NEXT (NEXT (NEXT (NEXT (NEXT (ZERO 0))))))))))
eight
(define x5 (toInt (add two four)))
x5
(define x6 (toInt (add two eight)))
x6
(define x7 (toInt (add eight eight)))
x7
(define x8 (toInt (add (ZERO 0) (ZERO 0))))
x8
(define x9 (toInt (add (ZERO 0) two)))
x9
(struct NODE (x0 x1 x2) #:transparent)
(struct LEAF (x0) #:transparent)

(define (min tree)
  (cond 
    [(LEAF? tree)
     (let ([x (LEAF-x0 tree)]) x)]
    [(NODE? tree)
     (let (
      [x (NODE-x0 tree)]
      [left (NODE-x1 tree)]
      [right (NODE-x2 tree)]
    ) (define l (min left))
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
(define big_tree (NODE 1 (NODE 2 (LEAF 5) (LEAF 7)) (NODE 10 (LEAF (- 0 10)) (NODE 1 (NODE 100 (LEAF 10) (LEAF 100)) (LEAF 500)))))
big_tree
(define x10 (min (LEAF 10)))
x10
(define x11 (min big_tree))
x11
(define (max tree)
  (cond 
    [(LEAF? tree)
     (let ([x (LEAF-x0 tree)]) x)]
    [(NODE? tree)
     (let (
      [x (NODE-x0 tree)]
      [left (NODE-x1 tree)]
      [right (NODE-x2 tree)]
    ) (define l (max left))
    l
    (define r (max right))
    r
    (if (and (> x l) (> x r))
      x
      (if (> l r)
        l
        r)))]
    ))
max
(define x12 (max (LEAF 10)))
x12
(define x13 (max big_tree))
x13
(define (contains tree x)
  (cond 
    [(LEAF? tree)
     (let ([a (LEAF-x0 tree)]) (equal? a x))]
    [(NODE? tree)
     (let (
      [a (NODE-x0 tree)]
      [left (NODE-x1 tree)]
      [right (NODE-x2 tree)]
    ) (or (or (equal? a x) (contains left x)) (contains right x)))]
    ))
contains
(define x14 (contains big_tree 123))
x14
(define x15 (contains big_tree 0))
x15
(define x16 (contains big_tree 1))
x16
(define x17 (contains big_tree (- 0 10)))
x17
(define x18 (contains big_tree 500))
x18
(define (countLeaves tree)
  (cond 
    [(LEAF? tree)
     (let ([w0 (LEAF-x0 tree)]) 1)]
    [(NODE? tree)
     (let (
      [w1 (NODE-x0 tree)]
      [l (NODE-x1 tree)]
      [r (NODE-x2 tree)]
    ) (+ (countLeaves l) (countLeaves r)))]
    ))
countLeaves
(define x19 (countLeaves big_tree))
x19
(define (countBranches tree)
  (cond 
    [(LEAF? tree)
     (let ([w2 (LEAF-x0 tree)]) 0)]
    [(NODE? tree)
     (let (
      [w3 (NODE-x0 tree)]
      [l (NODE-x1 tree)]
      [r (NODE-x2 tree)]
    ) (+ (+ 1 (countBranches l)) (countBranches r)))]
    ))
countBranches
(define x20 (countBranches big_tree))
x20
(define (height tree)
  (cond 
    [(LEAF? tree)
     (let ([w4 (LEAF-x0 tree)]) 1)]
    [(NODE? tree)
     (let (
      [w5 (NODE-x0 tree)]
      [l (NODE-x1 tree)]
      [r (NODE-x2 tree)]
    ) (define left (+ 1 (height l)))
    left
    (define right (+ 1 (height r)))
    right
    (if (> left right)
      left
      right))]
    ))
height
(define x21 (height (LEAF 10)))
x21
(define x22 (height big_tree))
x22
(define (append_lst lst_a lst_b)
  (define (append lst a)
    (define (insert lst x n)
      (if (null? lst)
        (cons x null)
        (if (equal? n 0)
          (cons x lst)
          (cons (car lst) (insert (cdr lst) x (- n 1))))))
    insert
    (define (len lst)
      (if (null? lst)
        0
        (+ 1 (len (cdr lst)))))
    len
    (insert lst a (len lst)))
  append
  (if (null? lst_b)
    lst_a
    (append_lst (append lst_a (car lst_b)) (cdr lst_b))))
append_lst
(define x23 (append_lst (list 1) (list 4)))
x23
(define (toList tree)
  (cond 
    [(LEAF? tree)
     (let ([i (LEAF-x0 tree)]) (list i))]
    [(NODE? tree)
     (let (
      [i (NODE-x0 tree)]
      [l (NODE-x1 tree)]
      [r (NODE-x2 tree)]
    ) (append_lst (append_lst (toList l) (list i)) (toList r)))]
    ))
toList
(define x24 (toList big_tree))
x24
(define (isBalanced tree)
  (cond 
    [(LEAF? tree)
     (let ([w6 (LEAF-x0 tree)]) true)]
    [(NODE? tree)
     (let (
      [w7 (NODE-x0 tree)]
      [l (NODE-x1 tree)]
      [r (NODE-x2 tree)]
    ) (define height_diff (- (height l) (height r)))
    height_diff
    (and (<= height_diff 1) (>= height_diff (- 0 1))))]
    ))
isBalanced
(define x25 (isBalanced (LEAF 10)))
x25
(define x26 (isBalanced big_tree))
x26
(define x27 (isBalanced (NODE 0 (NODE 0 (LEAF 0) (LEAF 0)) (NODE 0 (LEAF 0) (LEAF 0)))))
x27
(define (isBST tree)
  (define (eval tree)
    (cond 
      [(LEAF? tree)
       (let ([x (LEAF-x0 tree)]) x)]
      [(NODE? tree)
       (let (
        [x (NODE-x0 tree)]
        [w8 (NODE-x1 tree)]
        [w9 (NODE-x2 tree)]
      ) x)]
      ))
  eval
  (cond 
    [(LEAF? tree)
     (let ([w10 (LEAF-x0 tree)]) true)]
    [(NODE? tree)
     (let (
      [x (NODE-x0 tree)]
      [l (NODE-x1 tree)]
      [r (NODE-x2 tree)]
    ) (define left (eval l))
    left
    (define right (eval r))
    right
    (and (and (and (> x left) (< x right)) (isBST l)) (isBST r)))]
    ))
isBST
(define bst (NODE 20 (NODE 10 (NODE 5 (LEAF 2) (NODE 7 (LEAF 6) (LEAF 8))) (NODE 15 (LEAF 12) (LEAF 17))) (NODE 22 (LEAF 18) (LEAF 25))))
bst
(define x28 (isBST (LEAF 10)))
x28
(define x29 (isBST big_tree))
x29
(define x30 (isBST bst))
x30
