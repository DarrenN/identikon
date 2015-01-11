#lang racket

(provide draw-rules)

; ———————————
; implementation

(require racket/list
         2htdp/image
         lang/posn
         sugar
         identikon/utils)

; Define shapes
(define shapes (make-vector 16))
(define centers (vector 0 4 8 15))

; Shape 0
(vector-set! shapes 0 (λ (cell [rot 0] [color "black"] [color-bg "white"])
                        (rotate (* -1 90 rot) (square (dim-w cell) "solid" color))))

; Shape 1
(vector-set! shapes 1 (λ (cell [rot 0] [color "black"] [color-bg "white"])
                        (rotate (* -1 90 rot) (triangle/ass 90
                                                            (dim-w cell)
                                                            (dim-h cell)
                                                            "solid"
                                                            color))))

; Shape 2
(vector-set! shapes 2 (λ (cell [rot 0] [color "black"] [color-bg "white"])
                        (rotate (* -1 90 rot) (overlay/align "middle" "bottom"
                                               (triangle (dim-h cell) "solid" color)
                                               (square (dim-w cell) "solid" color-bg)))))

; Shape 3
(vector-set! shapes 3 (λ (cell [rot 0] [color "black"] [color-bg "white"])
                        (rotate (* -1 90 rot) (overlay/align "left" "top"
                                                             (rectangle (/ (dim-w cell) 2) (dim-h cell) "solid" color)
                                                             (square (dim-w cell) "solid" color-bg)))))

; Shape 4
(vector-set! shapes 4 (λ (cell [rot 0] [color "black"] [color-bg "white"])
                        (rotate (* -1 90 rot) (overlay (rotate 45
                                                               (square (/ (dim-w cell) 1.5)
                                                                       "solid"
                                                                       color))
                                                       (square (dim-w cell) "solid" color-bg)))))

; Shape 5
(vector-set! shapes 5 (λ (cell [rot 0] [color "black"] [color-bg "white"])
                        (rotate (* -1 90 rot) (polygon (list (make-posn 0 0)
                                                             (make-posn (dim-w cell) (/ (dim-h cell) 2))
                                                             (make-posn (dim-w cell) (dim-h cell))
                                                             (make-posn (/ (dim-w cell) 2) (dim-h cell))
                                                             (make-posn 0 0))
                                                       "solid"
                                                       color))))

; Shape 6
(vector-set! shapes 6 (λ (cell [rot 0] [color "black"] [color-bg "white"])
                        (rotate (* -1 90 rot) (overlay/align "middle" "bottom"
                                               (above
                                                (triangle (/ (dim-w cell) 2) "solid" color)
                                                (beside
                                                 (triangle (/ (dim-w cell) 2) "solid" color)
                                                 (triangle (/ (dim-w cell) 2) "solid" color)))
                                               (square (dim-w cell) "solid" color-bg)))))

; Shape 7
(vector-set! shapes 7 (λ (cell [rot 0] [color "black"] [color-bg "white"])
                        (rotate (* -1 90 rot) (polygon (list (make-posn 0 0)
                                                             (make-posn (dim-w cell) (/ (dim-h cell) 2))
                                                             (make-posn (/ (dim-w cell) 2) (dim-h cell))
                                                             (make-posn 0 0))
                                                       "solid"
                                                       color))))

; Shape 8
(vector-set! shapes 8 (λ (cell [rot 0] [color "black"] [color-bg "white"])
                        (rotate (* -1 90 rot) (overlay (square (/ (dim-w cell) 2) "solid" color)
                                                       (square (dim-w cell) "solid" color-bg)))))

; Shape 9
(vector-set! shapes 9 (λ (cell [rot 0] [color "black"] [color-bg "white"])
                        (rotate
                         (* -1 90 rot)
                         (overlay/align
                          "left"
                          "bottom"
                          (triangle/ass 90 (/ (dim-w cell) 2) (/ (dim-h cell) 2) "solid" color)
                          (overlay/align
                           "right"
                           "top"
                           (triangle/ass 90 (/ (dim-w cell) 2) (/ (dim-h cell) 2) "solid" color)
                           (square (dim-w cell) "solid" color-bg))))))

; Shape 10
(vector-set! shapes 10 (λ (cell [rot 0] [color "black"] [color-bg "white"])
                         (rotate (* -1 90 rot) (overlay/align
                                                "left"
                                                "top"
                                                (square (/ (dim-w cell) 2) "solid" color)
                                                (square (dim-w cell) "solid" color-bg)))))

