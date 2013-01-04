The Mocca Programming Language
==============================

Actually it´s much to early for a more precise description, but I try it nonetheless:

* dynamically typed
* interpreted within JavaScript, no compilation.
* int, boolean and function data types
* expression evaluation respective correct precedence and associativity
* variable definitions and usage in expressions
* lexical scoping
* functions capture their definition context (aka "closures")
* a function call returns the last statement per default
* a few semantic runtime checks

Mocca is experimental at the moment but there are some things on my mind
I want to evaluate:

* use native JavaScript and JavaScript libraris from within Mocca
* direct integration of "standard libraries" in the language. That means
  something like "jQuery as language construct"
* extending Mocca with library functions that are indistinguishable from
  builtin keywords 
* programs as data (aka "metaprogramming")
* code generation for JavaScript (and another language?!)

See index.html for a few code samples.

