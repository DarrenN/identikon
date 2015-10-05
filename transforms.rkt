#lang racket

(require mrlib/image-core
         (except-in racket/draw
                    make-pen make-color)
         (only-in 2htdp/image
                  image-height
                  image-width)
         net/base64
         sugar)

(provide image->svg-port
         image->bitmap-dc
         image->bitmap-string
         image->svg-string
         save-svg
         save-bitmap)

;; ///////////////////////
;; // SVG Operations
;; //////////////////////

;; Render image as an SVG and return its data in a string port
(define (image->svg-port image)
  (let* ([width (image-width image)]
         [height (image-height image)]
         [out (open-output-string)]
         [sdc (new svg-dc% [width width] [height height] [output out])])
    (send sdc start-doc "")
    (send sdc start-page)
    (send sdc set-smoothing 'aligned)
    (render-image image sdc 0 0)
    (send sdc end-page)
    (send sdc end-doc)
    out))

;; Return string representation of SVG from port
(define (image->svg-string image)
  (get-output-string (image->svg-port image)))

;; Save SVG string to disk
(define (save-svg image filename)
  (display-to-file (image->svg-string image)
                   filename
                   #:mode 'binary
                   #:exists 'replace))

(module+ test
  (require rackunit
           2htdp/image)

  (test-case
      "image->svg-port returns a port"
    (check-pred port? (image->svg-port (circle 20 "outline" "red"))))

  (test-case
      "image->svg-string returns a string"
    (check-pred string? (image->svg-string (circle 20 "outline" "red")))))

;; ///////////////////////
;; // Bitmap Operations
;; //////////////////////

;; Convert image to a bitmap
(define (image->bitmap-dc image)
  (let* ([width (image-width image)]
         [height (image-height image)]
         [bm (make-bitmap (inexact->exact (ceiling width))
                          (inexact->exact (ceiling height)))]
         [bdc (make-object bitmap-dc% bm)])
    ;(send bdc set-smoothing 'aligned)
    (send bdc erase)
    (render-image image bdc 0 0)
    (send bdc set-bitmap #f)
    bm))

;; Dump bitmap into port to use as a string
(define (image->bitmap-bytes image [type 'png] [quality 75])
  (let* ([out (open-output-bytes)]
         [bmp (image->bitmap-dc image)])
    (send bmp save-file out type quality)
    out))

;; Return a bitmap as a base-64 encoded byte string
(define (image->bitmap-string image [type 'png] [quality 75])
  (bytes->string/utf-8 (base64-encode (get-output-bytes (image->bitmap-bytes image type quality)))))

;; Save Bitmap to disk as 'png or 'jpeg
(define (save-bitmap image filename [type 'png] #:quality [quality 75])
  (let* ([out (open-output-bytes)]
         [bmp (image->bitmap-dc image)])
    (send bmp save-file out type quality)
    (display-to-file (get-output-bytes out)
                     filename
                     #:mode 'binary
                     #:exists 'replace)))

(module+ test
  (test-case
      "image->bitmap-dc returns a bitmap"
    (check-true (is-a? (image->bitmap-dc (circle 20 "outline" "red")) bitmap%)))

  (test-case
      "image->bitmap-bytes returns a port"
    (check-pred port? (image->bitmap-bytes (circle 20 "outline" "red"))))

  (test-case
      "image->bitmap-string returns a string"
    (check-pred string? (image->bitmap-string (circle 20 "outline" "red")))))
