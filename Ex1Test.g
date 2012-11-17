grammar Ex1Test;

options {
  language=JavaScript;
  k=1;
}

prog: statement* EOF;
statement: ID '=' value { console.debug("Assign: "+$ID.text+" = "+$value.text); }
//          | ID '->' '{' DOTS '}'
         ;

value: INTEGER|STRING;


ID: CHAR (CHAR|'0'..'9')*;
INTEGER: '0'..'9'+;
STRING: '"' (.)* '"';
EQ: '=';
WS: (' '|'\t'|'\r'|'\n') { this.skip(); };

fragment CHAR: 'a'..'z'|'A'..'Z';



