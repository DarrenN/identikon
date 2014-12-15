#lang racket

(provide draw-rules)

(require lang/posn
         openssl/sha1
         2htdp/image
         sugar
         "utils.rkt")

; Data structs
(struct point (x y))
(struct dim (w h))
(struct canvas (outside inside border))

; Build up a list of triplets '(1 2 3) to use as color information
(define (make-triplets user)
  (let* ([initial (take (slice-at user 3) 6)]
         [firsts (slice-at (foldl (λ (x y) (cons (first x) y)) '() initial) 3)]
         [seconds (slice-at (foldl (λ (x y) (cons (second x) y)) '() initial) 3)]
         [thirds (slice-at (foldl (λ (x y) (cons (third x) y)) '() initial) 3)])
    (append initial firsts seconds thirds)))

; Take the dimensions and calculate a border 10% of dim and the internal draw space
(define (make-canvas width height)
  (let* ([border (* width .1)]
         [iw (->int (- width (* border 2)))]
         [ih (->int (- height (* border 2)))]
         [outside (dim width height)]
         [inside (dim iw ih)])
    (canvas outside inside border)))

; Generate a color with alphas from r g b list
(define (build-color base-color alpha)
  (cond
    [(string? base-color) "white"]
    [(list? base-color) (color (first base-color)
                           (second base-color)
                           (third base-color)
                           (max 50 alpha))]))

; Create a hexagon from three rhombii
(define (make-hex size base-color)
  (overlay/offset
   (rotate 90 (rhombus size 60 "solid" (build-color base-color 255)))
   0 (- size (/ size 4))
   (beside (rotate 30 (rhombus size 60 "solid" (build-color base-color 80)))
           (rotate -30 (rhombus size 60 "solid" (build-color base-color 155))))))

; Evens are white
(define (filter-triplets triplets)
  (map (λ (t)
         (if (even? (foldl + 0 t))
             "white"
             t)) triplets))

; Create a row of hexagons
(define (make-row triplets w)
  (define colors (filter-triplets triplets))
  (beside
     (make-hex w (first colors))
     (make-hex w (second colors))
     (make-hex w (third colors))))

; Stack up the rows
(define (make-rows triplets w n)
  (cond
    [(zero? n) (make-row triplets w)]
    [else
     (local [(define hex-row (make-row triplets w))
             (define hex-w (image-width (make-hex w "white")))
             (define row-h (image-height hex-row))]
       (define x-offset (if (even? n)
                            0
                            (->int (* hex-w .5))))
       (overlay/offset
        (make-rows (drop triplets 3) w (- n 1))
        x-offset (->int (* n (- row-h (* w .5))))
        (make-rows (reverse (drop triplets 3)) w (- n 1))))]))

(define (draw-rules width height user)
  (let* ([canvas (make-canvas width height)]
         [border (canvas-border canvas)]
         [base (square width "solid" "white")])
    (overlay 
     (make-rows (make-triplets user) (->int (/ (- width border) 6.5)) 2)
     base)))