# Goertzel algorithm library

This library has Goertzel algorithm implementations in several
languages.  There is a certain level of uniformity between the
implementations/languages, but it is not dogmatic.

The main points are:

- Strive to not have any requirements other than the basics of
  the standard library of the language - if at all possible,
  only the math part of it

- For ease of use, be a single module, and, if at all possible, only
  one file

- Speed of execution was a consideration, but portability and ease of
  use and maintenance was more important

The choice of languages is somewhat arbitrary - these are the
languages in which I've implemented this beast throughout the years.
Thus, this code is battle-tested, but there are no unit tests. If I
find the time I'll try to compile some from the larger tests suites
that tested apps that used these modules.
