#  SML -> Racket 🚀 

Welcome to SML to Racket translator.

## Description

The goal of this project is to implement a compiler which will be able to parse `SML` code, evaluate it's semantics, and as a result produce valid `Racket` code.

## Project summary  

- Tokenization (lexical analysis) of SML code
- Syntax analysis: Abstract Syntax Tree
  - core syntax
- Semantic analysis: type evaluation
  - core semantics
- Code generation: target language ==> Racket

Source code of this _translator_ will be written in `Swift`.

🚀🚀🚀

## Other relevant information
Implementation of the compiler will be based on: http://sml-family.org/sml97-defn.pdf (PDF included in `/SML/sml97-defn.pdf`)

The codebase is based on `Atheris-Swift` project, which at this point in time contains only tokenization of the `Atheris` programming language. The original compiler (written in Java) can be found at https://gitlab.com/seckmaster/atheris. 
