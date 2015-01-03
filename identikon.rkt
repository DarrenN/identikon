#lang racket/base

; Identikon - parses username into a sha1-based identifier list and
; interfaces with rule-sets to create identicon image

(provide identikon)

(require racket/date
         racket/list
         racket/string
         openssl/sha1
         2htdp/image
         "utils.rkt")

; ———————————
; implementation

(define draw-rules null)

(define-namespace-anchor a)

; Dynamically load in a rules file
(define (load-plug-in file)
  (let ([ns (make-base-empty-namespace)])
    (namespace-attach-module (namespace-anchor->empty-namespace a)
                             '2htdp/image
                             ns)
    (parameterize ([current-namespace ns])
      (dynamic-require file 'draw-rules))))

; Create a filename and check if the file already exists, if so
; append a timestamp
(define (make-filename name size extension)
  (let* ([ext (string-join (list "." extension) "")]
         [sizename (string-join (list name (number->string size)) "_")]
         [filename (string-join (list sizename ext) "")])
    (if (file-exists? filename)
        (string-join (list sizename "_" (number->string (date->seconds (current-date))) ext) "")
        filename)))

; Save the file based on type - png or svg
(define (save-identicon filename type rendered)
  (cond
    [(string=? "svg" type) (save-svg-image rendered filename)]
    [(string=? "png" type) (save-image rendered filename)]
    [else (error 'save-identicon "failed because could not not save file type of ~a" type)]))

; Turn a SHA1 hash into a list of 20 base 10 numbers
(define (process-user user)
  (map (λ (x) (string->number x 16))
       (string-pairs (sha1 (open-input-bytes (string->bytes/utf-8 user))))))

; Identikon - build an identicon of a specific size based on username and
; using a rule-set. Will automatically drop the identicon in the repl unless
; you tell it to save
;
; ex: ;(identikon 300 300 "dfsdf")
;
(define (identikon width height username [rules "default"] [type #f])
  (let* ([processed-user (process-user username)]
         [rule-file (string-join (list rules "rkt") ".")])
    
    ; Load rules file if provided
    (set! draw-rules (load-plug-in rule-file))
    
    ; Create identicon
    (define rendered (draw-rules width height processed-user))
    
    ; Either save the identicon or output to REPL
    (if type
        (save-identicon (make-filename username width type) type rendered)
        rendered)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Command line handling for Identikon
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(module+ main
  (require racket/cmdline
           racket/list)
  
  (define size-flags (make-parameter null))
  (define rules-set (make-parameter '("default")))
  (define name (make-parameter null))
  (define ext (make-parameter "png"))
  
  (define make-identikon
    (command-line
     #:program "identikon"
     #:once-each
     [("-n" "--name") nm
                      "Username to convert to identikon"
                      (name nm)]
     
     [("-t" "--type") ty
                      "File type: png or svg"
                      (ext ty)]
     
     [("-r" "--rules") rs
                       "Use specific rules"
                       (rules-set (cons rs (rules-set)))]
     
     #:multi
     [("-s" "--size") sz
                      "Add a square size to generate"
                      (size-flags (cons sz (size-flags)))]))
  
  (cond
    [(and (empty? (size-flags)) (empty? (name))) (printf "No information provided ~n")]
    [(empty? (size-flags)) (printf "No sizes were provided, -s ~n")]
    [(empty? (name)) (printf "No name provided to process, -n ~n")]
    [else (for ([s (size-flags)])
            (identikon (string->number s)
                       (string->number s)
                       (name)
                       (first (rules-set)) (ext)))]))