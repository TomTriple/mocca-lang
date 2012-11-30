grammar Ex1Test;

options {
  language=JavaScript;
  output=AST;
// removing k means k=*
}


tokens {
  DEF_VAR;
  DEF_FUNC;
  DEF_CALL;
  DEF_STRUCT;
  PUTS;
  IF;
}


@members {

}

prog: statement* EOF -> statement*;

statement: ID '=' atom ';' -> ^(DEF_VAR ID atom)
         | ID '->' '()'? '{' body+=statement+ '}' ';' -> ^(DEF_FUNC ID $body+)
         | ID '()' ';' -> ^(DEF_CALL ID)
         | 'puts' (ID -> ^(PUTS ID)|atom -> ^(PUTS atom)) ';'
         | 'if' e=expression 'do' body+=statement+ 'end' ';' -> ^(IF $e $body+)
         | ID '=' '{' field+ '}' ';' -> ^(DEF_STRUCT ID field+)
         ;

field: ID '=' atom ';' -> ^(DEF_VAR ID atom)
     ;

expression: e1=INTEGER '==' e2=INTEGER -> ^('==' $e1 $e2)
          ;


atom: INTEGER
     | STRING
     | BOOLEAN
     ;


BOOLEAN: 'T'|'F';
ID: CHAR (CHAR|'0'..'9'|'.')*;
INTEGER: '0'..'9'+;
STRING: '"' (.)* '"';
WS: (' '|'\t'|'\r'|'\n') { this.skip(); };

fragment CHAR: 'a'..'z'|'A'..'Z';



