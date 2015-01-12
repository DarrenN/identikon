#lang scribble/manual

@(require scribble/eval
          identikon
          (prefix-in q: identikon/rules/qbert)
          (for-label racket identikon))

@(define my-eval (make-base-eval))
@(my-eval `(require identikon identikon/rules/qbert))


@title{Identikon}

@author[(author+email "Darren Newton" "info@v25media.com")]

A small framework for generating @link["https://en.wikipedia.org/wiki/Identicon"]{identicons}.

@defmodule[identikon]

@section{Installation & updates}

At the command line:
@verbatim{raco pkg install identikon}

After that, you can update the package from the command line:
@verbatim{raco pkg update identikon}

@section{Generate identicon}

Identikon exposes a single function that generates an identicon based on a rules module.

@defproc[
         (identikon
          [width exact-positive-integer?]
          [height exact-positive-integer?]
          [username string?]
          [rules string? "default"]
          [type (or/c #f string?) #f])
         image?]


@racket[rules] is the name of the rules module to use in generating the identicon. This defaults to @racket["default"].

@racket[type] is the filetype of the image to save, and can be either @racket["png"] or @racket["svg"]. If omitted no file will be saved and the identicon will be output to the REPL.

Create a 300x300px identicon for @racket["racket"] using the @racket["default.rkt"] rule module.

@examples[#:eval my-eval
(identikon 300 300 "racket")
]

Create a 300x300 identicon for @racket["racket"] using the @racket["squares.rkt"] rule module.

@examples[#:eval my-eval
(identikon 300 300 "racket" "squares")
]

@section{Rules modules}

All rules modules must provide a single draw-rules function and live in the @racket[rules] folder.

@defproc[
  (draw-rules
   [width exact-positive-integer?]
   [height exact-positive-integer?]
   [user (listof exact-positive-integer?)])
  image?]

@examples[#:eval my-eval
(draw-rules
 200
 200
 '(27 180 200 176 189 77 68 156 1 211 209 117 218 72 146 38 144 184 241 76))
]

@section{License & source code}

This module is under the MIT license.

Source repository at @link["https://github.com/DarrenN/identikon"]{https://github.com/DarrenN/identikon}. Suggestions, corrections and pull-requests welcome.
