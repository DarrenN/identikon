#lang info
(define collection "identikon")
(define version "1.0.1")
(define scribblings '(("scribblings/identikon.scrbl" ())))
(define deps '("draw-lib"
               "gui-lib"
               "base"
               "sugar"
               "css-tools"
               "htdp-lib"
               "quickcheck"))
(define build-deps '("rackunit-lib"
                     "racket-doc"
                     "scribble-lib"))
(define raco-commands '(("identikon" (submod identikon main) "issue Identikon command" #f)))
