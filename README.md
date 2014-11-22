![a](https://dl.dropboxusercontent.com/u/4221594/github/darren_200.png) ![b](https://dl.dropboxusercontent.com/u/4221594/github/norma_200.png) ![c](https://dl.dropboxusercontent.com/u/4221594/github/koji_200.png)

identikon
=========

A small collection of Racket scripts for generating identicons. This is very much alpha and will be changing a lot as I learn more about Racket. Currently saves identicons to disk as a PNG.

## CLI interface

```shell

-s  Size (all identikons are currently squares)
-n  String to convert to identicon (will expand this to take files)
-r  Ruleset to use.

$ racket main.rkt -s 300 -n "FooBarBaz" -r "default.rkt"
```
