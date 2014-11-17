#lang racket/base

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Command line handling for Identikon
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require racket/cmdline
         racket/list
         "identikon.rkt")

(define size-flags (make-parameter null))
(define rules-set (make-parameter null))
(define name (make-parameter null))

(define make-identikon
  (command-line
   #:program "identikon"
   #:once-each
   [("-n" "--name") nm
                    "Username to convert to identikon"
                    (name nm)]
   #:once-any
   [("-r" "--rules") rs
                     "Use specific rules"
                     (rules-set (cons rs (rules-set)))]
   #:multi
   [("-s" "--size") sz
                    "Add a square size to generate"
                    (size-flags (cons sz (size-flags)))]))

(cond
  [(empty? (size-flags)) (printf "No sizes were provided, -s ~n")]
  [(empty? (name)) (printf "No name provided to process, -n ~n")])

(for ([s (size-flags)])
  (identikon (string->number s) (string->number s) (name) (first (rules-set))))