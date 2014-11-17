#lang racket
(require racket/gui
         racket/draw
         openssl/sha1
         css-tools/colors
         sugar)

(provide draw-rules)

; Split a SHA1 hash into a list of pairs ex: '("7b" "3b" ... )
(define (split-hash h)
  (for/list ([i (range 0 (string-length h) 2)])
    (substring h i (+ i 2))))

; Turn a SHA1 hash into a list of base 10 numbers
(define (process-user user) 
  (map (λ (x) (string->number x 16)) (split-hash (sha1 (open-input-bytes user)))))

; Is a number a double? ex: 33, 66
(define (double? x)
  (let ([nums (string->list (number->string x))])
    (eq? (first nums) (last nums))))

; Partition list into lists of n elements
; example: (chunk-mirror 3 '(1 2 3 4 5 6)) returns
; '((1 2 3 3 2 1) (4 5 6 6 5 4))
(define (chunk-mirror xs n)
  (let ([chunked (slice-at xs n)])
    (map (λ (x)
           (flatten (cons x (reverse x)))) chunked)))

; Build colors
(define color-a (first (take name 2)))
(define color-b (if (< 100 (second (take name 2)))
                    (/ (second (take name 2)) 2)
                    (second (take name 2))))
(define color-range (slice-at (if (> color-a color-b)
                                  (range color-b 
                                         color-a 
                                         (/ (- color-a color-b) (* (length (drop name 2)) 2)))
                                  (range color-a 
                                         color-b 
                                         (/ (- color-b color-a) (* (length (drop name 2)) 2)))) 6))

; Turn a hue into an RGB color object
(define (make-rgb hue [sat "60%"] [lig "50%"])
  (define rgb (map (λ (x) (->int (* 255 x))) 
                   (hsl->rgb (list (number->string (* 1.411 hue)) sat lig))))
  (make-color (first rgb) (second rgb) (third rgb)))

; Create the mirrored lists of hash values to create the shapes
(define points (chunk-mirror (drop name 2) 3))

; Solid circle
(define (even dc hue pos dim)
  (define offset (/ border 2))
  (define color (make-rgb hue))
  (send dc set-brush color 'solid)
  (send dc set-pen color 1 'solid)
  (send dc draw-ellipse 
        (+ (point-x pos) (/ offset 2)) 
        (+ (point-y pos) (/ offset 2)) 
        (- (dim-w dim) offset) 
        (- (dim-h dim) offset)))

; Empty circle
(define (double dc hue pos dim)
  (define offset (/ border 2))
  (define stroke (/ (dim-w dim) 4))
  (define color (make-rgb hue "30%"))
  (send dc set-brush "white" 'solid)
  (send dc set-pen color stroke 'solid)
  (send dc draw-ellipse 
        (+ (point-x pos) (/ offset 2) 4) 
        (+ (point-y pos) (/ offset 2) 4) 
        (- (dim-w dim) stroke 4) 
        (- (dim-h dim) stroke 4)))

; Dot
(define (odd dc hue pos dim)
  (define w (/ (dim-w dim) 2))
  (define h (/ (dim-h dim) 2))
  (define x (+ (point-x pos) (/ w 2)))
  (define y (+ (point-y pos) (/ h 2)))
  (define color (make-rgb hue "60%" "80%"))
  (send dc set-brush color 'solid)
  (send dc set-pen color 1 'solid)
  (send dc draw-ellipse x y w h))

; Drawing rules
(define (draw-rules dc xs hues c user)
  (let ([count (range 0 (length xs))])
    (for ([x xs]
          [hue hues]
          [i count])
      (cond [(double? x) (double dc 
                                 hue 
                                 (point (+ border (* (dim-w cell) i)) (+ border (* (dim-h cell) c))) 
                                 cell)] 
            [(even? x) (even dc 
                             hue 
                             (point (+ border (* (dim-w cell) i)) (+ border (* (dim-h cell) c))) 
                             cell)]
            [(odd? x) (odd dc 
                           hue 
                           (point (+ border (* (dim-w cell) i)) (+ border (* (dim-h cell) c))) 
                           cell)]
            ))))