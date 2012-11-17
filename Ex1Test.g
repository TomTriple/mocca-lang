grammar Ex1Test;

options {
  language=JavaScript;
  k=2;
}

prog: statement* EOF;

// k=1 is not enough lookahead to distinguish between the alternatives in statement
statement: ID '=' value end           { console.debug("Assign: "+$ID.text+" = "+$value.text); }
         | ID '->' '{' '...' '}' end  { console.debug("Function: "+$ID.text); }
         ;

value: INTEGER|STRING;

end: ';';


ID: CHAR (CHAR|'0'..'9')*;
INTEGER: '0'..'9'+;
STRING: '"' (.)* '"';
WS: (' '|'\t'|'\r'|'\n') { this.skip(); };

fragment CHAR: 'a'..'z'|'A'..'Z';



