## About
This repository represent my personal solutions for the [Write Yourself a Scheme in 48 Hours](https://en.wikibooks.org/wiki/Write_Yourself_a_Scheme_in_48_Hours) wikibook. Aparently the book is actually ~14 years old now (haven't confirmed this but came across a r/haskell thread where someone mentions this), so this is a good practical way to learn Haskell but probably doesn't contain newer features of the prelude (as if I'll ever know what those are :P).

## Build
I know I won't remember how to do this later so here a list of ways to compile the binaries for each chapter

chapter 2 ghc -package parsec -o bin/q2 sec/ch02/{file}