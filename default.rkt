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
         "utils.rkt")

; Data structs
(struct point (x y))
(struct dim (w h))
(struct canvas (outside inside border))

; Take the dimensions and calculate a border 10% of dim and the internal draw space
(define (make-canvas width height)
  (let* ([border (* width .04)]
         [iw (- width (* border 2))]
         [ih (- height (* border 2))]
         [outside (dim width height)]
         [inside (dim iw ih)])
    (canvas outside inside border)))

; Create cell dimensions from inside canvas dim / divisor
(define (make-cell c divisor)
  (let* ([inside (canvas-inside c)]
         [cw (dim-w inside)]
         [ch (dim-h inside)])
    (dim (/ cw divisor) (/ ch divisor))))

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
(define (draw-rules width height user filename)
  (let* ([canvas (make-canvas width height)]
         [color-range (build-color-range user)]
         [points (chunk-mirror (drop user 2) 3)]
         [cell (make-cell canvas 6)]
         [border (canvas-border canvas)]
         [count (range 0 (length points))]
         [base (square width "solid" "white")])
    (let ([circles (for/list ([row points]
                              [color-row color-range]
                              [i count])
                     (row->image (draw-rule row color-row i border cell)))])
      (save-image (overlay (rotate 180 (foldr (λ (r g) (above r g)) (first circles) (reverse (rest circles))))
                           base) filename))))