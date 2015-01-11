#lang info
(define collection "identikon")
(define version "0.2")
(define scribblings '(("scribblings/identikon.scrbl" ())))
(define deps '("base"
               "sugar"
               "css-tools"
               "quickcheck"))
(define build-deps '("scribble-lib"))
(define raco-commands '(("identikon" (submod identikon main) "issue Identikon command" #f)))
