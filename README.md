Introduction
============

Prooby is a Ruby-inspired syntax for Python.  At the moment, it uses Ruby itself
to parse the code and compile to a Python AST.  In the future, it is planned to
be copmletely self-bootstrapping.

What Prooby is not
==================

Prooby is not a Ruby implementation.  When writing Prooby code, you're in
Python's world.  You can't use Ruby's standard library, and writing code as if
you're writing for Ruby simply won't fly.  Use blocks, implicit returns, nested
control-flow structures, etc, but don't forget you're playing in Pythonland.

Installation
============

First, install prereqs:
> gem install ruby_parser pp

Clone the Prooby repos

Usage
=====

Standard prooby usage is as follows:
> ruby prooby.rb input.rb | python

Notice, a great deal of debugging information is dumped to a comment at the
beginning of the generated Python code.  It's invaluable for development.

Todo
====

 * Multiple-assignment support
 * Static/class methods
 * Decorators
 * Nested control-flow structures
 * Hash constants
