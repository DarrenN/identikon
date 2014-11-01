#lang racket/base
(require racket/list
         2htdp/image 
         css-tools/colors
         sugar)

(provide build-color-range
         make-rgb
         double?
         row->image
         chunk-mirror)

; Grab the first 4 numbers from the user list and use them to generate a list of 
; color values for points in the indentikon
(define (build-color-range user)
  (define color-a (first (take user 2)))
  (define color-b (if (< 100 (second (take user 2)))
                      (/ (second (take user 2)) 2)
                      (second (take user 2))))
  (slice-at (if (> color-a color-b)
                (range color-b 
                       color-a 
                       (/ (- color-a color-b) (* (length (drop user 2)) 2)))
                (range color-a 
                       color-b 
                       (/ (- color-b color-a) (* (length (drop user 2)) 2)))) 6))

; Turn a hue into an RGB color object
(define (make-rgb hue [sat "60%"] [lig "50%"])
  (define rgb (map (λ (x) (->int (* 255 x))) 
                   (hsl->rgb (list (number->string (* 1.411 hue)) sat lig))))
  (make-color (first rgb) (second rgb) (third rgb)))

; Is a number a double? ex: 33, 66
(define (double? x)
  (let ([nums (string->list (number->string x))])
    (eq? (first nums) (last nums))))

; Drop images in a list next to one another 
(define (row->image row)
  (cond
    [(empty? row) empty-image]
    [else         (beside (first row) 
                          (row->image (rest row)))]))

; Partition list into lists of n elements
; example: (chunk-mirror 3 '(1 2 3 4 5 6)) returns
; '((1 2 3 3 2 1) (4 5 6 6 5 4))
(define (chunk-mirror xs n)
  (let ([chunked (slice-at xs n)])
    (map (λ (x)
           (flatten (cons x (reverse x)))) chunked)))