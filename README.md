![a](https://dl.dropboxusercontent.com/u/4221594/github/darren_200.png) ![b](https://dl.dropboxusercontent.com/u/4221594/github/norma_200.png) ![c](https://dl.dropboxusercontent.com/u/4221594/github/koji_200.png)

identikon
=========

A small collection of Racket scripts for generating identicons. This is very much alpha and will be changing a lot as I learn more about Racket. Identicons can be saved as PNG or SVG.

## Usage

Opening the `identikon.rkt` module in [Dr. Racket](http://docs.racket-lang.org/drracket/) or [Emacs/Geiser](http://docs.racket-lang.org/guide/Emacs.html) will give you access to the `identikon` function in the REPL:

```racket
; Generate a default 300px identicon for "racket"
(identikon 300 300 "racket")

; Generate a q*bert style 300px identicon for "racket"
(identikon 300 300 "racket" "qbert")

; Generate a q*bert style 300px identicon for "racket" and save as an svg
(identikon 300 300 "racket" "qbert" "svg")
```

Additionally you can require identikon into your own program as a module:

```racket
(require "identikon.rkt")
(define foo (identikon 300 300 "racket"))
```

**Note:** Trying to use identikon in a standard CLI racket REPL will just return an `(object:image% ...)` instead of rendering the image. You could save an image to the filesystem this way: `(identikon 300 300 "racket" "default" "svg")`.

## CLI interface

```shell
-s  (multi) Size (all identikons are currently squares)
-n  String to convert to identicon (will expand this to take files)
-r  (optional) Ruleset to use
-t  (optional) Filetype to save as: "png" or "svg"; defaults to png

$ racket identikon.rkt -s 300 -n "FooBarBaz"

$ racket identikon.rkt -s 300 -n "FooBarBaz" -r "squares"

$ racket identikon.rkt -s 300 -n "FooBarBaz" -r "squares" -t "svg"

$ racket identikon.rkt -s 300 -s 200 -s 100 -n "FooBarBaz" -r "stars" -t "svg"
```

## Built-in rule sets

Each identicon has a rules file (ex: `default.rkt`) which is responsible for taking the input data and generating an image as it sees fit. There are a few existing rule sets to play with.

#### default.rkt

![d](https://dl.dropboxusercontent.com/u/4221594/github/norma_300_default.png)

#### qbert.rkt

![s](https://dl.dropboxusercontent.com/u/4221594/github/racket_300_qbert.png)

#### squares.rkt

![s](https://dl.dropboxusercontent.com/u/4221594/github/norma_300_squares.png)

#### circles.rkt

![c](https://dl.dropboxusercontent.com/u/4221594/github/norma_300_circles.png)

#### angles.rkt

![a](https://dl.dropboxusercontent.com/u/4221594/github/norma_300_angles.png)

#### angles2.rkt

![a](https://dl.dropboxusercontent.com/u/4221594/github/norma_300_angles2.png)

#### nineblock.rkt

![n](https://dl.dropboxusercontent.com/u/4221594/github/norma_300_nineblock.png)

#### stars.rkt

![s](https://dl.dropboxusercontent.com/u/4221594/github/norma_300_stars.png)

#### rings.rkt

![r](https://dl.dropboxusercontent.com/u/4221594/github/norma_300_rings.png)
