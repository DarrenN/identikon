#lang racket/base

; Default rule-set for identikon.
; All rule-sets must provide a single function, draw-rules
; which is called by identikon. This function should always
; take the following arguments: width height user filename

(provide draw-rules)

; ———————————
; implementation

(require racket/list
         2htdp/image
         sugar
         identikon/utils)

; Constants
(define PERCENT-DIVISOR 2.55)
(define MIN-SATURATION 30)
(define MAX-SATURATION 80)
(define MIN-LIGHTNESS 50)
(define MAX-LIGHTNESS 80)
(define BORDER-MAX 30)

; Create cell dimensions from inside canvas dim / divisor
(define (make-cell c divisor)
  (let* ([inside (canvas-inside c)]
         [cw (->int (dim-w inside))]
         [ch (->int (dim-h inside))])
    (dim (->int (/ cw divisor)) (->int (/ ch divisor)))))

; Partition list into lists of n elements
; example: (chunk-mirror 3 '(1 2 3 4 5 6)) returns
; '((1 2 3 2 1) (4 5 6 5 4))
(define (chunk-mirror2 xs n)
  (let ([chunked (slice-at xs n)])
    (map (λ (x)
           (flatten (cons x (reverse (take x 2))))) chunked)))

; Keep a number with a range of floor and ceiling
(define (constrain-number n floor ceiling)
  (cond
    [(and (<= n ceiling) (>= n floor)) n]
    [(< n floor) floor]
    [(> n ceiling) ceiling]))

; Use last three numbers from user list to generate an rgb color, keeping
; the saturation and lightness within constraints
(define (build-color user)
  (let* ([hue (last user)]
         [sat (->int (/ (last (take user (- (length user) 1))) PERCENT-DIVISOR))]
         [lig (->int (/ (last (take user (- (length user) 2))) PERCENT-DIVISOR))]
         [ssat (format "~a%" (constrain-number sat MIN-SATURATION MAX-SATURATION))]
         [slig (format "~a%" (constrain-number lig MIN-LIGHTNESS MAX-LIGHTNESS))])
    (make-rgb hue ssat slig)))

;;;;;;;;;;;;;;;;;;;
; Shapes
;;;;;;;;;;;;;;;;;;;

; even = solid square
(define (even color border cell i c)
  (let* ([pos (point (+ border (* (dim-w cell) i)) (+ border (* (dim-h cell) c)))]
         [offset (/ border 2)])
    (square (dim-w cell) "solid" color)))

; odd = white square
(define (odd color border cell i c)
  (let* ([pos (point (+ border (* (dim-w cell) i)) (+ border (* (dim-h cell) c)))]
         [offset (/ border 2)])
    (square (dim-w cell) "solid" "white")))

; Drawing a row of shapes
(define (draw-rule points hue c border cell)
  (let ([count (range 0 (length points))])
    (for/list ([p points]
               [i count])
      (cond [(even? p) (even hue border cell i c)]
            [(odd? p) (odd hue border cell i c)]))))

; The main entry point for creating an identikon
(define (draw-rules width height user)
  (let* ([canvas (make-canvas width height BORDER-MAX)]
         [color (build-color user)]
         [points (chunk-mirror2 (take user 15) 3)]
         [cell (make-cell canvas 5)]
         [border (canvas-border canvas)]
         [count (range 0 (length points))]
         [base (square width "solid" "white")])
    (let ([squares (for/list ([row points]
                              [i count])
                     (row->image (draw-rule row color i border cell)))])
      (overlay (rotate 180 (foldr (λ (r g) (above r g)) (first squares) (reverse (rest squares))))
                           base))))
