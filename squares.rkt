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
         "utils.rkt")

; Data structs
(struct point (x y))
(struct dim (w h))
(struct canvas (outside inside border))

; Take the dimensions and calculate a border 10% of dim and the internal draw space
(define (make-canvas width height)
  (let* ([border (* width .1)]
         [iw (->int (- width (* border 2)))]
         [ih (->int (- height (* border 2)))]
         [outside (dim width height)]
         [inside (dim iw ih)])
    (canvas outside inside border)))

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

;;;;;;;;;;;;;;;;;;;
; Shapes
;;;;;;;;;;;;;;;;;;;

; Solid circle
(define (even hue border cell i c)
  (let* ([pos (point (+ border (* (dim-w cell) i)) (+ border (* (dim-h cell) c)))]
         [offset (/ border 2)]
         [color (make-rgb hue "50%")])
    (square (dim-w cell) "solid" color)))

; Empty circle
(define (double hue border cell i c)
  (let* ([pos (point (+ border (* (dim-w cell) i)) (+ border (* (dim-h cell) c)))]
         [offset (/ border 2)]
         [color (make-rgb hue "50%" "80%")])
    (square (dim-w cell) "solid" color)))

; Dot
(define (odd hue border cell i c)
  (let* ([pos (point (+ border (* (dim-w cell) i)) (+ border (* (dim-h cell) c)))]
         [offset (/ border 2)]
         [color (make-rgb hue)])
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
  (let* ([canvas (make-canvas width height)]
         [color-range (reverse (build-color-range (reverse user)))]
         [points (chunk-mirror2 (take user 15) 3)]
         [cell (make-cell canvas 5)]
         [border (canvas-border canvas)]
         [count (range 0 (length points))]
         [base (square width "solid" "white")])
    (let ([circles (for/list ([row points]
                              [color-row color-range]
                              [i count])
                     (row->image (draw-rule row (first (first color-range)) i border cell)))])
      (overlay (rotate 180 (foldr (λ (r g) (above r g)) (first circles) (reverse (rest circles))))
                           base))))