; Shape 11
(vector-set! shapes 11 (λ (cell [rot 0] [color "black"] [color-bg "white"])
                         (rotate (* -1 90 rot) (overlay/align
                                                "middle"
                                                "bottom"
                                                (rotate 135
                                                        (triangle/ass 90
                                                                      (/ (dim-w cell) 1.5)
                                                                      (/ (dim-h cell) 1.5)
                                                                      "solid"
                                                                      color))
                                                (square (dim-w cell) "solid" color-bg)))))

; Shape 12
(vector-set! shapes 12 (λ (cell [rot 0] [color "black"] [color-bg "white"])
                         (rotate (* -1 90 rot) (overlay/align
                                                "middle"
                                                "bottom"
                                                (rotate -45
                                                        (triangle/ass 90
                                                                      (/ (dim-w cell) 1.5)
                                                                      (/ (dim-h cell) 1.5)
                                                                      "solid"
                                                                      color))
                                                (square (dim-w cell) "solid" color-bg)))))

; Shape 13
(vector-set! shapes 13 (λ (cell [rot 0] [color "black"] [color-bg "white"])
                         (rotate (* -1 90 rot)
                                 (overlay/align
                                  "left"
                                  "top"
                                  (rotate 180
                                          (triangle/ass 90
                                                        (/ (dim-w cell) 2)
                                                        (/ (dim-h cell) 2)
                                                        "solid"
                                                        color))
                                  (square (dim-w cell) "solid" color-bg)))))

; Shape 14
(vector-set! shapes 14 (λ (cell [rot 0] [color "black"] [color-bg "white"])
                         (rotate (* -1 90 rot)
                                 (overlay/align
                                  "left"
                                  "top"
                                  (triangle/ass 90
                                                (/ (dim-w cell) 2)
                                                (/ (dim-h cell) 2)
                                                "solid"
                                                color)
                                  (square (dim-w cell) "solid" color-bg)))))

; Shape 15
(vector-set! shapes 15 (λ (cell [rot 0] [color "black"] [color-bg "white"])
                         (rotate (* -1 90 rot) (square (dim-w cell) "solid" color-bg))))

; Create cell dimensions from inside canvas dim / divisor
(define (make-cell c divisor)
  (let* ([inside (canvas-inside c)]
         [cw (->int (dim-w inside))]
         [ch (->int (dim-h inside))])
    (dim (->int (/ cw divisor)) (->int (/ ch divisor)))))

; Take a list of values 0-255 and make a color object
(define (make-rgb-color rgb)
  (make-color (first rgb) (second rgb) (third rgb)))

; (make-nine-step (make-canvas 300 300) '(15 22 12 195 158 221 200 252 113 26 104 161 153 58 77 154 220 100 243 137) (make-rgb 15 "80%" "95%"))
(define (make-nine-step canvas points color-bg)
  (let* ([cell (make-cell canvas 3)]
         [ctr (vector-ref centers (modulo (first points) 4))] ; get center number from centers vector
         [a (modulo (second points) 16)]
         [a-rot (modulo (third points) 4)] ; starting rotation 1 - 4
         [b (modulo (fourth points) 16)]
         [b-rot (modulo (fifth points) 4)] ; starting rotation 1 - 4
         [color (make-rgb (sixth points))]
         [positions (list
                     (list ((vector-ref shapes b) cell b-rot color color-bg)
                           ((vector-ref shapes a) cell a-rot color color-bg)
                           ((vector-ref shapes b) cell (modulo (+ b-rot 1) 4) color color-bg))
                     (list ((vector-ref shapes a) cell (modulo (+ a-rot 3) 4) color color-bg)
                           ((vector-ref shapes ctr) cell 0 color color-bg)
                           ((vector-ref shapes a) cell (modulo (+ a-rot 1) 4) color color-bg))
                     (list ((vector-ref shapes b) cell (modulo (+ b-rot 3) 4) color color-bg)
                           ((vector-ref shapes a) cell (modulo (+ a-rot 2) 4) color color-bg)
                           ((vector-ref shapes b) cell (modulo (+ b-rot 2) 4) color color-bg)))])
    (above
     (beside (first (first positions))
             (second (first positions))
             (third (first positions)))
     (beside (first (second positions))
             (second (second positions))
             (third (second positions)))
     (beside (first (third positions))
             (second (third positions))
             (third (third positions))))))

; The main entry point for creating an identikon
(define (draw-rules width height user)
  (let* ([canvas (make-canvas width height)]
         [color-bg (make-rgb (sixth user) "60%" "90%")]
         [base (square width "solid" color-bg)])
    (overlay (make-nine-step canvas user color-bg)
                         base)))
