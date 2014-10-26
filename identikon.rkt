#lang racket
(require racket/gui
         racket/draw
         openssl/sha1
         css-tools/colors
         sugar)

(struct point (x y))
(struct dim (w h))

(define border 20)
(define padding 36)
(define numbers (build-list 18 (λ (x) (random 64))))

; Split a SHA1 hash into a list of pairs ex: '("7b" "3b" ... )
(define (split-hash h)
  (for/list ([i (range 0 (string-length h) 2)])
    (substring h i (+ i 2))))

; Turn a SHA1 hash into a list of base 10 numbers
(define name (map (λ (x) (string->number x 16)) (split-hash (sha1 (open-input-bytes #"d_run")))))

; Is a number a double? ex: 33, 66
(define (double? x)
  (let ([nums (string->list (number->string x))])
    (eq? (first nums) (last nums))))

; Returns #t for even, #f for odd and 'double for double numbers (ex: 33)
(define (filter-items x)
    (cond [(double? x) 'double]
          [(even? x) #t]
          [(odd? x) #f]))

; Partition list into lists of n elements
; example: (chunk-mirror 3 '(1 2 3 4 5 6)) returns
; '((1 2 3 3 2 1) (4 5 6 6 5 4))
(define (chunk-mirror xs n filter)
  (let ([chunked (slice-at xs n)])
    (map (λ (x)
           (map filter (flatten (cons x (reverse x))))) chunked)))

; Build colors
(define rgb (map (λ (x) (->int (* 255 x))) (hsl->rgb (list (number->string (* 1.411 (first (take name 2)))) "60%" "50%"))))
(define color (make-color (first rgb) (second rgb) (third rgb)))

(define points (chunk-mirror (drop name 2) 3 filter-items))

; Solid circle
(define (even dc pos dim)
  (send dc set-brush color 'solid)
  (send dc draw-ellipse (point-x pos) (point-y pos) (dim-w dim) (dim-h dim)))

; Empty circle
(define (double dc pos dim)
  (send dc set-brush "white" 'solid)
  (send dc set-pen color 6 'solid)
  (send dc draw-ellipse (point-x pos) (point-y pos) (dim-w dim) (dim-h dim)))

; Dot
(define (odd dc pos dim)
  (send dc set-brush color 'solid)
  (send dc draw-ellipse (point-x pos) (point-y pos) (dim-w dim) (dim-h dim)))

; Drawing rules
(define (draw-rules dc xs c)
  (let ([count (range 0 (length xs))])
    (for ([x xs]
          [i count])
      (cond [(eq? x #t) (even dc (point (+ border (* padding i)) (+ border (* padding c))) (dim 22 22))]
            [(eq? x #f) (odd dc (point (+ border 5 (* padding i)) (+ border 5 (* padding c))) (dim 12 12))]
            [(eq? x 'double) (double dc (point (+ border (* padding i)) (+ border (* padding c))) (dim 22 22))]))))

; Callback for canvas - loops over row data
(define (cb canvas dc)
  (send dc set-smoothing 'smoothed)
  (let ([count (range 0 (length points))])
        (for ([row points]
              [i count])
          (draw-rules dc row i))))

(define frame (new frame%
                   [label "Example"]
                   [width 300]
                   [height 300]))

(new canvas% [parent frame]
             [paint-callback cb])

(send frame show #t)