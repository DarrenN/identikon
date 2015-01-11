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
(define BORDER-MAX 20)

; Create cell dimensions from inside canvas dim / divisor
(define (make-cell c divisor)
  (let* ([inside (canvas-inside c)]
         [cw (dim-w inside)]
         [ch (dim-h inside)])
    (dim (/ cw divisor) (/ ch divisor))))

; Partition list into lists of n elements
; example: (chunk-mirror 3 '(1 2 3 4 5 6)) returns
; '((1 2 3 2 1) (4 5 6 5 4))
(define (chunk-mirror2 xs n)
  (let ([chunked (slice-at xs n)])
    (map (λ (x)
           (flatten (cons x (reverse (take x 2))))) chunked)))

;;;;;;;;;;;;;;;;;;;
; Shapes
;;;;;;;;;;;;;;;;;;;

; Solid circle
(define (even hue border cell i c)
  (let* ([pos (point (+ border (* (dim-w cell) i)) (+ border (* (dim-h cell) c)))]
         [offset (/ border 2)]
         [color (make-rgb hue)])
    (overlay (circle (/ (dim-w cell) 2.5) "solid" color)
             (square (dim-w cell) "solid" "white"))))

; Empty circle
(define (double hue border cell i c)
  (let* ([pos (point (+ border (* (dim-w cell) i)) (+ border (* (dim-h cell) c)))]
         [offset (/ border 2)]
         [color (make-rgb hue)])
    (overlay (circle (/ (dim-w cell) 4) "solid" "white")
             (circle (/ (dim-w cell) 2.5) "solid" color)
             (square (dim-w cell) "solid" "white"))))

; Dot
(define (odd hue border cell i c)
  (let* ([pos (point (+ border (* (dim-w cell) i)) (+ border (* (dim-h cell) c)))]
         [offset (/ border 2)]
         [color (make-rgb hue)])
    (overlay (circle (/ (dim-w cell) 3.75) "solid" color)
             (square (dim-w cell) "solid" "white"))))

; Drawing a row of shapes
(define (draw-rule points hues c border cell)
  (let ([count (range 0 (length points))])
    (for/list ([p points]
               [hue hues]
               [i count])
      (cond [(double? p) (double hue border cell i c)]
            [(even? p) (even hue border cell i c)]
            [(odd? p) (odd hue border cell i c)]))))

; The main entry point for creating an identikon
(define (draw-rules width height user)
  (let* ([canvas (make-canvas width height BORDER-MAX)]
         [color-range (build-color-range user)]
         [points (chunk-mirror2 (drop user 5) 3)]
         [cell (make-cell canvas 5)]
         [border (canvas-border canvas)]
         [count (range 0 (length points))]
         [base (square width "solid" "white")])
    (let ([circles (for/list ([row points]
                              [color-row color-range]
                              [i count])
                     (row->image (draw-rule row color-row i border cell)))])
      (overlay (rotate 180 (foldr (λ (r g) (above r g)) (first circles) (reverse (rest circles))))
                           base))))
