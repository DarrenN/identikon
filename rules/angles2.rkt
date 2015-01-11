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

; Create cell dimensions from inside canvas dim / divisor
(define (make-cell c divisor)
  (let* ([inside (canvas-inside c)]
         [cw (dim-w inside)]
         [ch (dim-h inside)])
    (dim (->int (/ cw divisor)) (->int (/ ch divisor)))))

;;;;;;;;;;;;;;;;;;;
; Shapes
;;;;;;;;;;;;;;;;;;;

; Even
(define (even hue cell [bg-light "60%"])
  (let* ([color (make-rgb hue)])
    (overlay
     (right-triangle (dim-w cell) (dim-w cell) "solid" (make-rgb hue))
     (square (dim-w cell) "solid" (make-rgb hue "80%" bg-light)))))


; Drawing a row of shapes
(define (draw-rule points hues c border cell)
  (let ([count (range 0 (length points))])
    (for/list ([p (map (λ (x) (modulo x 4)) points)]
               [hue hues]
               [i count])
      (cond [(zero? p) (even hue cell "70%")]
            [(eq? p 1) (even hue cell "50%")]
            [(eq? p 2) (even hue cell "40%")]
            [(eq? p 3) (even hue cell "30%")]))))

; The main entry point for creating an identikon
(define (draw-rules width height user)
  (let* ([canvas (make-canvas width height)]
         [color-range (build-color-range user)]
         [points (slice-at (drop user 4) 4)]
         [cell (make-cell canvas 4)]
         [border (canvas-border canvas)]
         [count (range 0 (length points))]
         [base (square width "solid" "white")])
    (let ([circles (for/list ([row points]
                              [color-row color-range]
                              [i count])
                     (row->image (draw-rule row color-row i border cell)))])
      (overlay (rotate 180 (foldr (λ (r g) (above r g)) (first circles) (reverse (rest circles))))
               base))))
