#lang scribble/manual

@(require scribble/eval
          identikon
          2htdp/image
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

Identikon has a full command line interface which you can view with
@verbatim{raco identikon --help}

@section{Generating identicons}

@defproc[
         (identikon
          [width exact-positive-integer?]
          [height exact-positive-integer?]
          [input (or/c symbol? string?)]
          [rules (or/c symbol? string?) "default"]
          [#:filename boolean? #t #f])
         image?]{

Identikon provides a single function, @racket[identikon], which produces images
based on input. If input is a string or symbole, a SHA1 hash will be produced
and used to geneate an image. If a filename is provided a SHA1 of the file will
be produced and used as input for generating images.

Produces an @racket[identikon] with dimensions specified by @racket[width] and
@racket[height].

@racket[input] is converted into a list of numbers based on a SHA1 hash and
passed to a @racket[rules] module for processing into an @racket[image?].

@racket[rules] is the name of the rules module to use in generating the
identicon. This defaults to @racket["default"].

If @racket[#:filename] is @racket[#t] then @racket[identikon] will treat the
value of @racket[input] as a filename and attempt fo open it for processing.
}

@bold{Examples:}

Create a 300x300px identicon for @racket["racket"] using the @racket["default.rkt"] rule module.

@examples[#:eval my-eval
(identikon 300 300 "racket")
]

Create a 300x300 identicon for @racket["racket"] using the @racket["squares.rkt"] rule module.

@examples[#:eval my-eval
(identikon 300 300 "racket" 'squares)
]

@defproc[
(save-identikon
 [filename string?]
 [type (or/c symbol? string?)]
 [image image?]
 [#:quality number? natural-number/c 75])
boolean?]{

Save an @racket[identikon] image to disk. Available types are @code[]{svg},
@code[]{png} and @code[]{jpeg}. If the file already exists, a new version
of the file will be saved with a timestamp (seconds) appended.

@racket[#:quality] only affects @code[]{jpeg} images.
}

@racketblock[
 (save-identikon "foo" 'png
                 (identikon 300 300 'racket 'qbert))
]

@defproc[
(identikon->string
 [type (or/c symbol? string?)]
 [image image?]
 [#:quality number? natural-number/c 75])
string?]{

Return an @racket[identikon] in a string format. This is useful if you want to
inject the image directly into an HTML page as an @code[]{<svg />} element or
as a data-uri.

Available types are @code[]{svg}, @code[]{png} and @code[]{jpeg}.

@code[]{svg} will emit a well formed @hyperlink["http://www.w3.org/TR/SVG11/"]{SVG element}.

@code[]{png} and @code[]{jpeg} types will emit a string of base-64 encoded bytes
suitable for use in an @hyperlink["https://en.wikipedia.org/wiki/Data_URI_scheme"]{HTML data-uri}.

@racket[#:quality] only affects @code[]{jpeg} images.
}

@racketblock[
(identikon->string (identikon 300 300 'racket 'qbert) 'svg)
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
