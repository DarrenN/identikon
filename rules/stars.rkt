#lang racket/base

; Default rule-set for identikon.
; All rule-sets must provide a single function, draw-rules
; which is called by identikon. This function should always
; take the following arguments: width height user filename

(provide draw-rules)

; ———————————
; implementation

(require racket/list
         racket/string
         2htdp/image
         sugar
         identikon/utils)

; Return a list of sizes in radius for use in circles
(define (make-sizes canvas user)
  (let* ([size (* (dim-w (canvas-outside canvas)) 2)]
         [step (/ size (length user))])
    (map (λ (x) (/ x 2)) (range 5 size step))))


(define (build-colors user)
  (define color-a (first user))
  (define color-b (if (< 100 (last user))
                      (/ (last user) 2)
                      (last user)))
  (if (> color-a color-b)
      (range color-b
             color-a
             (/ (- color-a color-b) (* (length (drop user 2)) 2)))
      (range color-a
             color-b
             (/ (- color-b color-a) (* (length (drop user 2)) 2)))))

;;;;;;;;;;;;;;;;;;;
; Shapes
;;;;;;;;;;;;;;;;;;;

; Drawing a row of shapes
(define (draw-rule digit radius sides color)
  (let* ([d (modulo digit 16)]
         [side (if (odd? sides)
                   (- sides 1)
                   sides)])
    (if (even? d)
        ;(radial-star sides (->int (/ radius 1.25)) radius "solid" "white")
        (radial-star side
                     (->int (/ radius 1.25))
                     radius
                     "solid"
                     (make-rgb color "50%" (string-join (list (number->string (- 100 d)) "%") "")))
        (radial-star side
                     (->int (/ radius 1.25))
                     radius
                     "solid"
                     (make-rgb color "60%" (string-join (list (number->string (- 60 d)) "%") ""))))))

; The main entry point for creating an identikon
; take 20 digits of user and create a new list of hues based on them
; create a list of 20 sizes (inner size / 20)
; iterate list and draw a circle of hue size for each

(define (draw-rules width height user)
  (let* ([canvas (make-canvas width height)]
         [sizes (make-sizes canvas user)]
         [color (first user)]
         [border (canvas-border canvas)]
         [base (square width "solid" "white")]
         [msides (->int (/ (last user) 10))]
         [sides (cond [(< msides 6) 6]
                      [(> msides 16) 16]
                      [else msides])])
    (let ([circles (for/list ([digit user]
                              [size sizes])
                     (draw-rule digit size sides color))])
      (crop/align "center" "center" width height (overlay (foldr (λ (r g) (overlay r g)) (first circles) (rest circles))
                                                          base)))))
