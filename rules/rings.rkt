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
         identikon/utils)

; Return a list of sizes in radius for use in circles
(define (make-sizes canvas user)
  (let* ([size (dim-w (canvas-inside canvas))]
         [step (/ size (length user))])
    (map (λ (x) (/ x 2)) (range 5 size step))))

;;;;;;;;;;;;;;;;;;;
; Shapes
;;;;;;;;;;;;;;;;;;;

; Drawing a row of shapes
(define (draw-rule digit radius border)
  (cond
    [(double? digit) (circle radius "solid" "white")]
    [(even? digit) (circle radius "solid" (make-rgb digit))]
    [(odd? digit) (circle radius "solid" (make-rgb digit "60%" "90%"))]))

; The main entry point for creating an identikon
; take 20 digits of user and create a new list of hues based on them
; create a list of 20 sizes (inner size / 20)
; iterate list and draw a circle of hue size for each

(define (draw-rules width height user)
  (let* ([canvas (make-canvas width height)]
         [sizes (make-sizes canvas user)]
         [border (canvas-border canvas)]
         [base (square width "solid" (make-rgb (first user) "100%" "90%"))])
    (let ([circles (for/list ([digit user]
                              [size sizes])
                     (draw-rule digit size border))])
      (overlay (foldr (λ (r g) (overlay r g)) (first circles) (rest circles))
                           base))))
