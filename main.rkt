#lang racket/base

;; Identikon - parses username into a sha1-based identifier list and
;; interfaces with rule-sets to create identicon image

(require racket/date
         racket/list
         racket/runtime-path
         racket/string
         racket/contract
         openssl/sha1
         2htdp/image
         sugar
         identikon/utils
         identikon/transforms)

(provide (contract-out [identikon (->* (exact-positive-integer?
                                        exact-positive-integer?
                                        any/c)
                                       ((or/c string? symbol?)
                                        #:filename boolean?)
                                       image?)]
                       [save-identikon (->* (string?
                                            (or/c symbol? string?)
                                            image?)
                                            (#:quality number?)
                                            boolean?)]
                       [identikon->string (->* ((or/c symbol? string?)
                                                image?)
                                               (#:quality number?)
                                               string?)]))

;; Identifier we overwrite dynamically with module functions
(define draw-rules null)

(define-namespace-anchor a)

(define-runtime-path RULES-DIR "rules")

;; Dynamically load in a rules file
(define (load-plug-in file)
  (let ([ns (make-base-empty-namespace)]
        [filename (build-path RULES-DIR file)])
    (namespace-attach-module (namespace-anchor->empty-namespace a)
                             '2htdp/image
                             ns)
    (parameterize ([current-namespace ns])
      (dynamic-require filename 'draw-rules))))

;; Create a filename and check if the file already exists, if so
;; append a timestamp
(define (make-filename name size extension)
  (let* ([ext (format ".~a" (->string extension))]
         [sizename (format "~a_~a" (->string name) (number->string size))]
         [filename (string-join (list sizename ext) "")])
    (if (file-exists? filename)
        (string-join
         (list sizename "_"
               (number->string (date->seconds (current-date))) ext) "")
        filename)))

;; Save the file based on type - png, jpeg or svg
(define (save-identikon filename type image #:quality [quality 75])
  (let* ([ext (->string type)]
         [path (make-filename filename (image-width image) ext)])
    (cond
      [(string=? "svg" ext) (save-svg image path)]
      [(string=? "png" ext) (save-bitmap image path)]
      [(string=? "jpeg" ext) (save-bitmap image path 'jpeg #:quality quality)]
      [else (error 'save-identicon
                   "failed because could not not save file type of ~a" type)])))

;; Output the image as a string representation
;; (svg as xml, png/jpeg as base64 bytes)
(define (identikon->string type image #:quality [quality 75])
  (let* ([ext (->string type)])
    (cond
      [(string=? "svg" ext) (image->svg-string image)]
      [(or (string=? "png" ext) (string=? "jpeg" ext))
       (image->bitmap-string image type quality)]
      [else (error 'identikon->string "~a is not a valid image type" ext)])))

;; Convert a symbol or string into a rules filename
(define (create-rules-filename rules)
  (let ([root (if (string? rules)
                  rules
                  (->string rules))])
    (format "~a.rkt" rules)))

#|

 Identikon - build an identicon of a specific size based on username and
 using a rule-set. Will automatically drop the identicon in the repl unless
 you tell it to save

 ex: (identikon 300 300 "dfsdf")
     (identikon 300 300 'dfsdf 'qbert)

|#
(define (identikon width height input
                   [rules "default"] #:filename [filename #f])
  (let* ([processed-input (if filename
                             (file->numberlist input)
                             (string->numberlist input))]
         [rule-file (create-rules-filename rules)])

    ;; Load rules file if provided
    (set! draw-rules (load-plug-in rule-file))

    ;; Create identicon
    (define rendered (draw-rules width height processed-input))

    ;; Return identikon (image)
    rendered))

(module+ test
  (require rackunit
           sugar
           2htdp/image)

  (test-case
      "create-rules-filename will append .rkt to anything that can be stringed"
    (check-regexp-match ".rkt" (create-rules-filename "rza"))
    (check-regexp-match ".rkt" (create-rules-filename 'wutang))
    (check-regexp-match ".rkt" (create-rules-filename 187)))

  (test-case
      "identikon returns an image"
    (check-pred image? (identikon 100 100 'rza)))

  (test-case
      "identikon->string returns a string"
    (check-pred string? (identikon->string 'jpeg (identikon 100 100 'rza)))
    (check-pred string? (identikon->string 'png (identikon 100 100 'rza)))
    (check-pred string? (identikon->string 'svg (identikon 100 100 'rza)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Command line handling for Identikon
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(module+ main
  (require racket/cmdline
           racket/list)

  (define size-flags (make-parameter null))
  (define rules-set (make-parameter '("default")))
  (define input-str (make-parameter null))
  (define file-name (make-parameter null))
  (define ext (make-parameter "png"))

  (define make-identikon
    (command-line
     #:program "identikon"
     #:once-each
     [("-i" "--input-str") in
                      "String input-str to convert to identikon"
                      (input-str in)]

     [("-f" "--file") fl
      "File or input stream used to generate identikon"
      (file-name fl)]

     [("-t" "--type") ty
                      "File type: png or svg"
                      (ext ty)]

     [("-r" "--rules") rs
                       "Use specific rules"
                       (rules-set (cons rs (rules-set)))]

     #:multi
     [("-s" "--size") sz
                      "Add a square size(s) to generate. You can create multiple sizes."
                      (size-flags (cons sz (size-flags)))]))

  (cond
    [(and (empty? (size-flags))
          (empty? (input-str))) (printf "No information provided ~n")]
    [(empty? (size-flags)) (printf "No sizes were provided, -s ~n")]
    [(empty? (input-str)) (printf "No input provided to process, -i ~n")]
    [(not (empty? (file-name))) (for ([s (size-flags)])
            (save-identikon (file-name) (ext) (identikon (string->number s)
                                                    (string->number s)
                                                    (file-name)
                                                    (first (rules-set))
                                                    #:filename #t))
            (printf "Saved ~apx identicon for ~a ~n" s (file-name)))]
    [else (for ([s (size-flags)])
            (save-identikon (input-str) (ext) (identikon (string->number s)
                                                     (string->number s)
                                                     (input-str)
                                                     (first (rules-set))))
            (printf "Saved ~apx identicon for ~a ~n" s (input-str)))]))
