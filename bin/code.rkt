#lang racket

(match-define-values x (values 10 20 30))
x
(match-define-values (a b c) (values 10 20 (+ 10 20)))
a b c
