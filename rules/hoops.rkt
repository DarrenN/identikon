#lang racket

(provide draw-rules)

(require openssl/sha1
         2htdp/image
         sugar
         "utils.rkt")

(define (build lst)
  lst)

; Main draw function
(define (draw-rules width height user)
  (let* ([canvas (make-canvas width height)])
    (build canvas (make-triplets user) 3)))