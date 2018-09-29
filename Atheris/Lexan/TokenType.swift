//
//  TokenType.swift
//  Atheris
//
//  Created by Toni Kocjan on 21/09/2018.
//

import Foundation

enum TokenType: String {
  case eof = "EOF"
  
  case identifier = "IDENTIFIER"
  
  case logicalConstant = "LOG_CONST"
  case integerConstant = "INT_CONST"
  case stringconstant = "STRING_CONST"
  case floatingConstant = "FLOAT_CONST"
  case charConstant = "CHAR_CONST"
  
  case and = "AND"
  case or = "OR"
  case not = "NOT"
  case equal = "EQU"
  case notEqual = "NEQ"
  case lowerThan = "LTH"
  case greaterThan = "GTH"
  case lowerOrEqual = "LEQ"
  case greaterOrEqual = "GEQ"
  
  case multiply = "MUL"
  case divide = "DIV"
  case modulo = "MOD"
  case add = "ADD"
  case subtract = "SUB"
  
  case leftParent = "LPARENT"
  case rightParent = "RPARENT"
  case leftBracket = "LBRACKET"
  case rightBracket = "RBRACKET"
  case leftBrace = "LBRACE"
  case rightBrace = "RBRACE"
  
  case dot = "DOT"
  case colon = "COLON"
  case semicolon = "SEMICOLON"
  case comma = "COMMA"
  case newline = "NEWLINE"
  case arrow = "->"
  
  case assign = "ASSIGN"
  
  case questionMark = "?"
  case esclamationMark = "!"
  
  case keywordElse = "ELSE"
  case keywordFor = "FOR"
  case keywordFun = "FUN"
  case keywordIf = "IF"
  case keywordVar = "VAR"
  case keywordWhile = "WHILE"
  case keywordStruct = "STRUCT"
  case keywordImport = "IMPORT"
  case keywordLet = "LET"
  case keywordNull = "NULL"
  case keywordClass = "CLASS"
  case keywordIn = "IN"
  case keywordReturn = "RETURN"
  case keywordPublic = "PUBLIC"
  case keywordPrivate = "PRIVATE"
  case keywordContinue = "CONTINUE"
  case keywordBreak = "BREAK"
  case keywordSwitch = "SWITCH"
  case keywordCase = "CASE"
  case keywordDefault = "DEFAULT"
  case keywordEnum = "ENUM"
  case keywordInit = "INIT"
  case keywordIs = "IS"
  case keywordAs = "AS"
  case keywordOverride = "OVERRIDE"
  case keywordExtension = "EXTENSION"
  case keywordFinal = "FINAL"
  case keywordStatic = "STATIC"
  case keywordInterface = "INTERFACE"
  case kwAbstract = "ABSTRACT"
}
