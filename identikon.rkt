#lang racket/base

(require racket/date
         racket/list
         racket/string
         openssl/sha1
         2htdp/image
         "default.rkt")

(provide identikon)

(define-namespace-anchor a)
 
; Dynamically load in a rules file
(define (load-plug-in file)
  (let ([ns (make-base-empty-namespace)])
    (namespace-attach-module (namespace-anchor->empty-namespace a)
                             'racket/base
                              ns)
    (parameterize ([current-namespace ns])
      (dynamic-require file 'draw-rules))))

; Create a filename and check if the file already exists, if so
; append a timestamp
(define (make-filename name size ext)
  (let* ([sizename (string-join (list name (number->string size)) "_")]
         [filename (string-join (list sizename ext) "")])
    (if (file-exists? filename) 
        (string-join (list sizename "_" (number->string (date->seconds (current-date))) ext) "")
        filename)))

; Split a SHA1 hash into a list of pairs ex: '("7b" "3b" ... )
(define (split-hash h)
  (for/list ([i (range 0 (string-length h) 2)])
    (substring h i (+ i 2))))

; Turn a SHA1 hash into a list of base 10 numbers
(define (process-user user) 
  (map (λ (x) (string->number x 16)) 
       (split-hash (sha1 (open-input-bytes (string->bytes/utf-8 user))))))

; Entry point 
(define (identikon width height username [rules #f])
  (let* ([processed-user (process-user username)]
         [label (string-join (list "Identikon ::" username))])
    
    ; Load rules file if provided
    (cond [rules (if (file-exists? rules)
                     (load-plug-in rules)
                     #f)])
    
    ; create a canvas to draw on
    (define filename (make-filename username width ".png"))
    (save-image (draw-rules width height processed-user) filename)))


;(identikon 300 300 "dfsdf")