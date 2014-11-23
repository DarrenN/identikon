#lang racket

(require rackunit
         rackunit/text-ui
         "../utils.rkt")

(define utils-tests
  (test-suite
   "Tests for utils.rkt"
   
   ; String pairs
   (test-case
    "Convert a string into a list of string pairs"    
    (check-equal? (string-pairs "Apple") '("Ap" "pl" "e")  "Simple string pairs")
    (check-equal? (string-pairs "Apples") '("Ap" "pl" "es")  "Simple string pairs")
    (check-equal? (string-pairs "This is a lot of   bo  ther   ") 
                  '("Th" "is" "is" "al" "ot" "of" "bo" "th" "er")  
                  "Simple string pairs"))
   
   ; Double?
   (test-case 
    "Numbers are doubles, ex: 33, 66, 1212"    
    (check-pred double? 33 "Double number")
    (check-pred double? 66 "Double number")
    (check-pred double? 1212 "Double number")
    (check-pred double? 341341 "Double number")
    (check-false (double? 313) "Not a double number")
    (check-false (double? 111) "Not a double number")
    (check-false (double? 2) "Not a double number"))
  
   ; Chunk mirror
  (test-case
   "Chunk mirror creates new mirrored lists from a list"
   (check-equal? (chunk-mirror '(1 2 3 4 5 6) 3) '((1 2 3 3 2 1) (4 5 6 6 5 4)) "Split by 3")
   (check-equal? (chunk-mirror '(1 2 3 4 5 6) 2) '((1 2 2 1) (3 4 4 3) (5 6 6 5)) "Split by 2")
   (check-equal? (chunk-mirror '(1 2 3 4 5 6) 4) '((1 2 3 4 4 3 2 1) (5 6 6 5)) "Split by 4"))
  
  
  ))

(run-tests utils-tests)