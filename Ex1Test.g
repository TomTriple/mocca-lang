grammar Ex1Test;

options {
  language=JavaScript;
  output=AST;
// removing k means k=*
}

tokens {
  UNARY;
}

@members {

}

prog: exprStmt* EOF -> exprStmt*
    ;

exprStmt: ID ':' 
          (
            expr -> ^(':' ID expr)
            |
            BOOLEAN -> ^(':' ID BOOLEAN)
          ) 
          ';'
        ;

fn: a=ID ':' (args+=ID ':'?)* '{' body+=exprStmt* '}' -> ^(':' $a $args* $body*)
  ;

expr: (exprMult -> exprMult) ('+' e=exprMult -> ^('+' $expr $e))*
    ;

exprMult:  (atom -> atom) ('*' e=atom -> ^('*' $exprMult $e))*
        ;

atom: INTEGER
     | ID
     | '(' expr ')' -> expr
     ;


BOOLEAN: ('T'|'F');
ID: CHAR (CHAR|'0'..'9'|'.')*;
INTEGER: '0'..'9'+;
STRING: '"' (.)* '"';
WS: (' '|'\t'|'\r'|'\n') { this.skip(); };

fragment CHAR: 'a'..'z'|'A'..'Z';



