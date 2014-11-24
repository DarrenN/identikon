#lang racket

(require quickcheck
         sugar
         "../utils.rkt")

; string-pairs length is equal to original string without spaces
(define string-pairs-length-agree
  (property ([str arbitrary-printable-ascii-string])
            (= (string-length (string-trim (string-replace str " " "")))
               (string-length (string-join (string-pairs str) "")))))

(quickcheck string-pairs-length-agree)

; string-pairs list contains items of length 2 or less
(define string-pairs-lengths-are-two
  (property ([str arbitrary-printable-ascii-string])
            (not (false? (foldl (λ (x y) (<= (string-length x) 2)) #t (string-pairs str))))))

(quickcheck string-pairs-lengths-are-two)

; chunk mirror returns lists with twice the length of the original
(define chunk-mirrors-length-doubled
  (property ([lst (arbitrary-list arbitrary-natural)]
             [num arbitrary-natural])
            (= (* 2 (length lst)) (length (flatten (chunk-mirror lst (+ 1 num)))))))

(quickcheck chunk-mirrors-length-doubled)

; chunk mirror returns list items that are mirrors, so if we split the item list
; in half both pieces should be equal when the 2nd half is reversed
(define chunk-mirrors-items-mirrored
  (property ([lst (arbitrary-list arbitrary-natural)]
             [num arbitrary-natural])
            (let ([cm (chunk-mirror lst (+ 1 num))])
              (not (false? (foldl (λ (x y)
                                    (let-values ([(f b) (split-at x (quotient (length x) 2))])
                                      (equal? f (reverse b)))) 
                                  #t 
                                  cm))))))

(quickcheck chunk-mirrors-items-mirrored)

; chunk mirror returns lists with lengths equal slice-at lst num + 1
(define chunk-mirrors-length-is-round
  (property ([lst (arbitrary-list arbitrary-natural)]
             [num arbitrary-natural])
            (let ([cm (chunk-mirror lst (+ 1 num))])
              (= (length cm) (length (slice-at lst (+ 1 num)))))))

(quickcheck chunk-mirrors-length-is-round)

; chunk dupe returns list items that dupes, so if we split the item list
; in half both pieces should be equal
(define chunk-dupe-items-mirrored
  (property ([lst (arbitrary-list arbitrary-natural)]
             [num arbitrary-natural])
            (let ([cm (chunk-dupe lst (+ 1 num))])
              (not (false? (foldl (λ (x y)
                                    (let-values ([(f b) (split-at x (quotient (length x) 2))])
                                      (equal? f b))) 
                                  #t 
                                  cm))))))

(quickcheck chunk-dupe-items-mirrored)