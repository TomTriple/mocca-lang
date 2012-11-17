grammar Ex1Test;

options {
  language=JavaScript;
  k=1;
}

prog: EOF;
/*
statement: ID '=' value { console.debug("Assign: "+$ID.text+" = "+$value.text); }
         | ID '->' '{' DOTS '}'
         ;

value: INTEGER|STRING;
*/


ID: CHAR (CHAR|'0'..'9')*;
INTEGER: '0'..'9'+;
// FLOAT: '0'..'9'+ '.' '0'..'9';
EQ: '=';
WS: (' '|'\t'|'\r'|'\n') { this.skip(); };

fragment CHAR: 'a'..'z'|'A'..'Z';



