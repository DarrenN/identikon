#lang racket

(provide draw-rules)

(require lang/posn
         openssl/sha1
         2htdp/image
         sugar
         identikon/utils)

; Constants
(define RHOMBUS-ANGLE 60)
(define HEX-TOP 200)
(define HEX-LEFT 80)
(define HEX-RIGHT 155)
(define ALPHA-MAX 50)
(define DEFAULT-ALPHA 255)
(define CANVAS-COLOR "white")
(define BORDER-MAX 10)
(define MAX-USER-LENGTH 18)

; Data structs
(struct hex (offset row col point image) #:transparent)

; Rhombus offset - the hexes are two sideways rhombii tall, so this
; will calculate 1/4 of their height, used in stacking on y-axis
(define (rhombus-offset height)
  (- height (/ height 4)))

; Generate a color with alphas from r g b list
(define (build-color base-color [alpha DEFAULT-ALPHA])
  (cond
    [(string? base-color) base-color]
    [(list? base-color) (color (first base-color)
                               (second base-color)
                               (third base-color)
                               (max ALPHA-MAX alpha))]))

; Given a width, find the side length of a rhombus using rwidth by searching constraints
(define (find-side width)
  (let ([r (range (+ width 1))])
    (define (loop n)
      (cond
        [(empty? n) 0]
        [(>= (round (rwidth (first n))) width) (first n)]
        [else (loop (rest n))]))
    (loop r)))

; Get width of rhombus from length of side
(define (rwidth side)
  (sqrt
   (+ (* 2 (expt side 2))
      (* (* 2 (expt side 2))
         (cos (degrees->radians RHOMBUS-ANGLE))))))

; hex (offset row col point image)
(define (build-hexes points size hex-dim hex-offset canvas)
  (for/list ([row points]
             [row-pos (range (length points))]
             [offset (map even? (range 0 (length points)))])
    (for/list ([color row]
               [col (range (length row))])
      (let* ([w (dim-w hex-dim)]
             [h (dim-h hex-dim)]
             [dx (/ (- (/ (dim-w (canvas-inside canvas)) 2) (/ (* (dim-w hex-dim) (length row)) 2)) 2)]
             [dy (- (dim-w (canvas-inside canvas)) (* (rhombus-offset h) 4))]
             [off (if offset
                      (+ (/ w 2) dx)
                      dx)]
             [x (+ (* w col) (/ w 2) off)]
             [y (+ (* (rhombus-offset h) row-pos) (+ (/ h 2) (/ dy 4)))])
        (hex offset row-pos col (point x y) (make-hex size color))))))

; (build (make-canvas 200 200) (make-triplets (build-list 18 (λ (x) (random 255)))) 3)
(define (build canvas triplets columns)
  (let* ([points (slice-at (filter-triplets triplets) columns)]
         [rows (length points)]
         [canvas-w (dim-w (canvas-inside canvas))]
         [canvas-h (dim-h (canvas-inside canvas))]
         [point-h (/ canvas-h rows)]
         [hex-size (find-side point-h)]
         [hex (make-hex hex-size "white")]
         [hex-dim (dim (image-width hex) (image-height hex))]
         [hex-offset-x (* (dim-w hex-dim) .5)]
         [hexes (flatten (build-hexes points hex-size hex-dim hex-offset canvas))]
         [scene (square (dim-w (canvas-inside canvas)) "solid" CANVAS-COLOR)])
    (define (loop image hexes)
      (cond
        [(empty? hexes) image]
        [else (place-image
               (hex-image (first hexes))
               (point-x (hex-point (first hexes)))
               (point-y (hex-point (first hexes)))
               (loop scene (rest hexes)))]))
    (overlay
     (loop scene hexes)
     (square (dim-w (canvas-outside canvas)) "solid" CANVAS-COLOR))))

; Create a hexagon from three rhombii
(define (make-hex size base-color)
  (overlay/offset
   (rotate 90 (rhombus size RHOMBUS-ANGLE "solid" (build-color base-color HEX-TOP)))
   0 (rhombus-offset size)
   (beside (rotate 30 (rhombus size RHOMBUS-ANGLE "solid" (build-color base-color HEX-LEFT)))
           (rotate -30 (rhombus size RHOMBUS-ANGLE "solid" (build-color base-color HEX-RIGHT))))))

; Numbers divisible by 3 are white
(define (filter-triplets triplets)
  (map (λ (t)
         (if (zero? (modulo (foldl + 0 t) 3))
             CANVAS-COLOR
             t)) triplets))

; Main draw function
(define (draw-rules width height user)
  (let* ([canvas (make-canvas width height BORDER-MAX)])
    (build canvas (make-triplets user MAX-USER-LENGTH) 3)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Tests

(module+ test
  (require quickcheck
           sugar)

  ; rhombus-offset calculcation is correct
  (define rhombus-offset-outputs-agree
    (property ([num arbitrary-natural])
              (let* ([onum (rhombus-offset num)]
                     [diff (- num onum)])
                (= num
                   (* diff 4)))))
  (quickcheck rhombus-offset-outputs-agree))
