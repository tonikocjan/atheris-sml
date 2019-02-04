//
//  TokenType.swift
//  Atheris
//
//  Created by Toni Kocjan on 21/09/2018.
//

import Foundation

public enum TokenType: String {
  case nonEscapedStringConstant
  case invalidCharacter
  
  case eof = "EOF"
  
  case identifier = "IDENTIFIER"
  
  case logicalConstant = "LOG_CONST"
  case integerConstant = "INT_CONST"
  case stringConstant = "STRING_CONST"
  case floatingConstant = "FLOAT_CONST"
  case charConstant = "CHAR_CONST"
  
  case leftParent = "LPARENT"
  case rightParent = "RPARENT"
  case leftBracket = "LBRACKET"
  case rightBracket = "RBRACKET"
  case leftBrace = "LBRACE"
  case rightBrace = "RBRACE"
  
  case colon = "COLON"
  case semicolon = "SEMICOLON"
  case comma = "COMMA"
  case arrow = "ARROW"
  case darrow = "DARROW"
  case hashtag = "HASHTAG"
  case assign = "ASSIGN"
  case pipe = "PIPE"
  
  case wildcard = "_"
  
  case keywordModulo = "MOD"
  case keywordNot = "NOT"
  case keywordAbstype = "ABSTYPE"
  case keywordAnd = "AND"
  case keywordAndalso = "ANDALSO"
  case keywordAs = "AS"
  case keywordCase = "CASE"
  case keywordDatatype = "DATATYPE"
  case keywordDo = "DO"
  case keywordElse = "ELSE"
  case keywordEnd = "END"
  case keywordException = "EXCEPTION"
  case keywordFn = "FN"
  case keywordFun = "FUN"
  case keywordHandle = "handle"
  case keywordIf = "IF"
  case keywordIn = "IN"
  case keywordInfix = "INFIX"
  case keywordInfixr = "INFIXR"
  case keywordLet = "LET"
  case keywordLocal = "LOCAL"
  case keywordNonfix = "NONFIX"
  case keywordOf = "OF"
  case keywordOp = "OP"
  case keywordOpen = "OPEN"
  case keywordOrelse = "ORELSE"
  case keywordRaise = "RAISE"
  case keywordRec = "REC"
  case keywordThen = "THEN"
  case keywordType = "TYPE"
  case keywordVal = "VAL"
  case keywordWith = "WITH"
  case keywordWithtype = "WITHTYPE"
  case keywordWhile = "WHILE"
}
