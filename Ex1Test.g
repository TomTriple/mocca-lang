grammar Ex1Test;

options {
  language=JavaScript;
  output=AST;
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

expr: (exprCompare -> exprCompare) 
        (
          ('&&' e=exprCompare -> ^('&&' $expr $e))
        )?
    ;

exprCompare: (exprAdd -> exprAdd) 
        (
          ('==' e=exprAdd -> ^('==' $exprCompare $e))
          |
          ('>' e=exprAdd -> ^('>' $exprCompare $e))
          |
          ('<' e=exprAdd -> ^('<' $exprCompare $e))
        )?
    ;

exprAdd: (exprMult -> exprMult) 
          (
            ('+' e=exprMult -> ^('+' $exprAdd $e)) 
            |
            ('-' e=exprMult -> ^('-' $exprAdd $e))
          )*
    ;

exprMult:  (atom -> atom) 
          (
            ('*' e=atom -> ^('*' $exprMult $e))
            |
            ('/' e=atom -> ^('/' $exprMult $e))
           )*
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



