grammar Ex1Test;

options {
  language=JavaScript;
  output=AST;
}

tokens {
  FN_CALL;
  FN_DEF;
  FN_DEF_INLINE;
  EX;
}

@members {

}

prog: exprStmt* EOF -> exprStmt*
    ;

exprStmt: ID ':' expr ';' -> ^(':' ID expr)
        | name=ID ':' '{' (arg+=ID)? (',' arg+=ID)* '=>' body+=exprStmt* '}' ';' -> ^(FN_DEF $name $arg* $body*)
        | name=ID ':' '=>' inline=exprStmt -> ^(FN_DEF_INLINE $name $inline)
        | expr ';' -> ^(EX expr)
        ;

expr: (exprAnd -> exprAnd) 
        (
          ('||' e=exprAnd -> ^('||' $expr $e))
        )*
    ;

exprAnd: (exprCompare -> exprCompare) 
        (
          ('&&' e=exprCompare -> ^('&&' $exprAnd $e))
        )*
    ;

exprCompare: (exprAdd -> exprAdd) 
        (
          ('==' e=exprAdd -> ^('==' $exprCompare $e))
          |
          ('!=' e=exprAdd -> ^('!=' $exprCompare $e))
          |
          ('>' e=exprAdd -> ^('>' $exprCompare $e))
          |
          ('<' e=exprAdd -> ^('<' $exprCompare $e))
          |
          ('>=' e=exprAdd -> ^('>=' $exprCompare $e))
          |
          ('<=' e=exprAdd -> ^('<=' $exprCompare $e))
        )?
    ;

exprAdd: (exprMult -> exprMult) 
          (
            ('+' e=exprMult -> ^('+' $exprAdd $e)) 
            |
            ('-' e=exprMult -> ^('-' $exprAdd $e))
          )*
    ;

exprMult:(unary -> unary) 
          (
            ('*' e=unary -> ^('*' $exprMult $e))
            |
            ('/' e=unary -> ^('/' $exprMult $e))
           )*
        ;

unary: atom
     | '!' unary -> ^('!' unary) // points again to unary as one can chain multiple negations like !!!true;
     ;

// matching for BOOLEAN in atom means one can syntactically use TRUE in an arithmetic expression which
// doesn´t make much sense. Cases like this need to be catched in the semantic analysis phase.
atom: INTEGER
     | ID
     | BOOLEAN
     | '(' expr ')' -> expr
     | fn
     | 'if' cond=expr ':' body=exprStmt -> ^('if' $cond $body)
     ;

fn: ID '(' e+=expr? (',' e+=expr)* ')' -> ^(FN_CALL ID $e*)
//  | (ID '(' expr? (',' expr)* ')' '{')=>ID '(' x+=expr? (',' x+=expr)* ')' '{' body=exprStmt '}' -> ^(FN_CALL_LAZY ID $x* $body)
  ;

BOOLEAN: ('T'|'F');
ID: CHAR (CHAR|'0'..'9'|'.')*;
INTEGER: '0'..'9'+;
STRING: '"' (.)* '"';
WS: (' '|'\t'|'\r'|'\n') { this.skip(); };

fragment CHAR: 'a'..'z'|'A'..'Z';


